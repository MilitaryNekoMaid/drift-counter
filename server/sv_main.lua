TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('drift-counter:finished')
AddEventHandler('drift-counter:finished', function(data)
	if Config.Payout.Enable then
		payout(data.score)
	end

	if Config.Logging.Enable then
		log(data.score, data.vehicle)
	end
end)

function payout(score)
	local xPlayer = ESX.GetPlayerFromId(source)
	local money = math.floor(score/Config.Payout.Divider)

	xPlayer.addMoney(money)

	if Config.Notification.Enable then
		TriggerClientEvent('drift-counter:notify', source, (Config.Notification.Message):format(ESX.Math.GroupDigits(money)))
	end
end

function log(score, vehicle)
	local ids = getIdentifiers(source)
	local money = math.floor(score/Config.Payout.Divider)

	local player = "**Player:** "..GetPlayerName(source).." ("..source..")"

	if ids.discord then
		discord = "\n**Discord:** <@" ..ids.discord:gsub("discord:", "").."> ("..ids.discord:gsub("discord:", "")..")"
	else
		discord = "\n**Discord:** N/A (N/A)"
	end

	if ids.license then
		license = "\n**License:** "..ids.license:gsub("license:", "")
	else
		license = "\n**License:** N/A"
	end
	
	if ids.steam then
		steam = "\n**Steam:** https://steamcommunity.com/profiles/"..tonumber(ids.steam:gsub("steam:", ""), 16)
		hex = "\n**HEX:** "..ids.steam:gsub("steam:", "")
	else
		steam = "\n**Steam:** N/A"
		hex = "\n**HEX:** N/A"
	end

	local identifiers = player..discord..license..steam..hex
	local message = "**Score:** "..ESX.Math.GroupDigits(score).."\n**Payout:** $"..ESX.Math.GroupDigits(money).."\n**SPZ:** "..vehicle.plate..""

	local embed = {{
		["color"] = "11480319",
		["author"] = {
			["name"] = "Drift Counter",
		},
		["description"] = identifiers.."\n\n"..message.."\n\n**Timestamp:** <t:"..math.floor(tonumber(os.time()))..":R>",
		["footer"] = {
			["text"] = "Made by cryptixik • "..os.date('%H:%M:%S - %d.%m.%Y', os.time()),
		},
	}}

	PerformHttpRequest(Config.Logging.Webhook, function(err, text, headers) end, 'POST', json.encode({username = "Drift Counter", embeds = embed}), { ['Content-Type'] = 'application/json' }) 
end

function getIdentifiers(src)
	local identifiers = {}

	for i = 0, GetNumPlayerIdentifiers(src) - 1 do
		local id = GetPlayerIdentifier(src, i)

		if string.find(id, "steam:") then
			identifiers['steam'] = id
		elseif string.find(id, "ip:") then
			identifiers['ip'] = id
		elseif string.find(id, "discord:") then
			identifiers['discord'] = id
		elseif string.find(id, "license:") then
			identifiers['license'] = id
		elseif string.find(id, "license2:") then
			identifiers['license2'] = id
		elseif string.find(id, "xbl:") then
			identifiers['xbl'] = id
		elseif string.find(id, "live:") then
			identifiers['live'] = id
		elseif string.find(id, "fivem:") then
			identifiers['fivem'] = id
		end
	end

	return identifiers
end

Citizen.CreateThread(function()
	PerformHttpRequest("https://raw.githubusercontent.com/cryptixik/drift-counter/master/version", check, "GET")
	function check(error, response, headers)
		local current = LoadResourceFile(GetCurrentResourceName(), "version")
		if current ~= response and tonumber(current) < tonumber(response) then
			print("^1Drift Counter is outdated, you are currently using version "..current.." please update to newest version: "..response..".")
			print("^1You can update here: https://github.com/cryptixik/drift-counter.")
		end
	end
end)
