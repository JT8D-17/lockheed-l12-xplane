--- *******************************************************
--- Vintage radio script for Lockheed L12a
--- by S. Baugh
--- mod by BK

--- SIM DATAREFS ---
simDR_battery_power = find_dataref("sim/cockpit2/electrical/battery_on[0]")
simDR_NAV_power = find_dataref("sim/cockpit2/radios/actuators/nav1_power")
simDR_ADF_power = find_dataref("sim/cockpit2/radios/actuators/adf1_power")
simDR_NAV_frequency = find_dataref("sim/cockpit2/radios/actuators/nav1_frequency_hz")
simDR_ADF_frequency = find_dataref("sim/cockpit2/radios/actuators/adf1_frequency_hz")
simDR_NAV_bearing = find_dataref("sim/cockpit2/radios/indicators/nav1_relative_bearing_deg")
simDR_ADF_bearing = find_dataref("sim/cockpit2/radios/indicators/adf1_relative_bearing_deg")
simDR_NAV_id = find_dataref("sim/cockpit2/radios/indicators/nav1_nav_id")
simDR_ADF_id = find_dataref("sim/cockpit2/radios/indicators/adf1_nav_id")
simDR_NAV_has_dme = find_dataref("sim/cockpit2/radios/indicators/nav1_has_dme")
simDR_NAV_distance = find_dataref("sim/cockpit2/radios/indicators/nav1_dme_distance_nm")
simDR_ADF_has_dme = find_dataref("sim/cockpit2/radios/indicators/adf1_has_dme")
simDR_ADF_distance = find_dataref("sim/cockpit2/radios/indicators/adf1_dme_distance_nm")
simDR_NAV_volume = find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav1")
simDR_ADF_volume = find_dataref("sim/cockpit2/radios/actuators/audio_volume_adf1")

--- SIM COMMANDS ---
simCMD_monitor_NAV_on = find_command("sim/audio_panel/monitor_audio_nav1_on")
simCMD_monitor_NAV_off = find_command("sim/audio_panel/monitor_audio_nav1_off")
simCMD_monitor_ADF_on = find_command("sim/audio_panel/monitor_audio_adf1_on")
simCMD_monitor_ADF_off = find_command("sim/audio_panel/monitor_audio_adf1_off")


--- CUSTOM DATAREFS ---
function fake_handler() end -- Usage of a handler, even if fake, makes custom datarefs writable
myDR_radcom_needle = create_dataref("lockheed/L12a/radio_compass_needle","number")
myDR_audio_knob = create_dataref("lockheed/L12a/audio_volume_knob","number")

myDR_freq_group_knob = create_dataref("lockheed/L12a/frequency_group_knob","number",fake_handler)

myDR_freq_groups = create_dataref("lockheed/L12a/frequency_grouping_cards","number") -- grouping cards move with knob
myDR_tuning_wheel = create_dataref("lockheed/L12a/tuning_wheel","number")
myDR_freq_crank_coarse = create_dataref("lockheed/L12a/frequency_crank_coarse","number")
myDR_freq_crank_fine = create_dataref("lockheed/L12a/frequency_crank_fine","number")
myDR_mode_knob = create_dataref("lockheed/L12a/mode_selector","number")
myDR_signal_needle = create_dataref("lockheed/L12a/signal_needle","number")
myDR_signal_knob = create_dataref("lockheed/L12a/signal_selector","number")


-- local variables
local vor_freq = 0			-- used for exit value
local adf_freq = 0			-- used for exit value
local new_knob = 0
local new_wheel = 0.0
local new_mode = 0
local mode_setting = 0
local signal_mode = 0
local volume = 0.0
local v = 0.0
local x = 0
local y = 0.0
local sigstrength = 0.0
local empty_string = ""
local bearing = 0.0
local tab_sigfront = {}
local tab_sigrear = {}



---------------- HANDLER FUNCTIONS ---

function func_animation_handler(new_value, anim_value, anim_speed)
	anim_value = anim_value + ((new_value - anim_value) * (anim_speed * SIM_PERIOD))
	return anim_value
end

function func_test_boundaries(y,low,hi)
	if y < low then y = low
	elseif y > hi then y = hi
	end
	return y
end

function func_round(num, numdec)
    local mult = 10^(numdec or 0)
    if num >= 0 then return math.floor(num * mult + 0.5) / mult
    else return math.ceil(num * mult - 0.5) / mult
	end
end

function func_process_sigstrength(b,s)			-- set up signal strenth gauge values with lookup table
	b = math.abs(b)										-- makes negative positive
	b = func_round(b,0)									-- makes it integer
	if b <= 0 or b >= 360 then							-- error check
		b = 1
	end				

	if b >= 90 and b <= 180 then							-- right rear quarter
		b = (b - 89)
		b = (b - 20)									-- reduce 20%
		if b <= 0 then b = 1 end						-- then error check
		s = tab_sigrear[b]
	elseif bearing >= 269 and bearing <= 181 then			-- left rear quarter
		b = (b - 180)
		b = (b - 20)									-- reduce 20%
		if b <= 0 then b = 1 end						-- then error check
		s = tab_sigrear[bearing]
	elseif bearing >= 270 and bearing <= 359 then			-- left front quarter
		b = (b - 269)
		s = tab_sigfront[b]
	else													-- right front quarter
		s = tab_sigfront[b]
	end
	return s
end

---------------- COMMAND FUNCTIONS ---

function cmd_freq_selector_cw(phase, duration)
	if phase == 0 then

		if new_knob == 0 then					-- on NAV1 so move to ADF!, else no action
			new_knob = 1
			new_wheel = 190.0
			simDR_NAV_frequency = 190.00		-- set sim NAV1 to match
			simDR_ADF_frequency = 190			-- set sim ADF1 to match
		end

	end
end

function cmd_freq_selector_ccw(phase, duration)
	if phase == 0 then

		if new_knob == 1 then					-- on ADF1 so move to NAV1, else no action
			new_knob = 0
			new_wheel = 10800
			simDR_NAV_frequency = 10800		-- set sim NAV1 to match
			simDR_ADF_frequency = 108			-- set sim ADF1 to match
		end

	end
end






function cmd_crank_coarse_cw(phase, duration)
 	if phase == 0 then

		if mode_setting == 1 then						-- NAV1
			new_wheel = new_wheel + 1.0
			new_wheel = func_test_boundaries(new_wheel,108.0,117.0)		-- makes sure new_wheel is in range
			simDR_NAV_frequency = new_wheel

		elseif mode_setting >= 2 then					-- 2 or 3 = ADF1
			new_wheel = func_round(new_wheel,0)			-- needs rounding to integer if NAV1 has used it
			new_wheel = new_wheel + 10.0
			new_wheel = func_test_boundaries(new_wheel,190,535)
			simDR_ADF_frequency = new_wheel
		end
	end
end

function cmd_crank_coarse_ccw(phase, duration)
	if phase == 0 then

		if mode_setting == 1 then						-- NAV1
			new_wheel = new_wheel - 1.0
			new_wheel = func_test_boundaries(new_wheel,108.0,117.0)
			simDR_NAV_frequency = new_wheel

		elseif mode_setting >= 2 then					-- 2 or 3 = ADF1
			new_wheel = func_round(new_wheel,0)
			new_wheel = new_wheel - 10.0
			new_wheel = func_test_boundaries(new_wheel,190,535)
			simDR_ADF_frequency = new_wheel
		end
	end
end


function cmd_crank_fine_cw(phase, duration)
 	if phase == 0 then

		if mode_setting == 1 then						-- NAV1
			new_wheel = new_wheel + 0.05
			new_wheel = func_test_boundaries(new_wheel,108.0,118.0)
			simDR_NAV_frequency = math.ceil(new_wheel * 100.0)			-- input nav1 freq and round b/c of rounding error

		elseif mode_setting >= 2 then					-- 2 or 3 = ADF1
			new_wheel = func_round(new_wheel,0)
			new_wheel = new_wheel + 1.0
			new_wheel = func_test_boundaries(new_wheel,190,535)
			simDR_ADF_frequency = new_wheel
		end
	end
end
		
function cmd_crank_fine_ccw(phase, duration)
	if phase == 0 then

		if mode_setting == 1 then						-- NAV1
			new_wheel = new_wheel - 0.05
			new_wheel = func_test_boundaries(new_wheel,108.0,118.0)
			simDR_NAV_frequency = math.ceil(new_wheel * 100.0)

		elseif mode_setting >= 2 then					-- 2 or 3 = ADF1
			new_wheel = func_round(new_wheel,0)
			new_wheel = new_wheel - 1.0
			new_wheel = func_test_boundaries(new_wheel,190,535)
			simDR_ADF_frequency = new_wheel
		end
	end
end

function cmd_radio_mode_cw(phase, duration)
	if phase == 0 then
		mode_setting = mode_setting + 1
		if mode_setting == 1 then				-- set to NAV1
			simCMD_monitor_NAV_on:once()
			new_mode = 1							-- for knob animation
		elseif mode_setting == 2 then				-- set to ADF1 with ANT morse id
			simCMD_monitor_NAV_off:once()
			simCMD_monitor_ADF_on:once()
			new_mode = 2
		elseif mode_setting == 3 then			-- set to ADF1 no morse id
			new_mode = 3
		else									-- set to 4 & out of range, stay on ADF1 & no action
			mode_setting = 3
		end
	end
end

function cmd_radio_mode_ccw(phase, duration)
	if phase == 0 then
		mode_setting = mode_setting - 1
		if mode_setting == 2 then				-- set to ADF1 with morse id below
			new_mode = 2
		elseif mode_setting == 1 then			-- set to NAV1 with ADF1 audio off
			simCMD_monitor_ADF_off:once()
			simCMD_monitor_NAV_on:once()
			new_mode = 1
		else									-- set to 0 or -1 and out of range so turn off NAV1
			simCMD_monitor_NAV_off:once()
			mode_setting = 0
			new_mode = 0
		end
	end
end

--[[ Radio mode ]]
function nav_radio_mode()



end


function cmd_signal_mode_cw(phase, duration)	-- switches between bearing mode and dme mode
	if phase == 0 then
		signal_mode = 1						-- use to animate below, uses bearing signal for gauge
	end
end

function cmd_signal_mode_ccw(phase, duration)
	if phase == 0 then
		signal_mode = 0						-- use to animate below, uses dme for gauge
	end
end

--
-- probably needs to activate sim volume in mode_setting routine above
--
function cmd_audio_knob_cw(phase, duration)			-- switches between NAV and ADF volume
	if phase == 0 then
		volume = volume + 0.1
		if volume >= 1.0 then volume = 1 end		-- error check
		myDR_audio_knob = volume					-- move knob itself
		simDR_NAV_volume = volume
		simDR_ADF_volume = volume
	end
end

function cmd_audio_knob_ccw(phase, duration)
	if phase == 0 then
		volume = volume - 0.1
		if volume <= 0.0 then volume = 0 end	-- error check
		myDR_audio_knob = volume					-- move knob itself
		simDR_NAV_volume = volume
		simDR_ADF_volume = volume
	end
end

---------------- CREATE COMMANDS ---
lkl12freqselcw = create_command("lockheed/L12a/frequency_group_select_cw","selector",cmd_freq_selector_cw)
lkl12freqselccw = create_command("lockheed/L12a/frequency_group_select_ccw","selector",cmd_freq_selector_ccw)

lkl12frqwhlcrscw = create_command("lockheed/L12a/frequency_crank_coarse_cw","crank",cmd_crank_coarse_cw)
lkl12frqwhlcrsccw = create_command("lockheed/L12a/frequency_crank_coarse_ccw","crank",cmd_crank_coarse_ccw)
lkl12frqwhlfncw = create_command("lockheed/L12a/frequency_crank_fine_cw","crank",cmd_crank_fine_cw)
lkl12frqwhlfnccw = create_command("lockheed/L12a/frequency_crank_fine_ccw","crank",cmd_crank_fine_ccw)
lkl12radmdcw = create_command("lockheed/L12a/radio_mode_cw","source",cmd_radio_mode_cw)
lkl12radmdccw = create_command("lockheed/L12a/radio_mode_ccw","source",cmd_radio_mode_ccw)
lkl12tnmdcw = create_command("lockheed/L12a/signal_mode_cw","dme or not",cmd_signal_mode_cw)
lkl12tnmdccw = create_command("lockheed/L12a/signal_mode_ccw","dme or not",cmd_signal_mode_ccw)
lkl12adkncw = create_command("lockheed/L12a/audio_knob_cw","volume",cmd_audio_knob_cw)
lkl12adknccw = create_command("lockheed/L12a/audio_knob_ccw","volume",cmd_audio_knob_ccw)


--- START RUNTIME AND END FUNCTIONS ---

function flight_start()

	vor_freq = simDR_NAV_frequency		-- set for exit value
	adf_freq = simDR_ADF_frequency		-- set for exit value
	simDR_NAV_frequency = 10800
	simDR_ADF_frequency = 108
	simDR_NAV_power = 0
	simDR_ADF_power = 0
	simDR_NAV_volume = 0.0
	simDR_ADF_volume = 0.0

	myDR_freq_group_knob = 0
	myDR_tuning_wheel = 108.0
 	myDR_freq_crank_coarse = 108.0
 	new_wheel = 108.0
	mode_setting = 0
	myDR_signal_knob = 0
	signal_mode = 0
	myDR_radcom_needle = 90.0
	myDR_signal_needle = 0.0
	myDR_audio_knob = 0.0
	
	
	--- *** populate tables used for signal strength needle values ***
	for v = 1.00, 0.10, -0.01 do				-- 3d value specifies step;
 		table.insert(tab_sigfront, v)
	end
	
	for v = 0.10, 1.00, 0.01 do					-- = declining value flying away from nav
		table.insert(tab_sigrear, v)
	end
	
end

function after_physics()
	
	if new_knob ~= myDR_freq_group_knob then			 -- animate knob, tuning wheel, and crank slowly
 		myDR_freq_group_knob = func_animation_handler(new_knob,myDR_freq_group_knob,15)
		myDR_tuning_wheel = func_animation_handler(new_wheel,myDR_tuning_wheel,20)
		myDR_freq_crank_coarse = func_animation_handler(new_wheel,myDR_freq_crank_coarse,10)
	end
	
	if new_wheel ~= myDR_tuning_wheel then			 -- animate knob, tuning wheel, and crank slowly
 		myDR_tuning_wheel = func_animation_handler(new_wheel,myDR_tuning_wheel,15)
		myDR_freq_crank_coarse = func_animation_handler(new_wheel,myDR_freq_crank_coarse,15)
	end
	
	if new_mode ~= myDR_mode_knob then
		myDR_mode_knob = func_animation_handler(new_mode,myDR_mode_knob,10)
	end
	
	if signal_mode ~= myDR_signal_knob then
		myDR_signal_knob = func_animation_handler(signal_mode,myDR_signal_knob,10)
	end
	

--- *** ROUTINES FOR SIGNAL STRENGTH ***

	if mode_setting == 1						-- set to NAV1 and tuned -- DME MODE
		and simDR_NAV_id ~= empty_string
		and simDR_NAV_has_dme == 1
		and signal_mode == 0 then			-- set to dme mode
			bearing = simDR_NAV_bearing
			myDR_radcom_needle = bearing
			d = simDR_NAV_distance				-- d for distance via dme
				if d >= 100.0 then					-- error check
					d = 99.0
				end
			sigstrength = ((100 - d) * 0.01)			-- convert nm to % of 1.0 for signal strength needle
			sigstrength = func_round(sigstrength,2)		-- round and make 0.xx places
			myDR_signal_needle = func_animation_handler(sigstrength,myDR_signal_needle,7)

	elseif mode_setting == 1						-- set to NAV1 and tuned -- BEARING MODE
		and simDR_NAV_id ~= empty_string
		and signal_mode == 1 then					-- set to bearing mode
			bearing = simDR_NAV_bearing									-- bearing is main variable to use
			myDR_radcom_needle = bearing								-- feed radio compass needle
			sigstrength = func_process_sigstrength(bearing,sigstrength)	-- process for signal strength needle
			myDR_signal_needle = func_animation_handler(sigstrength,myDR_signal_needle,7)

	elseif mode_setting >= 2						-- set to ADF1 and tuned to station -- DME MODE
		and simDR_ADF_id ~= empty_string
		and simDR_ADF_has_dme == 1					-- adf1 has dme and knob set to dme mode
		and signal_mode == 0 then
			bearing = simDR_ADF_bearing
			myDR_radcom_needle = bearing
			d = simDR_ADF_distance
				if d >= 100.0 then
					d = 99.0
				end
			sigstrength = ((100 - d) * 0.01)
			sigstrength = func_round(sigstrength,2)
			myDR_signal_needle = func_animation_handler(sigstrength,myDR_signal_needle,7)
	
	elseif mode_setting >= 2						-- set to ADF1 and tuned -- BEARING MODE
			and simDR_ADF_id ~= empty_string
			and signal_mode == 1 then
			bearing = simDR_ADF_bearing
			myDR_radcom_needle = bearing
			sigstrength = func_process_sigstrength(bearing,sigstrength)
			myDR_signal_needle = func_animation_handler(sigstrength,myDR_signal_needle,7)

	else
		sigstrength = 0.0											-- have everything off
		myDR_signal_needle = func_animation_handler(sigstrength,myDR_signal_needle,7)
		myDR_radcom_needle = 90.0
	end

--- *** END SIGNAL STRENGTH *** ---

	if simDR_battery_power == 1 and mode_setting == 1 then
		simDR_NAV_power = 1
	elseif simDR_battery_power == 1 and mode_setting == 2 then
		simDR_ADF_power = 3									-- ADF on with morse
	elseif simDR_battery_power == 1 and mode_setting == 3 then
		simDR_ADF_power = 2									-- ADF on without morse
	else
		simDR_NAV_power = 0
		simDR_ADF_power = 0
	end

end

function aircraft_unload()

	simDR_NAV_frequency = vor_freq		-- set to entrance value
	simDR_ADF_frequency	= adf_freq 		-- set to entrance value
	simDR_NAV_power = 1					-- turn on power for next plane
	simDR_ADF_power = 2
	
end
