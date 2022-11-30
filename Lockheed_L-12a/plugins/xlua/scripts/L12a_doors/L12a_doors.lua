--[[
Door and ladder control script for the Lockheed L12a
by S. Baugh
mod by BK
]]
--[[

X-PLANE DATAREFS

]]
simDR_start_running = find_dataref("sim/operation/prefs/startup_running")
simDR_left_eng_running = find_dataref("sim/flightmodel/engine/ENGN_running[0]")
simDR_right_eng_running = find_dataref("sim/flightmodel/engine/ENGN_running[1]")

simDR_nose_light = find_dataref("sim/cockpit2/switches/taxi_light_on")
simDR_main_door = find_dataref("sim/flightmodel2/misc/door_open_ratio[0]")	-- needed for timing with ladder
--[[

X-PLANE COMMANDS

]]
simCMD_open_door01 = find_command("sim/flight_controls/door_open_1")
simCMD_open_door02 = find_command("sim/flight_controls/door_open_2")
simCMD_open_door03 = find_command("sim/flight_controls/door_open_3")

simCMD_close_door01 = find_command("sim/flight_controls/door_close_1")
simCMD_close_door02 = find_command("sim/flight_controls/door_close_2")
simCMD_close_door03 = find_command("sim/flight_controls/door_close_3")
--[[

CUSTOM DATAREFS

]]
myDR_stow_ladder = create_dataref("lockheed/L12a/ladder_stow","number") -- 0.0=deployed, 1.0 = stowed

function fake_handler() -- Usage of a handler, even if fake, makes custom datarefs writable
end
myDR_main_door_switch = create_dataref("lockheed/L12a/main_door_switch","number",fake_handler)
myDR_baggage_doors_switch = create_dataref("lockheed/L12a/baggage_doors_switch","number",fake_handler)
--[[

VARIABLES

]]
local ladder_new
local door_speed
local doors_flag = 0	-- prevents loop when engines off
--[[

FUNCTIONS

]]
--[[ Handler for playing animations ]]
function func_animation_handler(new_value, anim_value, anim_speed)
	anim_value = anim_value + ((new_value - anim_value) * (anim_speed * SIM_PERIOD))
	return anim_value
end
--[[

COMMAND CALLBACKS

]]
function cmd_main_door_open(phase, duration)
	if phase == 0 then
		ladder_new = 0.0
		door_speed = 3
		simCMD_open_door01:once()
		myDR_main_door_switch = 1.0		
	end
end

function cmd_main_door_close(phase, duration)
	if phase == 0 then
		ladder_new = 1.0
		door_speed = 5
		simCMD_close_door01:once()
		myDR_main_door_switch = 0.0
	end
end

function cmd_bag_doors_open(phase, duration)
	if phase == 0 then
		simCMD_open_door02:once()
		if simDR_nose_light == 0 then			-- nose light has to be off to open nose door
			simCMD_open_door03:once()
		end
		myDR_baggage_doors_switch = 1.0
	end
end

function cmd_bag_doors_close(phase, duration)
	if phase == 0 then
		simCMD_close_door02:once()
		simCMD_close_door03:once()
		myDR_baggage_doors_switch = 0.0
	end
end

-- NEW

function cmd_main_door_toggle(phase, duration)
	if phase == 0 then
        if myDR_main_door_switch == 0 then
            ladder_new = 0.0
            door_speed = 3
            simCMD_open_door01:once()
            myDR_main_door_switch = 1.0
        else
            ladder_new = 1.0
            door_speed = 5
            simCMD_close_door01:once()
            myDR_main_door_switch = 0.0
        end
	end
end

function cmd_bag_doors_toggle(phase, duration)
	if phase == 0 then
        if myDR_baggage_doors_switch == 0 then
            simCMD_open_door02:once()
            if simDR_nose_light == 0 then			-- nose light has to be off to open nose door
                simCMD_open_door03:once()
            end
            myDR_baggage_doors_switch = 1.0
        else
            simCMD_close_door02:once()
            simCMD_close_door03:once()
            myDR_baggage_doors_switch = 0.0
        end
	end
end
--[[

CUSTOM COMMANDS

]]
cmdmaindropn = create_command("lockheed/L12a/main_door_open","Main Door Open", cmd_main_door_open)
cmdmaindrcls = create_command("lockheed/L12a/main_door_close","Main Door Close", cmd_main_door_close)

cmdbagdropn = create_command("lockheed/L12a/baggage_doors_open","Baggage Door Open",cmd_bag_doors_open)
cmdbagdrcls = create_command("lockheed/L12a/baggage_doors_close","Baggage Door Close",cmd_bag_doors_close)

-- NEW
cmdmaindrtog = create_command("lockheed/L12a/main_door_toggle","Main Door Toogle", cmd_main_door_toggle)
cmdbagdrtog = create_command("lockheed/L12a/baggage_doors_toggle","Baggage Door Toggle",cmd_bag_doors_toggle)
--[[

RUNTIME INTEGRATION

]]
--[[ Runs at X-Plane session start or aircraft load ]]
function flight_start()

	if simDR_start_running == 1 then
		myDR_main_door_switch = 0.0
		myDR_baggage_doors_switch = 0.0
		myDR_stow_ladder = 1.0
	else
		simCMD_open_door01:once()
		myDR_main_door_switch = 1.0
		simDR_main_door = 1.0
		myDR_stow_ladder = 0.0
		ladder_new = 0.0
		simCMD_open_door02:once()
		simDR_nose_light = 0
		simCMD_open_door03:once()
		myDR_baggage_doors_switch = 1.0
	end
	
end
--[[ Runs during X-Plane session ]]
function after_physics()

	if ladder_new ~= myDR_stow_ladder then
		if simDR_main_door >= 0.5 then
			myDR_stow_ladder = func_animation_handler(ladder_new, myDR_stow_ladder, door_speed)
		elseif simDR_main_door == 0.0 then
			myDR_stow_ladder = 1.0
		end
	end
	
end

