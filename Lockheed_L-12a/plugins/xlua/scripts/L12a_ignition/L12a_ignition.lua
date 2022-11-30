--[[
Ignition code for the Lockheed L12a
by S. Baugh
mod by BK
]]
--[[

X-PLANE DATAREFS

]]
simDR_running = find_dataref("sim/operation/prefs/startup_running")
simDR_ignition_left = find_dataref("sim/cockpit2/engine/actuators/ignition_on[0]")
simDR_ignition_right = find_dataref("sim/cockpit2/engine/actuators/ignition_on[1]")
--[[

CUSTOM DATAREFS

]]
function fake_handler() end -- Usage of a handler, even if fake, makes custom datarefs writable
left_knob_angle = create_dataref("lockheed/L12a/ignition_left","number",fake_handler) --		0 - OFF  1 - L	  2 - R	   3 - BOTH
right_knob_angle = create_dataref("lockheed/L12a/ignition_right","number",fake_handler) --		0 - OFF  1 - L	  2 - R	   3 - BOTH
magneto_knob = create_dataref("lockheed/L12a/magneto_lock","number",fake_handler) -- 0 = magnetos OFF and grounded, 1 = ON and active
--[[

COMMAND CALLBACKS

]]
function cmd_magnetos_locked(phase, duration)
 	if phase == 0 then
 		magneto_knob = 0			-- Pull knob OUT to turn OFF ignition and ground mags
		simDR_ignition_left = 0		-- And move ignition knobs to OFF
		left_knob_angle = 0
		simDR_ignition_right = 0
		right_knob_angle = -105
	end
end

function cmd_magnetos_unlocked(phase, duration)
	if phase == 0 then
		magneto_knob = 1		-- Push knob IN to unlock ignition
	end
end

function cmd_left_ignition_select_cw(phase, duration)
	if phase == 0 then
        if left_knob_angle < 105 then left_knob_angle = left_knob_angle + 35 end
	end
end

function cmd_left_ignition_select_ccw(phase, duration)
	if phase == 0 then
		if left_knob_angle > 0 then left_knob_angle = left_knob_angle - 35 end
	end
end

function cmd_right_ignition_select_cw(phase, duration)
	if phase == 0 then
		if right_knob_angle < 0 then right_knob_angle = right_knob_angle + 35 end
	end
end

function cmd_right_ignition_select_ccw(phase, duration)
	if phase == 0 then
		if right_knob_angle > -105 then right_knob_angle = right_knob_angle - 35 end
	end
end

function cmd_magneto_master_toggle(phase,duration)
 	if phase == 0 then
 		if magneto_knob == 0 then
            magneto_knob = 1
 		else
            magneto_knob = 0			-- Pull knob OUT to turn OFF ignition and ground mags
            simDR_ignition_left = 0		-- And move ignition knobs to OFF
            simDR_ignition_right = 0
 		end
		--left_knob_angle = 0

		--right_knob_angle = -105
	end
end
--[[

CUSTOM COMMANDS

]]
maglockon = create_command("lockheed/L12a/mags_grounded","Main Ignition Switch",cmd_magnetos_locked)
maglockoff = create_command("lockheed/L12a/mags_active","Main Ignition Switch",cmd_magnetos_unlocked)
maglocktoggle = create_command("lockheed/L12a/magneto_master_toggle","Main Ignition Switch Toggle",cmd_magneto_master_toggle)

cmdlignselcw = create_command("lockheed/L12a/left_ignition_selector_cw","Magneto Switch Left CW",cmd_left_ignition_select_cw)
cmdlmagscw = replace_command("sim/magnetos/magnetos_up_1",cmd_left_ignition_select_cw)
cmdlignselccw = create_command("lockheed/L12a/left_ignition_selector_ccw","Magneto Switch Left CCW",cmd_left_ignition_select_ccw)
cmdlmagsccw = replace_command("sim/magnetos/magnetos_down_1",cmd_left_ignition_select_ccw)
cmdrignselcw = create_command("lockheed/L12a/right_ignition_selector_cw","Magneto Switch Right CW",cmd_right_ignition_select_cw)
cmdrmagscw = replace_command("sim/magnetos/magnetos_up_2",cmd_right_ignition_select_cw)
cmdrignselccw = create_command("lockheed/L12a/right_ignition_selector_ccw","Magneto Switch Right CCW",cmd_right_ignition_select_ccw)
cmdrmagsccw = replace_command("sim/magnetos/magnetos_down_2",cmd_right_ignition_select_ccw)
--[[

RUNTIME INTEGRATION

]]
--[[ Runs at X-Plane session start or aircraft load ]]
function flight_start()
	if simDR_running == 1 then
		magneto_knob = 1			-- Engine is running, magneto_knob is ON
		simDR_ignition_left = 3		-- Left selector on BOTH
		left_knob_angle = 105
		simDR_ignition_right = 3	-- Right selector on BOTH
		right_knob_angle = 0
	else
		magneto_knob = 0			-- else magnetos are OFF and both left and right knobs OFF
		simDR_ignition_left = 0
		left_knob_angle = 0
		simDR_ignition_right = 0
		right_knob_angle = -105
	end
end
--[[ Runs during X-Plane session ]]
function after_physics()
    if magneto_knob == 1 then
        if left_knob_angle == 0 and simDR_ignition_left ~= 0 then simDR_ignition_left = 0 end
        if left_knob_angle == 35 and simDR_ignition_left ~= 2 then simDR_ignition_left = 2 end
        if left_knob_angle == 70 and simDR_ignition_left ~= 1 then simDR_ignition_left = 1 end
        if left_knob_angle == 105 and simDR_ignition_left ~= 3 then simDR_ignition_left = 3 end
        if right_knob_angle == -105 and simDR_ignition_right ~= 0 then simDR_ignition_right = 0 end
        if right_knob_angle == -70 and simDR_ignition_right ~= 2 then simDR_ignition_right = 2 end
        if right_knob_angle == -35 and simDR_ignition_right ~= 1 then simDR_ignition_right = 1 end
        if right_knob_angle == 0 and simDR_ignition_right ~= 3 then simDR_ignition_right = 3 end
    else
        if simDR_ignition_left ~= 0 then simDR_ignition_left = 0 end
        if simDR_ignition_right ~= 0 then simDR_ignition_right = 0 end
    end
end
