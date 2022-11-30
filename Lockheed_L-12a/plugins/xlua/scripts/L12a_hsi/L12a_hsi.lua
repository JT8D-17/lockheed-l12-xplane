------------------------------------------------------------
-- XLUA Howard course rollers script
-- by SmB
------------------------------------------------------------

----------------------------------- LOCATE/CREATE DATAREFS -----------------------------------

simDR_float_deg = find_dataref("sim/cockpit2/radios/actuators/hsi_obs_deg_mag_pilot")
simDR_hsi_selection = find_dataref("sim/cockpit/switches/HSI_selector")

myDR_hsi_deg_integer = create_dataref("lockheed/L12a/hsi_course_degrees","number")


function fake_handler() -- Usage of a handler, even if fake, makes custom datarefs writable
end
myDR_hsi_src_knob = create_dataref("lockheed/L12a/hsi_source_selector","number",fake_handler)


--------------------------------- COMMAND FUNCTIONS ---------------------------------

function cmd_hsi_up(phase, duration)				-- used to skip hsi source NAV2
	if phase == 0 then
		myDR_hsi_src_knob = 1					-- 0=NAV, 1=GPS for my knob
		simDR_hsi_selection = 2					-- 0=NAV1, 1=NAV2, 2=GPS for sim
	end
end

function cmd_hsi_dn(phase, duration)
	if phase == 0 then
		myDR_hsi_src_knob = 0
		simDR_hsi_selection = 0
	end
end

-- NAV

function cmd_hsi_source_toggle(phase, duration)
	if phase == 0 then
        if myDR_hsi_src_knob == 0 then
            myDR_hsi_src_knob = 1					-- 0=NAV, 1=GPS for my knob
        else
            myDR_hsi_src_knob = 0
        end
	end
end

--------------------------------- CREATE COMMANDS

L12srcup = create_command("lockheed/L12a/hsi_src_up","HSI Nav Source Up",cmd_hsi_up)
L12srcup2 = replace_command("sim/autopilot/hsi_select_up",cmd_hsi_up)
L12srcdn = create_command("lockheed/L12a/hsi_src_down","HSI Nav Source Down",cmd_hsi_dn)
L12srcdn2 = replace_command("sim/autopilot/hsi_select_down",cmd_hsi_dn)
-- New
L12srctog = create_command("lockheed/L12a/hsi_src_toggle","HSI Nav Source Toggle",cmd_hsi_source_toggle)

--------------------------------- DO THIS EACH FLIGHT START ---------------------------------

function flight_start()

	myDR_hsi_deg_integer = math.floor(simDR_float_deg + 0.5)		-- round to integer
	
end

--------------------------------- REGULAR RUNTIME ---------------------------------

function after_physics()

	myDR_hsi_deg_integer = math.floor(simDR_float_deg + 0.5)		-- round to integer
	if myDR_hsi_src_knob == 1 and simDR_hsi_selection ~= 2 then simDR_hsi_selection = 2 end -- 0=NAV1, 1=NAV2, 2=GPS for sim
	if myDR_hsi_src_knob == 0 and simDR_hsi_selection ~= 0 then simDR_hsi_selection = 0 end -- 0=NAV1, 1=NAV2, 2=GPS for sim
end
