ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('menu:checkItem', function(source, cb, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    local items = xPlayer.getInventoryItem(item)
    if items ~= nil then
    	if tonumber(items.count) > 0 then
    		print(true)
    		cb(true)
    	else
    		cb(false)
    	end
    else
    	cb(false)
    end
end)

ESX.RegisterServerCallback('menu:checkMoney', function(source, cb, count)
    local xPlayer = ESX.GetPlayerFromId(source)
    local money = xPlayer.getMoney()
    if money ~= nil then
        if money > count then
            xPlayer.removeMoney(count)
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)


RegisterServerEvent('menu:drag')
AddEventHandler('menu:drag', function(closestPlayer)
	TriggerClientEvent('menu:client:drag', closestPlayer, source)
end)

RegisterNetEvent('vehicle:flipit')
AddEventHandler('vehicle:flipit', function()
	TriggerClientEvent('vehicle:flipit')
end)
