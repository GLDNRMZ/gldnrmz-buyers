local QBCore = exports['qb-core']:GetCoreObject()

PlayerJob = {}

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(200)
        PlayerJob = QBCore.Functions.GetPlayerData().job
        isLoggedIn = true
    end
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

function loadAnimDict(dict) while (not HasAnimDictLoaded(dict)) do RequestAnimDict(dict) Wait(0) end end

-- Change shopPeds and shopBlips to support arrays (multiple entities per shopId)
local shopPeds = {} -- shopId -> { ped1, ped2, ... }
local shopBlips = {} -- shopId -> { blip1, blip2, ... }
local isLeaving = {}

function DeleteShopPed(shopId)
    -- Delete all peds for this shop
    if shopPeds[shopId] then
        for _, ped in pairs(shopPeds[shopId]) do
            if DoesEntityExist(ped) then
                DeletePed(ped)
            end
        end
        shopPeds[shopId] = nil
    end
    
    -- Remove all blips for this shop
    if shopBlips[shopId] then
        for _, blip in pairs(shopBlips[shopId]) do
            RemoveBlip(blip)
        end
        shopBlips[shopId] = nil
    end
end

function SpawnSinglePed(shopId, shopData, location)
    RequestModel(GetHashKey(shopData.model))
    while not HasModelLoaded(GetHashKey(shopData.model)) do
        Wait(0)
    end

    local ped = CreatePed(0, GetHashKey(shopData.model), location.x, location.y, location.z, location.w, false, false)
    
    -- Initialize table if it doesn't exist
    if not shopPeds[shopId] then shopPeds[shopId] = {} end
    table.insert(shopPeds[shopId], ped)

    SetEntityAsMissionEntity(ped)
    SetPedFleeAttributes(ped, 0, 0)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    TaskStartScenarioInPlace(ped, shopData.pedScenario, 0, true)

    if shopData.blip and shopData.blip.enabled then
        local blip = AddBlipForCoord(location.x, location.y, location.z)
        SetBlipSprite(blip, shopData.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, shopData.blip.scale)
        SetBlipColour(blip, shopData.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(shopData.blip.label)
        EndTextCommandSetBlipName(blip)
        
        -- Initialize table if it doesn't exist
        if not shopBlips[shopId] then shopBlips[shopId] = {} end
        table.insert(shopBlips[shopId], blip)
    end

    exports.ox_target:addLocalEntity(ped, {
        {
            name = "sell_items_" .. shopId,
            icon = "fa-solid fa-comments-dollar",
            label = "Sell items to " .. shopData.label,
            onSelect = function(data)
                loadAnimDict(shopData.animation.dict)
                TaskPlayAnim(PlayerPedId(), shopData.animation.dict, shopData.animation.anim, 8.0, 1.0, -1, 1, 0, 0, 0, 0)
                
                if shopData.dispatch.enabled and math.random(1, 100) <= shopData.dispatch.chance then
                    shopData.dispatch.call()
                end 
                
                if lib.progressBar({
                    duration = shopData.progress.duration,
                    label = shopData.progress.label,
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                    },
                }) then
                    ClearPedTasks(PlayerPedId())
                    if not shopData.restrictedJobs[PlayerJob.name] then
                        local options = {
                            {
                                title = 'Sell Everything',
                                description = 'Sell all matching items',
                                icon = 'chart-pie',
                                event = 'gldnrmz-buyers:client:confirmSellAll',
                                args = { shopId = shopId }
                            }
                        }

                        for item, itemData in pairs(shopData.items) do
                            local count = exports.ox_inventory:Search('count', item)
                            if count > 0 then
                                local label = itemData.label or (exports.ox_inventory:Items()[item] and exports.ox_inventory:Items()[item].label) or item
                                table.insert(options, {
                                    title = 'Sell ' .. label,
                                    description = 'Sell your ' .. label,
                                    icon = 'tag', 
                                    serverEvent = 'gldnrmz-buyers:server:sellSpecific',
                                    args = { item = item, shopId = shopId }
                                })
                            end
                        end

                        if #options == 1 then
                            lib.notify({ description = "You have nothing I'm interested in.", type = 'error' })
                        else
                            lib.registerContext({
                                id = 'sell_menu_' .. shopId,
                                title = shopData.label,
                                options = options
                            })
                            lib.showContext('sell_menu_' .. shopId)
                        end
                    else
                        lib.notify({ description = "I don't deal with your kind!", type = 'error' })
                    end
                else
                    ClearPedTasks(PlayerPedId())
                end
            end
        }
    })
end

RegisterNetEvent('gldnrmz-buyers:client:confirmSellAll', function(data)
    local alert = lib.alertDialog({
        header = 'Sell All Items',
        content = 'Are you sure you want to sell all available items to this store?',
        centered = true,
        cancel = true
    })

    if alert == 'confirm' then
        TriggerServerEvent('gldnrmz-buyers:server:sellItems', data)
    end
end)

function CreateShopPed(shopId, shopData)
    if shopData.randomizeLocations then
        -- Spawn ONE ped at a RANDOM location
        local locIndex = math.random(#shopData.locations)
        local location = shopData.locations[locIndex]
        SpawnSinglePed(shopId, shopData, location)
    else
        -- Spawn ALL peds at ALL locations
        for _, location in ipairs(shopData.locations) do
            SpawnSinglePed(shopId, shopData, location)
        end
    end
end

CreateThread(function()
    while true do
        Wait(1000)
        local hours = GetClockHours()

        for shopId, shopData in pairs(Config.Shops) do
            local isOpen = false

            if not shopData.timeRestricted then
                 isOpen = true
            elseif shopData.open < shopData.close then
                 if hours >= shopData.open and hours < shopData.close then isOpen = true end
            else
                 if hours >= shopData.open or hours < shopData.close then isOpen = true end
            end

            if isOpen then
                isLeaving[shopId] = false
                if not shopPeds[shopId] then -- Check if table exists (meaning peds spawned)
                    CreateShopPed(shopId, shopData)
                end
            else
                if shopPeds[shopId] and not isLeaving[shopId] then
                    isLeaving[shopId] = true
                    
                    for _, ped in pairs(shopPeds[shopId]) do
                        if DoesEntityExist(ped) then
                            -- Remove target options so players can't interact
                            exports.ox_target:removeLocalEntity(ped, "sell_items_" .. shopId)
                            
                            -- Make ped walk away
                            FreezeEntityPosition(ped, false)
                            ClearPedTasks(ped)
                            TaskWanderStandard(ped, 10.0, 10)
                        end
                    end
                    
                    SetTimeout(15000, function()
                        DeleteShopPed(shopId)
                        isLeaving[shopId] = false
                    end)
                end
            end
        end
    end
end)

--------------------
-- RESOURCE STOP --
--------------------

AddEventHandler('onResourceStop', function(resourceName) 
	if GetCurrentResourceName() == resourceName then
        for shopId, peds in pairs(shopPeds) do
            for _, ped in pairs(peds) do
                if DoesEntityExist(ped) then
                    DeletePed(ped)
                end
            end
        end
        for shopId, blips in pairs(shopBlips) do
            for _, blip in pairs(blips) do
                RemoveBlip(blip)
            end
        end
	end 
end)
