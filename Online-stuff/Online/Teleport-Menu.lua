Settings = ac.storage({
	KeyValue = 999, --key value for ac
	KeyName = "", --key name for user
	TPtoCam = false,
	ShowKeyTP = false,
	tpDistance = 8,
	SpectatePlayer = false,
	MousetoTrackRays = false,
	MousetoTrackRays_updates = "500",
	MousetoTrackRays_Chord_keyValue = 999,
	MousetoTrackRays_Chord_KeyName = "",
	MousetoTrackRays_pos_keyValue = 999,
	MousetoTrackRays_pos_KeyName = "",
	MousetoTrackRays_dir_keyValue = 999,
	MousetoTrackRays_dir_KeyName = "",
	MousetoTrackRays_TP_keyValue = 999,
	MousetoTrackRays_TP_KeyName = "",
})

local timer = {
	running = 0,	--we move length/blength into here
	length = 0,		--the normal length after teleporting
	blength = 0.5,	--length after setting a button
}

--#region [Menu]
local function Teleportation()
	--showing timer seems logical to me here
	ui.text("Cooldown: " .. math.round(timer.running, 1))

	ui.tabBar("Atabbar", function()
		ui.tabItem("Teleport to player", CartoCar_UI)
	end)
end
--#endregion

--#region [Car to Car] --physics stuff works in ui shit too so lol
function CartoCar_UI()
	ui.text("Will teleport you ~8 Meters behind the selected car.")
	if ui.checkbox("Spectate Player on Click",Settings.SpectatePlayer) then Settings.SpectatePlayer = not Settings.SpectatePlayer end
	ui.text("Select car to teleport to:")
	ui.childWindow("##drivers", vec2(ui.availableSpaceX(), 120), function()
		for i = 1, sim.carsCount - 1 do
			local car = ac.getCar(i)
			local driverName = ac.getDriverName(i)
			if car.isConnected and not car.isAIControlled and not string.find(driverName, "tnhd.gg") then
				if ui.selectable(driverName, selectedCar == car) then
					selectedCar = car
					if Settings.SpectatePlayer == true then
						ac.focusCar(i)
					end
				end
				if ui.button("Teleport") and selectedCar and timer.running <= 0 then -- check if car selected/button pressed/timer above 0
					timer.running = timer.length
					local dir = selectedCar.look

                    local teleportee = ac.getCarVelocity(selectedCar)

					physics.setCarVelocity(0, teleportee) -- mirror velocity
					physics.setCarPosition(0, selectedCar.position + vec3(0, 0.1, 0) - dir * 10, -dir) -- spawn 8 meters behind, add 0.1 meter height to avoid falling through the map
				end
			end
		end
	end)
end
--#endregion



function script.update(dt)
	--#region [Timer]
	if timer.running >= 0 then -- timer for anything to go
		timer.running = timer.running - dt
	end
	--#endregion

	--#region[Functions]
	TPtoCam_Update()
	ToTrackWithRotation_Update()
	--#endregion
end

function script.drawUI()
	if OverlayTimerKey == true then
		ui.transparentWindow("Keyandabindandacooldown", vec2(-15, -5), vec2(150, 150), false, function()
			ui.text("Key: " .. Settings.KeyName .. "\nCooldown: " .. math.round(timer.running, 1))
		end)
	end
end

function script.draw3D()
	ToTrackWithRotation_draw3D()
	TPtoCam_draw3D()
end



ui.registerOnlineExtra(ui.Icons.Compass, "Teleport To Player", nil, Teleportation,nil, ui.OnlineExtraFlags.Tool, ui.WindowFlags.NoScrollWithMouse)