local Bridge = exports.community_bridge:Bridge()
local Target = Bridge.Target

local RESOURCE = GetCurrentResourceName()
local LOCATION_KEY = ('%s:locations'):format(RESOURCE)
local MENU_ID = 'gldnrmz_buyers_menu'

--[[
    shopId -> {
        open    = bool,
        points  = { lib.points },
        blips   = { blip handles },
        peds    = { [point] = ped },
    }
]]
local shops = {}
local leavingPeds = {}
local busy = false

-----------------------------------------------------------------------
-- Helpers
-----------------------------------------------------------------------

local function notify(message, nType)
    if message then
        lib.notify({ description = message, type = nType or 'inform' })
    end
end

local function isShopOpen(shop)
    if not shop.timeRestricted then return true end
    local hour = GetClockHours()
    if shop.open < shop.close then
        return hour >= shop.open and hour < shop.close
    end
    return hour >= shop.open or hour < shop.close
end

local function getLocations(shopId, shop)
    if shop.randomizeLocations then
        local index = (GlobalState[LOCATION_KEY] or {})[shopId]
        return index and { shop.locations[index] } or {}
    end
    return shop.locations
end

local function targetName(shopId)
    return 'sell_items_' .. shopId
end

-----------------------------------------------------------------------
-- Selling flow
-----------------------------------------------------------------------

local openMenu

local function sell(shopId, itemName)
    local ok, message, quote = lib.callback.await('gldnrmz-buyers:server:sell', false, shopId, itemName)
    notify(message, ok and 'success' or 'error')

    if quote and #quote.items > 0 then
        openMenu(shopId, quote)
    end
end

function openMenu(shopId, quote)
    local shop = Config.Shops[shopId]
    local options = {
        {
            title = 'Sell Everything',
            description = ('You will receive: $%d'):format(quote.total),
            icon = 'sack-dollar',
            onSelect = function()
                local answer = lib.alertDialog({
                    header = 'Sell All Items',
                    content = ('Sell everything listed for **$%d**?'):format(quote.total),
                    centered = true,
                    cancel = true,
                })
                if answer == 'confirm' then
                    sell(shopId, nil)
                else
                    openMenu(shopId, quote)
                end
            end,
        },
    }

    if quote.commission > 0 then
        options[#options + 1] = {
            title = ('Commission: -%d%%'):format(quote.commission),
            description = 'Society fee applied to all sales',
            icon = 'circle-info',
            disabled = true,
        }
    end

    for _, item in ipairs(quote.items) do
        options[#options + 1] = {
            title = ('Sell %s x%d'):format(item.label, item.count),
            description = ('$%d ea | You get: $%d'):format(item.unit, item.payout),
            icon = 'tag',
            onSelect = function()
                sell(shopId, item.name)
            end,
        }
    end

    lib.registerContext({ id = MENU_ID, title = shop.label, options = options })
    lib.showContext(MENU_ID)
end

local function negotiate(shopId)
    if busy then return end
    busy = true

    local shop = Config.Shops[shopId]
    local ok, reason = lib.callback.await('gldnrmz-buyers:server:startNegotiation', false, shopId)
    if not ok then
        notify(reason or 'The buyer is not interested right now.', 'error')
        busy = false
        return
    end

    local dispatch = shop.dispatch
    if dispatch and dispatch.enabled and dispatch.call and math.random(100) <= dispatch.chance then
        local success, err = pcall(dispatch.call, shopId, GetEntityCoords(cache.ped))
        if not success then
            print(('^3[%s] Dispatch call failed for %s: %s^7'):format(RESOURCE, shopId, err))
        end
    end

    local progress = shop.progress or {}
    local anim = shop.animation
    local completed = lib.progressBar({
        duration = progress.duration or 5000,
        label = progress.label or 'Negotiating...',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
        anim = anim and { dict = anim.dict, clip = anim.anim } or nil,
    })

    if not completed then
        busy = false
        return
    end

    local success, quote = lib.callback.await('gldnrmz-buyers:server:getQuote', false, shopId)
    busy = false

    if not success then
        notify(quote or 'The deal fell through.', 'error')
    elseif #quote.items == 0 then
        notify("You have nothing I'm interested in.", 'error')
    else
        openMenu(shopId, quote)
    end
end

-----------------------------------------------------------------------
-- Peds and blips
-----------------------------------------------------------------------

local function spawnPed(shopId, shop, loc)
    local ok, model = pcall(lib.requestModel, shop.model, 10000)
    if not ok then
        print(('^1[%s] Failed to load model %s for %s^7'):format(RESOURCE, shop.model, shopId))
        return
    end

    local ped = CreatePed(4, model, loc.x, loc.y, loc.z, loc.w, false, true)
    SetModelAsNoLongerNeeded(model)

    SetEntityAsMissionEntity(ped, true, true)
    SetPedFleeAttributes(ped, 0, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    if shop.pedScenario then
        TaskStartScenarioInPlace(ped, shop.pedScenario, 0, true)
    end

    Target.AddLocalEntity(ped, {
        {
            name = targetName(shopId),
            icon = 'fa-solid fa-comments-dollar',
            label = 'Sell items to ' .. shop.label,
            distance = 2.5,
            onSelect = function()
                negotiate(shopId)
            end,
        },
    })

    return ped
end

local function deletePed(shopId, ped)
    if ped and DoesEntityExist(ped) then
        Target.RemoveLocalEntity(ped, targetName(shopId))
        DeleteEntity(ped)
    end
end

local function createBlip(shop, loc)
    local cfg = shop.blip
    local blip = AddBlipForCoord(loc.x, loc.y, loc.z)
    SetBlipSprite(blip, cfg.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, cfg.scale)
    SetBlipColour(blip, cfg.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(cfg.label)
    EndTextCommandSetBlipName(blip)
    return blip
end

--- Shows the shop: blips plus proximity points that spawn the ped when a player is near.
local function openShop(shopId, shop)
    local state = { open = true, points = {}, blips = {}, peds = {} }
    shops[shopId] = state

    for _, loc in ipairs(getLocations(shopId, shop)) do
        if shop.blip and shop.blip.enabled then
            state.blips[#state.blips + 1] = createBlip(shop, loc)
        end

        local point = lib.points.new({ coords = loc.xyz, distance = Config.SpawnDistance })

        function point:onEnter()
            state.peds[self] = spawnPed(shopId, shop, loc)
        end

        function point:onExit()
            deletePed(shopId, state.peds[self])
            state.peds[self] = nil
        end

        state.points[#state.points + 1] = point
    end
end

--- Hides the shop. With `walkAway`, peds wander off before being deleted.
local function closeShop(shopId, walkAway)
    local state = shops[shopId]
    if not state then return end
    shops[shopId] = nil

    for _, point in ipairs(state.points) do point:remove() end
    for _, blip in ipairs(state.blips) do RemoveBlip(blip) end

    for _, ped in pairs(state.peds) do
        if walkAway and DoesEntityExist(ped) then
            Target.RemoveLocalEntity(ped, targetName(shopId))
            FreezeEntityPosition(ped, false)
            ClearPedTasks(ped)
            TaskWanderStandard(ped, 10.0, 10)
            leavingPeds[ped] = shopId
            SetTimeout(15000, function()
                if leavingPeds[ped] then
                    leavingPeds[ped] = nil
                    deletePed(shopId, ped)
                end
            end)
        else
            deletePed(shopId, ped)
        end
    end

    if lib.getOpenContextMenu() == MENU_ID then lib.hideContext() end
end

-----------------------------------------------------------------------
-- Opening hours and location sync
-----------------------------------------------------------------------

CreateThread(function()
    while true do
        for shopId, shop in pairs(Config.Shops) do
            local open = isShopOpen(shop)
            if open and not shops[shopId] then
                openShop(shopId, shop)
            elseif not open and shops[shopId] then
                closeShop(shopId, true)
            end
        end
        Wait(5000)
    end
end)

-- Server moved a randomized shop: rebuild it at the new spot.
AddStateBagChangeHandler(LOCATION_KEY, 'global', function(_, _, value)
    local previous = GlobalState[LOCATION_KEY] or {}
    for shopId, index in pairs(value or {}) do
        if previous[shopId] ~= index and shops[shopId] then
            closeShop(shopId, false)
            -- GlobalState updates after this handler runs; wait a tick so getLocations sees the new index.
            SetTimeout(0, function()
                local shop = Config.Shops[shopId]
                if shop and not shops[shopId] and isShopOpen(shop) then
                    openShop(shopId, shop)
                end
            end)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= RESOURCE then return end
    for shopId in pairs(shops) do
        closeShop(shopId, false)
    end
    for ped, shopId in pairs(leavingPeds) do
        deletePed(shopId, ped)
    end
end)
