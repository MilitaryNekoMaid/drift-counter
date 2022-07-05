local screen = 0
local score = 0
local alpha = 0

Citizen.CreateThread(function()
	ESX = nil
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local playerPed = PlayerPedId()
		local usedVehicle = GetVehiclePedIsUsing(playerPed)

		if usedVehicle and GetPedInVehicleSeat(usedVehicle, -1) == playerPed and IsVehicleOnAllWheels(usedVehicle) and not IsPedInFlyingVehicle(playerPed) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)
			local angle, velocity = angle(vehicle)
			local tick = GetGameTimer()
			local bool = tick - (idleTime or 0) < 1850

			if not bool and score ~= 0 then
				local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
				score = ESX.Math.Round(score)

				trigger('drift-counter:finished', score, vehicleProps)

				score = 0
			end

			if angle ~= 0 then
				if bool then
					score = score + math.floor(angle * velocity) * 0.1
				else
					score = math.floor(angle * velocity) * 0.1
				end

				screen = ESX.Math.Round(score)
				idleTime = tick
			end

			if tick - (idleTime or 0) < 3000 then
				if alpha < 255 and alpha + 10 < 255 then
					alpha = alpha + 10
				elseif alpha > 255 then
					alpha = 255
				elseif alpha == 255 then
					alpha = 255
				elseif alpha == 250 then
					alpha = 255
				end
			else
				if alpha > 0 and alpha - 10 > 0 then
					alpha = alpha - 10
				elseif alpha < 0 then
					alpha = 0
				elseif alpha == 10 then
					alpha = 0
				end
			end
		end

		if not screen then screen = 0 end
		if alpha > 0 and screen ~= 0 then
			hud(("%s"):format(screen), {200, 200, 200, alpha}, 0.50, 0.88, 1.3)
			hud("SCORE", {5, 85, 255, alpha}, 0.45, 0.90, 0.9)
		end
	end
end)

function angle(vehicle)
	if not vehicle then return false end

	local vx, vy, vz = table.unpack(GetEntityVelocity(vehicle))
	local velocity = math.sqrt(vx * vx + vy * vy)
	local rx, ry, rz = table.unpack(GetEntityRotation(vehicle,0))
	local sn, cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))

	if GetEntitySpeed(vehicle) * 3.6 < 30 or GetVehicleCurrentGear(vehicle) == 0 then return 0, velocity end

	local cos = (sn * vx + cs * vy) / velocity

	if cos > 0.966 or cos < 0 then return 0, velocity end
	return math.deg(math.acos(cos)) * 0.5, velocity
end

function hud(text, colour, coordsx, coordsy, scale)
	local colourr, colourg, colourb, coloura = table.unpack(colour)

	SetTextFont(4)
	SetTextScale(scale, scale)
	SetTextColour(colourr, colourg, colourb, coloura)

	SetTextEntry("STRING")
	AddTextComponentString(text)
	EndTextCommandDisplayText(coordsx, coordsy)
end

function trigger(event, score, vehicleProps)
	local data = {score = score, vehicle = vehicleProps}
	TriggerServerEvent(event, data)
end

RegisterNetEvent('drift-counter:notify')
AddEventHandler('drift-counter:notify', function(message)
	ESX.ShowNotification(message)
end)