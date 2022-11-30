--[[
Vintage RCA com radio script for Lockheed L12a
by S. Baugh
mod by BK
]]
--[[

X-PLANE DATAREFS

]]
simDR_battery_power = find_dataref("sim/cockpit2/electrical/battery_on[0]")
simDR_com_power = find_dataref("sim/cockpit2/radios/actuators/com1_power")
simDR_com_volume = find_dataref("sim/cockpit2/radios/actuators/audio_volume_com1")
simDR_com2_volume = find_dataref("sim/cockpit2/radios/actuators/audio_volume_com2")
simDR_com_tune_MHz = find_dataref("sim/cockpit2/radios/actuators/com1_frequency_Mhz")  -- updated via command
simDR_com_tune_khz = find_dataref("sim/cockpit2/radios/actuators/com1_frequency_khz")
simDR_com_tune_hz = find_dataref("sim/cockpit2/radios/actuators/com1_frequency_hz_833")
--[[

CUSTOM DATAREFS

]]
function fake_handler() end -- Usage of a handler, even if fake, makes custom datarefs writable
myDR_com_mhz_knob = create_dataref("lockheed/L12a/com_mhz_knob","number",fake_handler)
myDR_com_mhz_needle = create_dataref("lockheed/L12a/com_mhz_needle","number")
myDR_com_khz_knob = create_dataref("lockheed/L12a/com_khz_knob","number",fake_handler)
myDR_com_hz_knob = create_dataref("lockheed/L12a/com_hz_knob","number",fake_handler)
--[[

FUNCTIONS

]]
--[[ Reads COM1 frequency from dataref; splits stuff into three parts ]]
function read_com1_frequency()
    myDR_com_mhz_knob = simDR_com_tune_MHz
    myDR_com_mhz_needle = myDR_com_mhz_knob
    myDR_com_khz_knob = math.floor(simDR_com_tune_khz/100) * 100
	myDR_com_hz_knob = simDR_com_tune_khz - math.floor(simDR_com_tune_khz/100) * 100
end
--[[ Updates COM1 frequency by assembling the new frequency from the three dials ]]
function update_com1_frequency()
    myDR_com_mhz_needle = myDR_com_mhz_knob
    simDR_com_tune_hz = (myDR_com_mhz_knob*1000)+myDR_com_khz_knob+myDR_com_hz_knob
end
--[[

COMMAND CALLBACKS

]]
function cmd_com_mhz_cw(phase, duration)
	if phase == 0 then
		if myDR_com_mhz_knob < 136 then							-- if > max ignore
			myDR_com_mhz_knob = myDR_com_mhz_knob + 1
			update_com1_frequency()
		end
	end
end

function cmd_com_mhz_ccw(phase, duration)
	if phase == 0 then
		if myDR_com_mhz_knob > 118 then							-- if < min ignore request
            myDR_com_mhz_knob = myDR_com_mhz_knob - 1
            update_com1_frequency()
		end
	end
end

function cmd_com_khz_cw(phase, duration)
	if phase == 0 then
		if myDR_com_khz_knob < 900 then							-- if > max ignore
			myDR_com_khz_knob = myDR_com_khz_knob + 100
			update_com1_frequency()
		end
	end
end

function cmd_com_khz_ccw(phase, duration)
	if phase == 0 then
		if myDR_com_khz_knob > 0 then							-- if > max ignore
			myDR_com_khz_knob = myDR_com_khz_knob - 100
			update_com1_frequency()
		end
	end
end

function cmd_com_hz_cw(phase, duration)
	if phase == 0 then
        if myDR_com_hz_knob < 95 then							-- if > max ignore
			myDR_com_hz_knob = myDR_com_hz_knob + 5
			update_com1_frequency()
        end
	end
end

function cmd_com_hz_ccw(phase, duration)
	if phase == 0 then
        if myDR_com_hz_knob > 0 then							-- if > max ignore
			myDR_com_hz_knob = myDR_com_hz_knob - 5
            update_com1_frequency()
        end
	end
end
--[[

CUSTOM COMMANDS

]]
lkl12ccrscw = create_command("lockheed/L12a/com_mhz_cw","MHz Selector Clockwise",cmd_com_mhz_cw)
lkl12ccrsccw = create_command("lockheed/L12a/com_mhz_ccw","MHz Selector Counterclockwise",cmd_com_mhz_ccw)
lkl12chzcw = create_command("lockheed/L12a/com_hz_cw","Hz Selector Clockwise",cmd_com_hz_cw)
lkl12chzccw = create_command("lockheed/L12a/com_hz_ccw","Hz Selector Counterclockwise",cmd_com_hz_ccw)
lkl12ckhzcw = create_command("lockheed/L12a/com_khz_cw","kHz Selector Clockwise",cmd_com_khz_cw)
lkl12ckhzccw = create_command("lockheed/L12a/com_khz_ccw","kHz Selector Counterclockwise",cmd_com_khz_ccw)
--[[

RUNTIME INTEGRATION

]]
--[[ Runs at X-Plane session start or aircraft load ]]
function flight_start()
    read_com1_frequency()
    simDR_com2_volume = 0 -- Mute COM2 to avoid wrongly inherited values from previous aircraft
    if simDR_battery_power == 1 then
        simDR_com_power = 1
        simDR_com_volume = simDR_com_volume
    else
        simDR_com_power = 0
        simDR_com_volume = simDR_com_volume
    end
end
--[[ Runs during X-Plane session ]]
function after_physics()
    if myDR_com_mhz_knob ~= simDR_com_tune_MHz then read_com1_frequency() end
    if myDR_com_khz_knob ~= math.floor(simDR_com_tune_khz/100) * 100 then read_com1_frequency() end
    if myDR_com_hz_knob ~= (simDR_com_tune_khz - math.floor(simDR_com_tune_khz/100) * 100) then read_com1_frequency() end
    -- Volume knob also turns off power:
    if simDR_battery_power == 1 and simDR_com_volume > 0.0 then
        simDR_com_power = 1
    else
        simDR_com_power = 0
    end
end
--[[ Runs during aircraft unload ]]
function aircraft_unload()
    simDR_com_power = 1     -- turn on power for next plane
end



