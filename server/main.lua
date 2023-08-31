if GetResourceState('es_extended') ~= 'started' then return end

ESX = nil

Citizen.CreateThread(function()
    local es_extended_version = GetResourceMetadata('es_extended', 'version', 0) or "unknown"

    print("Detected es_extended version: " .. es_extended_version)

    if es_extended_version == "1.2.0" then
        ESX = nil

        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        
        
    else
        ESX = exports["es_extended"]:getSharedObject()
    end
end)



RegisterNetEvent('zaps:moneywash')
AddEventHandler('zaps:moneywash', function(amount, playerCoords)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    -- Check for a valid amount
    if tonumber(amount) < 0 then return end

    -- Check if player has enough dirty money
    local dirtyMoney = xPlayer.getAccount('black_money').money
    if dirtyMoney < amount then
        TriggerClientEvent('esx:showNotification', _source, 'You do not have enough dirty money to wash.')
        return
    end

    local currentLocation = nil
    for _, loc in ipairs(Config.Locations) do
        local dist = #(playerCoords - vector3(loc.x, loc.y, loc.z))
        if dist < 5.0 then
            currentLocation = loc
            break
        end
    end

    if not currentLocation then
        return
    end

    local tax = tonumber(currentLocation.tax)
    local bidentax = (amount * tax) / 100
    local newAmount = amount - bidentax

    xPlayer.removeAccountMoney('black_money', amount)

    TriggerClientEvent('esx:showNotification', _source, 'You will receive in 30 seconds. $' .. tonumber(newAmount) .. ' clean money.')
    Citizen.Wait(30000) -- 30-second timer
    xPlayer.addMoney(newAmount)
end)
function startup()
    print("[Zaps] Join https://discord.gg/cfxdev | Version 1.0.0")
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        startup()
    end
end)
