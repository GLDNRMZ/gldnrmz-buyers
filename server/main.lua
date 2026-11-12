local Bridge = exports.community_bridge:Bridge()
local Framework = Bridge.Framework
local Inventory = Bridge.Inventory

local RESOURCE = GetCurrentResourceName()
local LOCATION_KEY = ('%s:locations'):format(RESOURCE)

-- src -> { shopId, location, startedAt, prices, expiresAt, lastAction }
local sessions = {}

-----------------------------------------------------------------------
-- Helpers
-----------------------------------------------------------------------

local function log(src, event, message, ...)
    if Config.Logging then
        lib.logger(src, event, message:format(...))
    end
end

local function warn(message, ...)
    print(('^3[%s] %s^7'):format(RESOURCE, message:format(...)))
end

local function getJobName(src)
    local data = Framework.GetPlayerJobData and Framework.GetPlayerJobData(src)
    return data and data.jobName
end

local function rollPrice(price)
    if type(price) == 'table' then
        return math.random(price.min, price.max)
    end
    return price
end

local function commissionOf(shop)
    local society = shop.society
    if society and society.enabled and (society.percent or 0) > 0 then
        return society.percent
    end
    return 0
end

--- Splits a gross amount into (playerCut, societyCut).
local function split(shop, gross)
    local societyCut = math.floor(gross * commissionOf(shop) / 100)
    return gross - societyCut, societyCut
end

local bankAdapters = {
    ['Renewed-Banking'] = function(account, amount)
        exports['Renewed-Banking']:addAccountMoney(account, amount)
    end,
    ['qb-banking'] = function(account, amount)
        exports['qb-banking']:AddMoney(account, amount, 'Buyer commission')
    end,
    ['qb-management'] = function(account, amount)
        exports['qb-management']:AddMoney(account, amount)
    end,
    ['okokBanking'] = function(account, amount)
        exports['okokBanking']:AddSocietyMoney(account, amount)
    end,
    ['esx_banking'] = function(account, amount)
        TriggerEvent('esx_addonaccount:getSharedAccount', account, function(shared)
            if shared then
                shared.addMoney(amount)
            else
                warn('ESX shared account not found: %s', account)
            end
        end)
    end,
    ['custom'] = function(account, amount)
        -- Add your own banking export here.
        warn('Custom banking selected but not configured (%s, $%d).', account, amount)
    end,
}

local function addSocietyMoney(account, amount)
    if not account or amount <= 0 then return end
    local adapter = bankAdapters[Config.BankScript]
    if not adapter then return end

    local ok, err = pcall(adapter, account, amount)
    if not ok then
        warn('Failed to pay society "%s" via %s: %s', account, Config.BankScript, err)
    end
end

--- Returns the shop locations a player may legitimately be standing at.
local function activeLocations(shopId, shop)
    if shop.randomizeLocations then
        local index = (GlobalState[LOCATION_KEY] or {})[shopId]
        return { shop.locations[index or 1] }
    end
    return shop.locations
end

local function nearestLocation(src, shopId, shop)
    local coords = GetEntityCoords(GetPlayerPed(src))
    for _, loc in ipairs(activeLocations(shopId, shop)) do
        if #(coords - loc.xyz) <= Config.MaxSellDistance then
            return loc
        end
    end
    return nil, coords
end

local function isNear(src, location)
    return #(GetEntityCoords(GetPlayerPed(src)) - location.xyz) <= Config.MaxSellDistance
end

--- Builds the price list shown to the client from the prices locked in at negotiation.
local function buildQuote(src, shop, prices)
    local items, gross = {}, 0

    for name, unit in pairs(prices) do
        local count = Inventory.GetItemCount(src, name) or 0
        if count > 0 then
            local total = unit * count
            gross = gross + total
            items[#items + 1] = {
                name = name,
                label = shop.items[name].label or name,
                count = count,
                unit = unit,
                payout = (split(shop, total)),
            }
        end
    end

    table.sort(items, function(a, b) return a.label < b.label end)

    return {
        items = items,
        total = (split(shop, gross)),
        commission = commissionOf(shop),
    }
end

--- Validates that a player has a live, unexpired quote at this shop and is still nearby.
local function getActiveSession(src, shopId)
    local session = sessions[src]
    if not session or session.shopId ~= shopId or not session.prices then
        return nil, 'You need to talk to the buyer first.'
    end
    if GetGameTimer() > session.expiresAt then
        sessions[src] = nil
        return nil, 'The buyer lost interest. Talk to them again.'
    end
    if not isNear(src, session.location) then
        return nil, 'You are too far from the buyer.'
    end
    return session
end

-----------------------------------------------------------------------
-- Randomized locations (server-authoritative, synced via GlobalState)
-----------------------------------------------------------------------

local function rollLocations()
    local current = GlobalState[LOCATION_KEY] or {}
    local nextState = {}

    for shopId, shop in pairs(Config.Shops) do
        if shop.randomizeLocations and #shop.locations > 0 then
            local index = math.random(#shop.locations)
            if #shop.locations > 1 then
                while index == current[shopId] do
                    index = math.random(#shop.locations)
                end
            end
            nextState[shopId] = index
        end
    end

    GlobalState[LOCATION_KEY] = nextState
end

rollLocations()

if (Config.RelocateMinutes or 0) > 0 then
    CreateThread(function()
        while true do
            Wait(Config.RelocateMinutes * 60000)
            rollLocations()
        end
    end)
end

-----------------------------------------------------------------------
-- Callbacks
-----------------------------------------------------------------------

--- Step 1: player talks to the buyer. Checks job + distance and starts the timer.
lib.callback.register('gldnrmz-buyers:server:startNegotiation', function(src, shopId)
    local shop = Config.Shops[shopId]
    if not shop then return false end

    local job = getJobName(src)
    if job and shop.restrictedJobs and shop.restrictedJobs[job] then
        return false, "I don't deal with your kind!"
    end

    local location, coords = nearestLocation(src, shopId, shop)
    if not location then
        warn('%s (ID %s) tried to negotiate at %s from %s - too far away.',
            GetPlayerName(src), src, shopId, coords)
        return false, 'You are too far from the buyer.'
    end

    sessions[src] = {
        shopId = shopId,
        location = location,
        startedAt = GetGameTimer(),
    }

    return true
end)

--- Step 2: after the progress bar, lock in prices and return the quote.
lib.callback.register('gldnrmz-buyers:server:getQuote', function(src, shopId)
    local shop = Config.Shops[shopId]
    local session = sessions[src]
    if not shop or not session or session.shopId ~= shopId then return false end

    -- The client can't skip the negotiation time.
    local required = (shop.progress and shop.progress.duration or 0) - 500
    if GetGameTimer() - session.startedAt < required then
        warn('%s (ID %s) requested a quote at %s before negotiation finished.', GetPlayerName(src), src, shopId)
        sessions[src] = nil
        return false
    end

    if not isNear(src, session.location) then
        sessions[src] = nil
        return false, 'You are too far from the buyer.'
    end

    local prices = {}
    for name, data in pairs(shop.items) do
        if (Inventory.GetItemCount(src, name) or 0) > 0 then
            prices[name] = rollPrice(data.price)
        end
    end

    session.prices = prices
    session.expiresAt = GetGameTimer() + Config.QuoteTimeout * 1000

    return true, buildQuote(src, shop, prices)
end)

--- Step 3: sell one item (itemName) or everything on the quote (itemName == nil).
lib.callback.register('gldnrmz-buyers:server:sell', function(src, shopId, itemName)
    local shop = Config.Shops[shopId]
    if not shop then return false end

    local session, err = getActiveSession(src, shopId)
    if not session then return false, err end

    local now = GetGameTimer()
    if session.lastAction and now - session.lastAction < 500 then
        return false, 'Slow down.'
    end
    session.lastAction = now

    local toSell = {}
    if itemName then
        if not session.prices[itemName] then return false, "I'm not buying that." end
        toSell[itemName] = session.prices[itemName]
    else
        toSell = session.prices
    end

    local gross, sold = 0, {}
    for name, unit in pairs(toSell) do
        local count = Inventory.GetItemCount(src, name) or 0
        if count > 0 and Inventory.RemoveItem(src, name, count) then
            gross = gross + unit * count
            sold[#sold + 1] = ('%dx %s'):format(count, name)
        end
    end

    if gross <= 0 then
        return false, "You don't have anything I want.", buildQuote(src, shop, session.prices)
    end

    local playerCut, societyCut = split(shop, gross)
    Framework.AddAccountBalance(src, 'cash', playerCut)
    if societyCut > 0 then
        addSocietyMoney(shop.society.account, societyCut)
    end

    log(src, 'sale', '%s sold [%s] at %s for $%d (society $%d)',
        GetPlayerName(src), table.concat(sold, ', '), shopId, playerCut, societyCut)

    local label = itemName and (shop.items[itemName].label or itemName) or 'everything'
    return true, ('You sold %s for $%d'):format(label, playerCut), buildQuote(src, shop, session.prices)
end)

AddEventHandler('playerDropped', function()
    sessions[source] = nil
end)
