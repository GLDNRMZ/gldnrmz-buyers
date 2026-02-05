local Bridge = exports['community_bridge']:Bridge()
local Framework = Bridge.Framework
local Inventory = Bridge.Inventory
local Notify = Bridge.Notify

local function notifyPlayer(src, title, message, nType)
    if Notify and Notify.SendNotification then
        Notify.SendNotification(src, title, message, nType, 5000)
        return
    end
    if Notify and Notify.SendNotify then
        Notify.SendNotify(src, message, nType, 5000)
        return
    end
    TriggerClientEvent('ox_lib:notify', src, { type = nType or 'info', description = message })
end

local function addCash(src, amount)
    return Framework.AddAccountBalance(src, 'cash', amount)
end

local function getPlayerJobName(src)
    local jobData = Framework.GetPlayerJobData and Framework.GetPlayerJobData(src) or nil
    return jobData and jobData.jobName or nil
end

local function getPlayerName(src)
    local first, last = Framework.GetPlayerName(src)
    if first and last then
        return (first .. ' ' .. last)
    end
    return first or last or 'Unknown'
end

local function AddSocietyMoney(society, amount)
    if not society or amount <= 0 then return end
    
    if Config.BankScript == 'Renewed-Banking' then
        exports['Renewed-Banking']:addAccountMoney(society, amount)
    elseif Config.BankScript == 'qb-management' then
        exports['qb-management']:AddMoney(society, amount)
    elseif Config.BankScript == 'okokBanking' then
        exports['okokBanking']:AddSocietyMoney(society, amount)
    elseif Config.BankScript == 'esx_banking' then
        TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
            if not account then
                print(string.format("^3[gldnrmz-buyers] ESX account not found: %s^7", tostring(society)))
                return
            end
            account.addMoney(amount)
        end)
    elseif Config.BankScript == 'custom' then
        -- Add custom export here
        print("^3[gldnrmz-buyers] Custom banking selected but not configured.^7")
    end
end

local function validateShopConditions(src, shopId)
    local playerJob = getPlayerJobName(src)
    if not playerJob then return false end
    
    local shopData = Config.Shops[shopId]
    if not shopData then return false end

    -- 1. Job Restriction Check
    if shopData.restrictedJobs and shopData.restrictedJobs[playerJob] then
        notifyPlayer(src, 'Error', "You cannot use this shop with your current job.", 'error')
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
        local playerName = getPlayerName(src)
        print(string.format("^1[Security] Player %s (ID: %s) attempted to sell items at %s but was too far away. Coords: %s^7", playerName, src, shopId, coords))
        notifyPlayer(src, 'Error', "You are too far from the shop.", 'error')
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

    local inventoryItems = Inventory.GetPlayerInventory and Inventory.GetPlayerInventory(src) or {}
    
    if inventoryItems then
        for _, item in pairs(inventoryItems) do
            if shopData.items[item.name] then
                local amount = item.count or item.amount or 0
                if amount > 0 then
                    local itemPrice = 0
                    local priceData = shopData.items[item.name].price
                    
                    if type(priceData) == 'table' then
                        itemPrice = math.random(priceData.min, priceData.max)
                    else
                        itemPrice = priceData
                    end
                    
                    price = price + (itemPrice * amount)
                    Inventory.RemoveItem(src, item.name, amount)
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

        addCash(src, playerMoney)
        notifyPlayer(src, 'Success', "You sold everything for $" .. playerMoney, 'success')
    else
        notifyPlayer(src, 'Error', "You have nothing to sell!", 'error')
    end
end)

local function sellSpecificItem(src, itemName, label, shopId)
    local shopData = Config.Shops[shopId]
    if not shopData or not shopData.items[itemName] then return end

    local count = (Inventory.GetItemCount and Inventory.GetItemCount(src, itemName)) or 0
    if count > 0 then
        local priceData = shopData.items[itemName].price
        local singlePrice = 0
        
        if type(priceData) == 'table' then
            singlePrice = math.random(priceData.min, priceData.max)
        else
            singlePrice = priceData
        end
        
        local price = singlePrice * count
        if Inventory.RemoveItem(src, itemName, count) then
            local playerMoney = price
            
            -- Handle Society Funds
            if shopData.society and shopData.society.enabled then
                local societyAmount = math.floor(price * (shopData.society.percent / 100))
                if societyAmount > 0 then
                    AddSocietyMoney(shopData.society.account, societyAmount)
                    playerMoney = price - societyAmount
                end
            end

            addCash(src, playerMoney)
            notifyPlayer(src, 'Success', "You sold your " .. label .. " for $" .. playerMoney, 'success')
        end
    else
        notifyPlayer(src, 'Error', "You don't have " .. label .. " to sell", 'error')
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
