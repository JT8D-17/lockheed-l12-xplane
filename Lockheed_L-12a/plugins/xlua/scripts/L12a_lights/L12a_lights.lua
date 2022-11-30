--[[
Light control script for the Lockheed L12a
by S. Baugh
mod by BK
]]
--[[

X-PLANE DATAREFS

]]
simDR_start_running = find_dataref("sim/operation/prefs/startup_running") -- Is aircraft initialized with engines running?
simDR_auto_start = find_dataref("sim/flightmodel2/misc/auto_start_in_progress") -- Is autostart event happening?
simDR_panel_light_left = find_dataref("sim/cockpit2/switches/panel_brightness_ratio[1]")	-- simply to turn off unless dark
simDR_panel_light_right = find_dataref("sim/cockpit2/switches/panel_brightness_ratio[2]")
simDR_local_time = find_dataref("sim/cockpit2/clock_timer/local_time_hours")
simDR_nose_door_status = find_dataref("sim/flightmodel2/misc/door_open_ratio[2]")
simDR_cabin_lights = find_dataref("sim/cockpit2/switches/generic_lights_switch[1]")
simDR_LL_deploy_left = find_dataref("sim/flightmodel2/misc/custom_slider_ratio[22]") -- Time controlled in PlaneMaker
simDR_LL_deploy_right = find_dataref("sim/flightmodel2/misc/custom_slider_ratio[23]") -- Time controlled in PlaneMaker
simDR_LL_switch = find_dataref("sim/cockpit2/switches/landing_lights_switch") -- Landing lights switch
simDR_TL_switch = find_dataref("sim/cockpit2/switches/taxi_light_on") -- Taxi lights switch


simDR_main_door_status = find_dataref("sim/flightmodel2/misc/door_open_ratio[0]")
simDR_bag_door_status = find_dataref("sim/flightmodel2/misc/door_open_ratio[1]")


--[[

FUNCTIONS


]]
function fake_handler() end -- Usage of a handler, even if fake, makes custom datarefs writable
--[[

CUSTOM DATAREFS

]]
myDR_LL_switch = create_dataref("lockheed/L12a/lights/landing_lights_switch","number",fake_handler)
myDR_NL_switch = create_dataref("lockheed/L12a/lights/nose_lights_switch","number",fake_handler)
myDR_cabin_light_switch = create_dataref("lockheed/L12a/lights/cabin_lights","number",fake_handler)

myDR_door_light_on = create_dataref("lockheed/L12a/door_light","number")
--[[

VARIABLES

]]
local CL_state = 0.0		-- Cabin light state: 0.0=off, 0.50=half on, 1.0=full on
--[[

RUNTIME INTEGRATION

]]
--[[ Runs at X-Plane session start or aircraft load ]]
function flight_start()
	if simDR_local_time >= 20 or simDR_local_time <= 7 then
		simDR_panel_light_left = 0.9
		simDR_panel_light_right = 0.9
	else
		simDR_panel_light_left = 0.0
		simDR_panel_light_right = 0.0
	end
	
	if simDR_main_door_status == 1 or simDR_bag_door_status == 1 or simDR_nose_door_status == 1 then
		myDR_door_light_on = 1
	else
		myDR_door_light_on = 0
	end
end
--[[ Runs during X-Plane session ]]
function after_physics()
    --[[ Landing lights logic ]]
    if myDR_LL_switch == 1 then
        if simDR_LL_deploy_left > 0.9 and simDR_LL_switch[0] ~= 1 then simDR_LL_switch[0] = 1 end
        if simDR_LL_deploy_left < 0.9 and simDR_LL_switch[0] ~= 0 then simDR_LL_switch[0] = 0 end
        if simDR_LL_deploy_right > 0.9 and simDR_LL_switch[1] ~= 1 then simDR_LL_switch[1] = 1 end
        if simDR_LL_deploy_right < 0.9 and simDR_LL_switch[1] ~= 0 then simDR_LL_switch[1] = 0 end
    else
        if simDR_LL_switch[0] ~= 0 then simDR_LL_switch[0] = 0 end
        if simDR_LL_switch[1] ~= 0 then simDR_LL_switch[1] = 0 end
    end
    --[[ Taxi light logic ]]
    if myDR_NL_switch == 1 and simDR_nose_door_status == 0 then if simDR_TL_switch ~= 1 then simDR_TL_switch = 1 end
    else if simDR_TL_switch ~= 0 then simDR_TL_switch = 0 end end
    --[[ Cabin light logic ]]
	if myDR_cabin_light_switch == 1 and simDR_cabin_lights ~= 1 then simDR_cabin_lights = 1 end
	if myDR_cabin_light_switch == 0 and simDR_cabin_lights ~= 0 then simDR_cabin_lights = 0 end

	if simDR_main_door_status == 1 or simDR_bag_door_status == 1 or simDR_nose_door_status == 1 then
		myDR_door_light_on = 1
	else
		myDR_door_light_on = 0
	end
	
end
