--[[
Collection of system routines for Lockheed L-12a
by S. Baugh
mod by BK
]]
--[[

X-PLANE DATAREFS

]]
simDR_running = find_dataref("sim/operation/prefs/startup_running")
simDR_avion = find_dataref("sim/cockpit2/switches/avionics_power_on")
simDR_batt01 = find_dataref("sim/cockpit2/electrical/battery_on[0]")
simDR_batt02 = find_dataref("sim/cockpit2/electrical/battery_on[1]")
simDR_inverter = find_dataref("sim/cockpit2/electrical/inverter_on[0]")
simDR_crosstie = find_dataref("sim/cockpit2/electrical/cross_tie")
simDR_tailwheel_lock = find_dataref("sim/operation/override/override_wheel_steer")
simDR_vacuum_pump_left = find_dataref("sim/operation/failures/rel_vacuum")
simDR_vacuum_pump_right = find_dataref("sim/operation/failures/rel_vacuum2")
--[[

CUSTOM DATAREFS

]]
function fake_handler() end -- Usage of a handler, even if fake, makes custom datarefs writable
myDR_master_switch_state = create_dataref("lockheed/L12a/master_switch","number",fake_handler)
myDR_vacuum_knob = create_dataref("lockheed/L12a/vacuum_selector","number",fake_handler)
myDR_config_hide_pilot = create_dataref("lockheed/L12a/hide_pilot","number",fake_handler)
--[[

VARIABLES

]]
local vac_pump = 0
--[[

FUNCTIONS

]]
function func_animation_handler(new_value, anim_value, anim_speed)
	anim_value = anim_value + ((new_value - anim_value) * (anim_speed * SIM_PERIOD))
	return anim_value
end
--[[

COMMAND CALLBACKS

]]
function cmd_master_toggle(phase, duration)
	if phase == 0 then
        if myDR_master_switch_state == 0 then myDR_master_switch_state = 1 else myDR_master_switch_state = 0 end -- signals knob				
	end
end

function cmd_tw_toggle(phase, duration)
	if phase == 0 then
		if simDR_tailwheel_lock == 0 then							-- local var used for animation below
			simDR_tailwheel_lock = 1
		else
			simDR_tailwheel_lock = 0
		end
	end
end

function cmd_vac_pump_togg(phase, duration)
	if phase == 0 then
		if myDR_vacuum_knob == 0 then				-- move to left pump on, right off
			myDR_vacuum_knob = 1

		else
			myDR_vacuum_knob = 0					-- else move to right pump on, left off
		end
	end
end
--[[

CUSTOM COMMANDS

]]
L12aMasterSwitchToggle = replace_command("sim/electrical/batteries_toggle",cmd_master_toggle)
L12atailwheeltoggle = replace_command("sim/flight_controls/tail_wheel_lock_toggle",cmd_tw_toggle)
L12avactogg = create_command("lockheed/L12a/vacuum_pump_toggle","Toggle Vacuum Pump",cmd_vac_pump_togg)
--[[

RUNTIME INTEGRATION

]]
--[[ Runs at X-Plane session start or aircraft load ]]
function flight_start()
	if simDR_running == 0 then		-- 0 = startup not running, 1 = running
		simDR_batt01 = 0
		simDR_batt02 = 0
		simDR_avion = 0
		simDR_inverter = 0
		myDR_master_switch_state = 0
		simDR_tailwheel_lock = 0
	else
		simDR_batt01 = 1
		simDR_batt02 = 1
		simDR_avion = 1
		simDR_inverter = 1
		myDR_master_switch_state = 1
		simDR_tailwheel_lock = 1
	end
	
	myDR_vacuum_knob = 0
	
end
--[[ Runs during X-Plane session ]]
function after_physics()
    -- Master switch
    if myDR_master_switch_state == 1 then
        if simDR_batt01 == 0 then simDR_batt01 = 1 end
        if simDR_batt02 == 0 then simDR_batt02 = 1 end
        if simDR_avion == 0 then simDR_avion = 1 end
        if simDR_inverter == 0 then simDR_inverter = 1 end
        if myDR_config_hide_pilot == 1 then myDR_config_hide_pilot = 0 end
    else
        if simDR_batt01 == 1 then simDR_batt01 = 0 end
        if simDR_batt02 == 1 then simDR_batt02 = 0 end
        if simDR_avion == 1 then simDR_avion = 0 end
        if simDR_inverter == 1 then simDR_inverter = 0 end
        if myDR_config_hide_pilot == 0 then myDR_config_hide_pilot = 1 end
    end
    -- Vacuum pump selector
	if vac_pump ~= myDR_vacuum_knob then							-- updates vacuum pump selector with vac_pump
		myDR_vacuum_knob = func_animation_handler(vac_pump,myDR_vacuum_knob,12)
	end
    if myDR_vacuum_knob == 0 then simDR_vacuum_pump_left = 0 simDR_vacuum_pump_right = 6 end		-- "6" turns off vacuum pump, 0 turns on
    if myDR_vacuum_knob == 1 then simDR_vacuum_pump_left = 6 simDR_vacuum_pump_right = 0 end		-- "6" turns off vacuum pump, 0 turns on
end
