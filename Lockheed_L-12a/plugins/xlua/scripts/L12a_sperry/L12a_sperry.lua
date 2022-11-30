-- ************************************************************************
-- For the Lockheed L-12a Sperry Mark 4 by S. M. Baugh
-- Consultation with GASTONREIF's flywithlua script for Sperry A-3
-- used by permission
-- mod by BK
-- ************************************************************************

----- SIM dataref variables ---- 
simDR_servos_on = find_dataref("sim/cockpit2/autopilot/servos_on")
simDR_AP_source = find_dataref("sim/cockpit2/autopilot/autopilot_source")	-- 0=pilot, 1=copilot
simDR_HDG_mode = find_dataref("sim/cockpit2/autopilot/heading_mode") 		-- 0=off, 1=on
simDR_copilot_HDG_bug = find_dataref("sim/cockpit2/autopilot/heading_dial_deg_mag_copilot")
simDR_bottom_roller = find_dataref("sim/cockpit2/gauges/indicators/heading_vacuum_deg_mag_copilot")
simDR_pitch_hold_deg = find_dataref("sim/cockpit2/autopilot/sync_hold_pitch_deg")

---- SIM commands ----
simCMD_AP_servos_on = find_command("sim/autopilot/servos_on")
simCMD_AP_servos_off = find_command("sim/autopilot/servos_off_any")
simCMD_HDG_hold = find_command("sim/autopilot/heading")
simCMD_ALT_hold = find_command("sim/autopilot/altitude_hold")
simCMD_pitch_sync = find_command("sim/autopilot/pitch_sync")
simCMD_roll_center = find_command("sim/autopilot/override_center")
simCMD_roll_left = find_command("sim/autopilot/override_left")
simCMD_roll_right = find_command("sim/autopilot/override_right")


---- Custom datarefs ----
function fake_handler() -- Usage of a handler, even if fake, makes custom datarefs writable
end
myDR_power_switch = create_dataref("lockheed/L12a/sperry_power_switch","number",fake_handler)
myDR_top_roller = create_dataref("lockheed/L12a/sperry_top_roller","number",fake_handler)
myDR_rudder_knob = create_dataref("lockheed/L12a/sperry_rudder_knob","number",fake_handler)
myDR_aileron_knob = create_dataref("lockheed/L12a/sperry_aileron_knob","number",fake_handler)
myDR_elevator_knob = create_dataref("lockheed/L12a/sperry_elevator_knob","number",fake_handler)	-- controlled by SIM commands

local rudder_knob = 0
local top_roller = 0
local gyro_hdg = 0
local hdg_bug = 0
local hdg_reset_flag = 0
local pitch = 0
local roll = 0
local roll_flag = 0
local power = 0
local x = 0


---------------- HANDLER FUNCTIONS ----------------------

function func_animation_handler(new_value, anim_value, anim_speed)
	anim_value = anim_value + ((new_value - anim_value) * (anim_speed * SIM_PERIOD))
	return anim_value
end

function func_round(num, numdec)
    local mult = 10^(numdec or 0)
    if num >= 0 then return math.floor(num * mult + 0.5) / mult
    else return math.ceil(num * mult - 0.5) / mult
	end
end

function func_autopilot_setup()					-- comes here if servos just toggled ON

	x = hdg_bug - gyro_hdg						-- find out if hdg_bug variable w/in 3 of gyro heading
	x = math.abs(x)								-- makes negative positive
	x = func_round(x,0)							-- makes x integer
	
	if x <= 3 then								-- process only if bug w/in 3 degrees of gyro heading . . .
		hdg_bug = gyro_hdg						-- line up bug to gyro HDG
		simDR_copilot_HDG_bug = hdg_bug			-- now set SIM copilot bug heading to requested bug heading
		top_roller = gyro_hdg					-- and line up top and bottom rollers
		simCMD_HDG_hold:once()					-- and turn on heading hold to hold copilot heading value
	end
	
	simCMD_ALT_hold:once()						-- start AP with ALT hold to current altitude ON
	simCMD_pitch_sync:once()					-- this freezes the next dataref
	pitch = simDR_pitch_hold_deg				-- this is the nose up/down set in degrees
	pitch = func_round(pitch,0)					-- round to integer
	if pitch < -10 then pitch = -10 end			-- keep in limits
	if pitch > 10 then pitch = 10 end
	simDR_pitch_hold_deg = pitch				-- set nose up/down to this integer
	myDR_elevator_knob = pitch					-- and set knob
	
end
	

------------- CUSTOM COMMAND FUNCTIONS -------------------------------

function cmd_head_bug_up(phase, duration)
	if phase == 0 then
		if power == 0 then								-- power off, just move heading bug knob and roller
			hdg_bug = func_round(hdg_bug,0)				-- round heading bug to integer
			hdg_bug = hdg_bug + 1
			if hdg_bug >= 360 then hdg_bug = 0 end		-- circle complete
			top_roller = hdg_bug						-- now move roller (= compass ribbon)
			rudder_knob = hdg_bug						-- and knob
		end
	end
end

function cmd_head_bug_down(phase, duration)				-- see above
	if phase == 0 then
		if power == 0 then
			hdg_bug = func_round(hdg_bug,0)
			hdg_bug = hdg_bug - 1
			if hdg_bug < 0 then hdg_bug = 359 end
			top_roller = hdg_bug
			rudder_knob = hdg_bug
		end
	end
end

function cmd_aileron_center(phase, duration)
	if phase == 0 then
		if power == 1 and roll_flag == 1 then		-- only works if power on and aileron knob been turned
			simCMD_roll_center:once()
			hdg_reset_flag = 1						-- resets heading knob and roller below
			roll_flag = 0							-- reset flag
			roll = 0								-- and roll variable used for knob and horizon bar
			simCMD_HDG_hold:once()					-- toggle on heading hold
		end
	end
end

function cmd_aileron_left(phase, duration)
	if phase == 0 then
		if power == 1 then							-- only act if AP power on
			if roll_flag == 0 then
				roll_flag = 1						-- set for center routine and heading hold
				simCMD_HDG_hold:once()				-- toggle off heading hold
			end
			roll = roll - 1							-- use for aileron knob and horizon bar
			if roll >= -10 then
				simCMD_roll_left:once()				-- only roll up to -10/10 degrees
			else
				roll = -10							-- else no more rolling
			end
		end											-- use for aileron knob and horizon bar
	end
end

function cmd_aileron_right(phase, duration)
	if phase == 0 then
		if power == 1 then							-- see above
			if roll_flag == 0 then
				roll_flag = 1						-- set for center routine and heading hold
				simCMD_HDG_hold:once()				-- toggle off heading hold
			end
			roll = roll + 1
			if roll <= 10 then
				simCMD_roll_right:once()
			else
				roll = 10
			end
		end
	end
end

function cmd_elevator_center(phase, duration)		-- elevator calibration knob pushed
	if phase == 0 then
		if power == 0 then
			simCMD_roll_center:once()				-- center bar
			pitch = 0								-- signal elevator bar center below
		end
	end
end

------------------------------ CREATE COMMANDS ----------------------------------------------

cmdhdbgup = create_command("lockheed/L12a/heading_bug_up","Sperry AP Heading Up",cmd_head_bug_up)
cmdhdbgdn = create_command("lockheed/L12a/heading_bug_down","Sperry AP Heading Down",cmd_head_bug_down)
cmdrolcnt = create_command("lockheed/L12a/aileron_center","Sperry AP Aileron Center",cmd_aileron_center)
cmdrollft = create_command("lockheed/L12a/aileron_left","Sperry AP Aileron Left",cmd_aileron_left)
cmdrolrt = create_command("lockheed/L12a/aileron_right","Sperry AP Aileron Right",cmd_aileron_right)
cmdcntpt = create_command("lockheed/L12a/elevator_center","Sperry AP Elevator Center",cmd_elevator_center)


---------------------------- RUNTIME FUNCTIONS -----------------------------------

function flight_start()

	simDR_AP_source = 1				-- source = copilot
	simCMD_AP_servos_off:once()
	
	gyro_hdg = simDR_bottom_roller
	hdg_bug = gyro_hdg
	power = 0
	pitch = 0
	roll = 0
	roll_flag = 0
	hdg_reset_flag = 0

end


function after_physics()

	if power ~= simDR_servos_on then					-- Power switch (servos) just toggled
		power = simDR_servos_on							-- keep power variable current
		myDR_power_switch = power						-- move switch
		if power == 1 then								-- servos just turned on
			gyro_hdg = simDR_bottom_roller			-- first set variable
			gyro_hdg = func_round(gyro_hdg,0)		-- round it first
			func_autopilot_setup()					-- then do AP HDG and ALT setup
		end
	end

	if roll_flag == 1 then
		hdg_bug = simDR_bottom_roller			-- set variables bug and rollers
		top_roller = hdg_bug
		myDR_top_roller = top_roller			-- and have top roller mirror bottom roller
		simDR_copilot_HDG_bug = hdg_bug			-- and sync copilot heading with commanded heading
	end

	if myDR_top_roller ~= top_roller then
		myDR_top_roller = top_roller
	end
	
	if myDR_rudder_knob ~= rudder_knob then
		myDR_rudder_knob = rudder_knob
	end

	if myDR_aileron_knob ~= roll then
		myDR_aileron_knob = roll
	end

	if myDR_elevator_knob ~= pitch then				-- process centering horizon bar when
		myDR_elevator_knob = pitch					-- elevator calibration knob pushed
	end

	if pitch ~= simDR_pitch_hold_deg then			-- Test if elevator knob has been moved
		if power == 1 then							-- only process if AP power on
			pitch = simDR_pitch_hold_deg			-- set variable to commanded pitch
			if pitch < -10 then pitch = -10 end		-- keep in limits
			if pitch > 10 then pitch = 10 end
			myDR_elevator_knob = pitch				-- move knob and horizon line
		end
	end
	
end


function aircraft_unload()

	simDR_AP_source = 0				-- return to source as pilot
	simCMD_AP_servos_off:once()		-- turn servos and flight director off at exit
	
end
