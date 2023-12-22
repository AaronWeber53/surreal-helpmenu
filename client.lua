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
RegisterNetEvent('qb-help:client:help', function(isAdmin)
	ShowHelpMenu(true, isAdmin)	
end)

RegisterNetEvent('qb-help:client:NewCharacter', function()
	IsNew = true
	ShowHelpMenu(true)	
end)

RegisterNUICallback('close', function(data, cb)
    ShowHelpMenu(false)
    cb(true)
	if IsNew then
		IsNew = false
		TriggerEvent('qb-clothes:client:CreateFirstCharacter')
	end
end)

RegisterNUICallback('denyRequest', function(data, cb)
	TriggerServerEvent('qb-help:server:denyRequest', data)
	cb('ok')
end)
RegisterNUICallback('approveRequest', function(data, cb)
	TriggerServerEvent('qb-help:server:approveRequest', data)
	cb('ok')
end)
RegisterNUICallback('submitRequest', function(data, cb)
	TriggerServerEvent('qb-help:server:submitRequest', data)
	cb('ok')
end)

RegisterNUICallback('playerRequests', function(data, cb)
	QBCore.Functions.TriggerCallback('qb-help:server:getPlayerRequests', function(list)	
		cb(list)
	end)
end)
RegisterNUICallback('adminRequests', function(data, cb)
	QBCore.Functions.TriggerCallback('qb-help:server:getAllRequests', function(list)	
		cb(list)
	end)
end)