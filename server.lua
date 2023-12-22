local QBCore = exports['qb-core']:GetCoreObject()
local Requests = {}
QBCore.Commands.Add("help", "Get help with Setup/View Commands/HotKeys", {}, false, function(source, args)
    TriggerClientEvent('qb-help:client:help', source, QBCore.Functions.HasPermission(source, 'admin'))
end)

QBCore.Functions.CreateCallback('qb-help:server:getPlayerRequests', function(source, cb)	
    local plicense = QBCore.Functions.GetIdentifier(source, 'license')
    local result = MySQL.Sync.fetchAll('SELECT * FROM feature_requests WHERE license=? ORDER BY last_updated desc', {plicense})    
	cb(result or {})
end)

QBCore.Functions.CreateCallback('qb-help:server:getAllRequests', function(source, cb)	
    if not QBCore.Functions.HasPermission(source, 'admin') then
        cb({})
        return
    end
    local result = MySQL.Sync.fetchAll('SELECT * FROM feature_requests ORDER BY last_updated desc', {})    
	cb(result or {})
end)

local function GetDiscordName(src)
    return exports['Badger_Discord_API']:GetDiscordName(src)
end

RegisterNetEvent('qb-help:server:submitRequest', function(requestData)
	local src = source
    local plicense = QBCore.Functions.GetIdentifier(src, 'license')
    local PlayerData = QBCore.Functions.GetPlayer(src).PlayerData
    local fullname = PlayerData.charinfo.firstname.." "..PlayerData.charinfo.lastname
    local discordName = GetDiscordName(src) or fullname
    MySQL.Async.insert('INSERT INTO feature_requests (license, discord, type, contact, summary, information) VALUES (?, ?, ?, ?, ?, ?)', {plicense, discordName, requestData.type or 'F', requestData.contact, requestData.summary, requestData.information}, function(rows)
        local result = MySQL.single.await('SELECT * FROM feature_requests WHERE license=? AND type=? AND summary=? ORDER BY last_updated desc LIMIT 1', {plicense, requestData.type, requestData.summary})    
        if result then
            DiscordLog('Submit', 'gold', discordName, requestData, false, result.id)
        end
    end)
    TriggerClientEvent('QBCore:Notify', src, 'Your feature request has been submitted.')

end)

RegisterNetEvent('qb-help:server:approveRequest', function(data)
	local src = source
    local hasPermAdmin = QBCore.Functions.HasPermission(src, 'admin')
    if not hasPermAdmin then
        return
    end
    local PlayerData = QBCore.Functions.GetPlayer(src).PlayerData
    local fullname = PlayerData.charinfo.firstname.." "..PlayerData.charinfo.lastname
    local discordName = GetDiscordName(src) or fullname
    UpdateRequest(discordName, 'Approved', data.response_reason, data.id)
end)

RegisterNetEvent('qb-help:server:denyRequest', function(data)
	local src = source
    local hasPermAdmin = QBCore.Functions.HasPermission(src, 'admin')
    if not hasPermAdmin then
        return
    end
    local PlayerData = QBCore.Functions.GetPlayer(src).PlayerData
    local fullname = PlayerData.charinfo.firstname.." "..PlayerData.charinfo.lastname
    local discordName = GetDiscordName(src) or fullname
    UpdateRequest(discordName, 'Denied', data.response_reason, data.id)
end)

function UpdateRequest(contact, value, reason, id)
    MySQL.Async.execute('UPDATE feature_requests SET response_contact = ?, response_value = ?, response_reason = ? WHERE id=? ', {contact, value, reason, id}, function(updated)
        local result = MySQL.Sync.fetchAll('SELECT * FROM feature_requests WHERE id=?', {id})    
        if result[1] then
            DiscordLog(value, value == 'Denied' and 'red' or 'green', contact, result[1], true)
            local responsePlayer = QBCore.Functions.GetPlayer(result[1]['license'])
            if responsePlayer then
			    TriggerClientEvent('QBCore:Notify', responsePlayer.PlayerData.source, 'Your feature request has been responded to.')                
            end
        end
    end)
end

function DiscordLog(type, color, name, data, update, id)
    local header = ''
    if id then
        header = header.."(ID: "..id..") "
    end
    header = header..'('..data.type..') '..data.summary
    local message = '** Discord: ' .. (update and data.discord or name) .. '** Contact Name('..data.contact..') Information: '..data.information..''
    if update then        
        message = message..' ** Response Contact: '..name..' ** Response Notes: '..data.response_reason..''
    end
    TriggerEvent('qb-log:server:CreateLog', 'request'..type, header, color or 'gold', message)
end


RegisterCommand('approver', function(source, args, rawCommand)
    --1: id 2: contact 3: message
    if args[1] and args[2] and args[3] and args[4] then
        local id = tonumber(args[1])
        local contact = args[2]
        table.remove(args, 2)
        table.remove(args, 1)
        local msg = table.concat(args, ' ')
        UpdateRequest(contact, 'Approved', msg, id)
        print('Updated Request')
    else
        print('Missing args')
    end
end, true)

RegisterCommand('denyr', function(source, args, rawCommand)
    --1: id 2: contact 3: message
    if args[1] and args[2] and args[3] and args[4] then
        local id = tonumber(args[1])
        local contact = args[2]
        table.remove(args, 2)
        table.remove(args, 1)
        local msg = table.concat(args, ' ')
        UpdateRequest(contact, 'Denied', msg, id)
        print('Updated Request')
    else
        print('Missing args')
    end
end, true)
