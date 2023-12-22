local IsNew = false
local QBCore = exports['qb-core']:GetCoreObject()

local ShowHelpMenu = function(enable, isAdmin)
	if (isAdmin == nil) then
		isAdmin = false
	end
    SetNuiFocus(enable, enable)
	SendNUIMessage({
		action = "open",
		open = enable,
		isAdmin = isAdmin
	})    
end
RegisterNetEvent('surreal-helpmenu:client:help', function(isAdmin)
	ShowHelpMenu(true, isAdmin)	
end)

-- this can be added to new character creation if you want to force to show the help menu on first creation
RegisterNetEvent('surreal-helpmenu:client:NewCharacter', function()
	IsNew = true
	ShowHelpMenu(true)	
end)

RegisterNUICallback('close', function(data, cb)
    ShowHelpMenu(false)
    cb(true)
	if IsNew then
		-- If created character continue with any events that should trigger after help menu is closed
		IsNew = false
		TriggerEvent('qb-clothes:client:CreateFirstCharacter')
	end
end)

RegisterNUICallback('denyRequest', function(data, cb)
	TriggerServerEvent('surreal-helpmenu:server:denyRequest', data)
	cb('ok')
end)
RegisterNUICallback('approveRequest', function(data, cb)
	TriggerServerEvent('surreal-helpmenu:server:approveRequest', data)
	cb('ok')
end)
RegisterNUICallback('submitRequest', function(data, cb)
	TriggerServerEvent('surreal-helpmenu:server:submitRequest', data)
	cb('ok')
end)

RegisterNUICallback('playerRequests', function(data, cb)
	QBCore.Functions.TriggerCallback('surreal-helpmenu:server:getPlayerRequests', function(list)	
		cb(list)
	end)
end)
RegisterNUICallback('adminRequests', function(data, cb)
	QBCore.Functions.TriggerCallback('surreal-helpmenu:server:getAllRequests', function(list)	
		cb(list)
	end)
end)