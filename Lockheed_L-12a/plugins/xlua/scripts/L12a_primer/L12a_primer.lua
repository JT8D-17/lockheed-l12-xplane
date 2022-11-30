--[[
Dual fuel primer for the Lockheed L-12a
by S. Baugh
mod by BK
]]
--[[

X-PLANE DATAREFS

]]
simDR_left_primer = find_dataref("sim/cockpit2/engine/actuators/primer_on[0]") -- 0 = NONE/DOWN, 1 = ON/UP
simDR_right_primer = find_dataref("sim/cockpit2/engine/actuators/primer_on[1]")
--[[

CUSTOM DATAREFS

]]
function fake_handler() end -- Usage of a handler, even if fake, makes custom datarefs writable
primer_handle_angle = create_dataref("lockheed/L12a/primer_selector","number",fake_handler) -- handle rotates to select which engine to prime -90 = left engine, 0 = OFF, 90 = right engine
engine_primer_handle = create_dataref("lockheed/L12a/primer_pump_handle","number")
--[[

COMMAND CALLBACKS

]]
function cmd_engine_prime_select_cw(phase, duration)
	if phase == 0 then
		if primer_handle_angle == -90 then			-- on left engine, move to OFF
			primer_handle_angle = 0
			engine_primer_handle = 0
		else										-- on OFF, move to right engine
			primer_handle_angle = 90
			engine_primer_handle = 1				-- activates handle
		end
	end
end
	
function cmd_engine_prime_select_ccw(phase, duration)
	if phase == 0 then
		if primer_handle_angle == 90 then			-- on right engine, move to OFF
			primer_handle_angle = 0
			engine_primer_handle = 0
			--simDR_left_primer = 0
			--simDR_right_primer = 0
		else										-- on OFF, move to left engine
			primer_handle_angle = -90
			engine_primer_handle = 1
		end
	end
end

function cmd_engine_primer_up(phase, duration)
	if phase == 0 then
		engine_primer_handle = 1
		simDR_left_primer = 0					-- both engine primer ratios go to zero
		simDR_right_primer = 0					-- 		when handle pushed down
	end
end

function cmd_engine_primer_down(phase, duration)
	if phase == 0 then
		if primer_handle_angle == -90 then
			engine_primer_handle = 0
			simDR_left_primer = 1
		elseif primer_handle_angle == 90 then
			engine_primer_handle = 0
			simDR_right_primer = 1
		else
			engine_primer_handle = 0
		end
	end
end

function cmd_engine_prime(phase, duration)
	if phase == 0 then -- Button push
		if primer_handle_angle == -90 then
			engine_primer_handle = 0
			simDR_left_primer = 1
		elseif primer_handle_angle == 90 then
			engine_primer_handle = 0
			simDR_right_primer = 1
		end
	end
	if phase == 2 then -- Button release
		if primer_handle_angle == -90 then
			engine_primer_handle = 1
			simDR_left_primer = 0
		elseif primer_handle_angle == 90 then
			engine_primer_handle = 1
			simDR_right_primer = 0
		end
	end
end
--[[

CUSTOM COMMANDS

]]
cmdprimecw = create_command("lockheed/L12a/primer_selector_cw","Primer Selector Clockwise",cmd_engine_prime_select_cw)
cmdprimeccw = create_command("lockheed/L12a/primer_selector_ccw","Primer Selector Counterclockwise",cmd_engine_prime_select_ccw)

cmdprimedn = create_command("lockheed/L12a/primer_pump_down","Primer Handle In",cmd_engine_primer_down)
cmdprimeup = create_command("lockheed/L12a/primer_pump_up","Primer Handle Out",cmd_engine_primer_up)

cmdprime = create_command("lockheed/L12a/primer_push","Primer Knob Push",cmd_engine_prime)
cmdprime1 = replace_command("sim/fuel/fuel_pump_1_prime",cmd_engine_prime)
cmdprime2 = replace_command("sim/fuel/fuel_pump_2_prime",cmd_engine_prime)
--[[

RUNTIME INTEGRATION

]]
--[[ Runs at X-Plane session start or aircraft load ]]
function flight_start()
	primer_handle_angle = 0			-- primer starts OFF
	engine_primer_handle = 0
	simDR_left_primer = 0
	simDR_right_primer = 0
end
