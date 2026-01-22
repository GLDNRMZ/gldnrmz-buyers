local QBCore = exports['qb-core']:GetCoreObject()

local function AddSocietyMoney(society, amount)
    if not society or amount <= 0 then return end
    
    if Config.BankScript == 'Renewed-Banking' then
        exports['Renewed-Banking']:addAccountMoney(society, amount)
    elseif Config.BankScript == 'qb-management' then
        exports['qb-management']:AddMoney(society, amount)
    elseif Config.BankScript == 'okokBanking' then
        exports['okokBanking']:AddSocietyMoney(society, amount)
    elseif Config.BankScript == 'custom' then
        -- Add custom export here
        print("^3[gldnrmz-buyers] Custom banking selected but not configured.^7")
    end
end

local function validateShopConditions(src, shopId)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    
    local shopData = Config.Shops[shopId]
    if not shopData then return false end

    -- 1. Job Restriction Check
    if shopData.restrictedJobs and shopData.restrictedJobs[Player.PlayerData.job.name] then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = "You cannot use this shop with your current job." })
        return false
    end

    -- 2. Distance Check
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local nearShop = false
    
    for _, loc in pairs(shopData.locations) do
        -- loc is vec4, we only need x,y,z
        local dist = #(coords - vector3(loc.x, loc.y, loc.z))
        if dist < 15.0 then -- 15.0 units buffer
            nearShop = true
            break
        end
    end

    if not nearShop then
        print(string.format("^1[Security] Player %s (ID: %s) attempted to sell items at %s but was too far away. Coords: %s^7", Player.PlayerData.name, src, shopId, coords))
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = "You are too far from the shop." })
        return false
    end

    return true
end

RegisterNetEvent('gldnrmz-buyers:server:sellItems', function(args)
    local src = source
    local shopId = args and args.shopId
    
    if not shopId or not Config.Shops[shopId] then return end
    
    -- Security Validation
    if not validateShopConditions(src, shopId) then return end
    
    local shopData = Config.Shops[shopId]
    local price = 0
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local inventory = exports.ox_inventory:GetInventoryItems(src)
    
    if inventory then
        for _, item in pairs(inventory) do
            if shopData.items[item.name] then
                local amount = item.count
                if amount > 0 then
                    local itemPrice = 0
                    local priceData = shopData.items[item.name].price
                    
                    if type(priceData) == 'table' then
                        itemPrice = math.random(priceData.min, priceData.max)
                    else
                        itemPrice = priceData
                    end
                    
                    price = price + (itemPrice * amount)
                    exports.ox_inventory:RemoveItem(src, item.name, amount)
                end
            end
        end
    end

    if price > 0 then
        local playerMoney = price
        
        -- Handle Society Funds
        if shopData.society and shopData.society.enabled then
            local societyAmount = math.floor(price * (shopData.society.percent / 100))
            if societyAmount > 0 then
                AddSocietyMoney(shopData.society.account, societyAmount)
                playerMoney = price - societyAmount -- Deduct from player? Or is it extra? Assuming split.
            end
        end

        Player.Functions.AddMoney("cash", playerMoney)
        TriggerClientEvent('ox_lib:notify', src, { type = 'success', description = "You sold everything for $" .. playerMoney })
    else
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = "You have nothing to sell!" })
    end
end)

local function sellSpecificItem(src, itemName, label, shopId)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local shopData = Config.Shops[shopId]
    if not shopData or not shopData.items[itemName] then return end

    local count = exports.ox_inventory:Search(src, 'count', itemName)
    if count > 0 then
        local priceData = shopData.items[itemName].price
        local singlePrice = 0
        
        if type(priceData) == 'table' then
            singlePrice = math.random(priceData.min, priceData.max)
        else
            singlePrice = priceData
        end
        
        local price = singlePrice * count
        if exports.ox_inventory:RemoveItem(src, itemName, count) then
            local playerMoney = price
            
            -- Handle Society Funds
            if shopData.society and shopData.society.enabled then
                local societyAmount = math.floor(price * (shopData.society.percent / 100))
                if societyAmount > 0 then
                    AddSocietyMoney(shopData.society.account, societyAmount)
                    playerMoney = price - societyAmount
                end
            end

            Player.Functions.AddMoney("cash", playerMoney)
            TriggerClientEvent('ox_lib:notify', src, { type = 'success', description = "You sold your " .. label .. " for $" .. playerMoney })
        end
    else
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = "You don't have " .. label .. " to sell" })
    end
end

RegisterNetEvent('gldnrmz-buyers:server:sellSpecific', function(args)
    local src = source
    local itemName = args.item
    local shopId = args.shopId
    
    if not shopId or not Config.Shops[shopId] then return end
    if not itemName or not Config.Shops[shopId].items[itemName] then return end
    
    -- Security Validation
    if not validateShopConditions(src, shopId) then return end

    local label = Config.Shops[shopId].items[itemName].label or itemName
    sellSpecificItem(src, itemName, label, shopId)
end)
