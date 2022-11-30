--[[
Vintage ARN-7 nav radio script for Lockheed L12a
by S. Baugh
mod by BK
]]
--[[

X-PLANE DATAREFS

]]
simDR_NAV_Freq_Hz = find_dataref("sim/cockpit2/radios/actuators/nav1_frequency_hz")
simDR_ADF_Freq_Hz = find_dataref("sim/cockpit2/radios/actuators/adf1_frequency_hz")
simDR_monitor_NAV = find_dataref("sim/cockpit2/radios/actuators/audio_selection_nav1")
simDR_monitor_ADF = find_dataref("sim/cockpit2/radios/actuators/audio_selection_adf1")
simDR_NAV_volume = find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav1")
simDR_ADF_volume = find_dataref("sim/cockpit2/radios/actuators/audio_volume_adf1")
simDR_NAV_id = find_dataref("sim/cockpit2/radios/indicators/nav1_nav_id")
simDR_ADF_id = find_dataref("sim/cockpit2/radios/indicators/adf1_nav_id")
simDR_NAV_bearing = find_dataref("sim/cockpit2/radios/indicators/nav1_relative_bearing_deg")
simDR_ADF_bearing = find_dataref("sim/cockpit2/radios/indicators/adf1_relative_bearing_deg")
simDR_NAV_has_dme = find_dataref("sim/cockpit2/radios/indicators/nav1_has_dme")
simDR_ADF_has_dme = find_dataref("sim/cockpit2/radios/indicators/adf1_has_dme")
simDR_NAV_distance = find_dataref("sim/cockpit2/radios/indicators/nav1_dme_distance_nm")
simDR_ADF_distance = find_dataref("sim/cockpit2/radios/indicators/adf1_dme_distance_nm")
--[[

VARIABLES

]]
local freq_crank_pos = {0,0,0} -- Previous position, delta, is at stop
local sigstrength = 0 -- Signal strength
local distance = 0 -- Distance to navaid
local tab_sigfront = { } -- Signal strength table for front half
for v = 1.00, 0.10, -0.01 do tab_sigfront[#tab_sigfront+1] = v end -- Populate signal strength table for front half
local tab_sigrear = { } -- Signal strength table for rear half
for v = 0.10, 1.00, 0.01 do tab_sigrear[#tab_sigrear+1] = v end -- Populate signal strength table for rear half
--[[

FUNCTIONS

]]
--[[ Handler for playing animations ]]
function func_animation_handler(new_value, anim_value, anim_speed)
	anim_value = anim_value + ((new_value - anim_value) * (anim_speed * SIM_PERIOD))
	return anim_value
end
--[[ Animation handler for the frequency crank ]]
function nav_freq_crank_animation(syncin,syncout)
    myDR_freq_crank = tonumber(string.format("%d",myDR_freq_crank)) -- Workaround to round if manipulator is mouse dragged
    if myDR_freq_crank < 1 then myDR_freq_crank = 360 myDR_freq_crank_anim = 360 elseif myDR_freq_crank > 359 then myDR_freq_crank = 0 myDR_freq_crank_anim = 0 end -- Reset rotation
    syncout = syncin
end
--[[ Frequency tuning logic ]]
function frequency_tuning(dref,min,max,increment)
    dref = dref + increment
    if dref < min then dref = min freq_crank_pos[3] = 1 elseif dref > max then dref = max freq_crank_pos[3] = 1 else freq_crank_pos[3] = 0 end -- Check for boundaries; mark handle as stopped when at boundary
    return dref
end
--[[ Handler for tuning the nav radio frequency ]]
function nav_freq_tune_handler()
    -- Crank animation
    myDR_freq_crank = tonumber(string.format("%d",myDR_freq_crank)) -- Workaround to round to integer if manipulator is mouse dragged
    freq_crank_pos[2] = myDR_freq_crank - freq_crank_pos[1] -- Calculate delta between current and previous position
    if myDR_freq_crank < 1 then myDR_freq_crank = 360 myDR_freq_crank_anim = 360 elseif myDR_freq_crank > 359 then myDR_freq_crank = 0 myDR_freq_crank_anim = 0 end -- Reset rotation
    -- Actual frequency tuning
    if myDR_freq_group_mode == 0 then simDR_NAV_Freq_Hz = frequency_tuning(simDR_NAV_Freq_Hz,10800,11795,freq_crank_pos[2] * 5) end -- NAV Mode
    if myDR_freq_group_mode == 1 then simDR_ADF_Freq_Hz = frequency_tuning(simDR_ADF_Freq_Hz,190,535,freq_crank_pos[2]) end -- ADF Mode

    if freq_crank_pos[3] == 0 then freq_crank_pos[1] = myDR_freq_crank else myDR_freq_crank = freq_crank_pos[1] end -- Capture previous crank position
end
--[[ Handler for the nav radio selector ]]
function radio_mode_selector()
    if myDR_mode_selector == 0 then -- NAV1 audio off, ADF1 audio off
        simDR_monitor_NAV = 0
        simDR_monitor_ADF = 0
    end
    if myDR_mode_selector == 1 then -- NAV1 audio on, ADF1 audio off
        simDR_monitor_NAV = 1
        simDR_monitor_ADF = 0
    end
    if myDR_mode_selector == 2 then -- NAV1 audio off, ADF1 audio on
        simDR_monitor_NAV = 0
        simDR_monitor_ADF = 1
    end
    if myDR_mode_selector == 3 then -- NAV1 audio off, ADF1 audio off
        simDR_monitor_NAV = 0
        simDR_monitor_ADF = 0
    end
    sigstrength = 0
end

function func_process_sigstrength(b,s) -- set up signal strenth gauge values with lookup table
    b = tonumber(string.format("%d",math.abs(b))) -- Make absolute, round to integer and convert back to number
    if b <= 0 or b >= 360 then b = 1 end -- Boundary check
    if b > 270 and b <= 90 then -- Front half
        if b > 270 and b <= 359 then b = (b - 270) end -- Front left quarter
        if b <= 0 then b = 1 end -- Boundary check
        s = tab_sigfront[b]
    else -- Rear half
        if b > 90 and b <= 180 then b = (b - 90) end -- Rear right quarter
        if b > 180 and b <= 270 then b = (b - 180) end -- Rear left quarter
        b = (b - 20) -- reduce 20%
        if b <= 0 then b = 1 end -- Boundary check
        s = tab_sigrear[b]
    end
	return s
end

function fake_handler() end -- Usage of a handler, even if fake, makes custom datarefs writable
--[[

CUSTOM DATAREFS

]]
-- Animation datarefs, not writable
myDR_freq_group_knob_anim = create_dataref("lockheed/L12a/navradio/frequency_group_knob_anim","number")
myDR_freq_crank_anim = create_dataref("lockheed/L12a/navradio/frequency_crank_anim","number")
myDR_mode_selector_anim = create_dataref("lockheed/L12a/navradio/mode_selector_anim","number")
myDR_signal_mode_anim = create_dataref("lockheed/L12a/navradio/signal_selector_anim","number")
myDR_tuning_wheel_anim = create_dataref("lockheed/L12a/navradio/tuning_wheel_anim","number")
myDR_signal_needle = create_dataref("lockheed/L12a/navradio/signal_needle","number")
myDR_radcom_needle = create_dataref("lockheed/L12a/radio_compass_needle","number") -- Used by the RMI
-- Interaction datarefs, writable
myDR_freq_group_mode = create_dataref("lockheed/L12a/navradio/frequency_group_knob","number",fake_handler)
myDR_freq_crank = create_dataref("lockheed/L12a/navradio/frequency_crank","number",nav_freq_tune_handler)
myDR_mode_selector = create_dataref("lockheed/L12a/navradio/mode_selector","number",radio_mode_selector)
myDR_signal_mode = create_dataref("lockheed/L12a/navradio/signal_selector","number",fake_handler)
myDR_volume = create_dataref("lockheed/L12a/navradio/audio_volume_knob","number",fake_handler)
--[[

RUNTIME INTEGRATION

]]
--[[ Runs at X-Plane session start or aircraft load ]]
function flight_start()
    myDR_volume = 0.5 -- Set initial ADF/NAV volume level
    myDR_freq_group_mode = 0
end
--[[ Runs during X-Plane session ]]
function after_physics()
    --[[ Animations ]]
    if myDR_freq_group_mode ~= myDR_freq_group_knob_anim then myDR_freq_group_knob_anim = func_animation_handler(myDR_freq_group_mode,myDR_freq_group_knob_anim,15) end
    if myDR_freq_crank ~= myDR_freq_crank_anim then myDR_freq_crank_anim = func_animation_handler(myDR_freq_crank,myDR_freq_crank_anim,10) end
    if myDR_mode_selector ~= myDR_mode_selector_anim then myDR_mode_selector_anim = func_animation_handler(myDR_mode_selector,myDR_mode_selector_anim,10) end
    if myDR_signal_mode ~= myDR_signal_mode_anim then myDR_signal_mode_anim = func_animation_handler(myDR_signal_mode,myDR_signal_mode_anim,10) end
    if myDR_freq_group_mode == 0 and (simDR_NAV_Freq_Hz / 100) ~= myDR_tuning_wheel_anim then myDR_tuning_wheel_anim = func_animation_handler((simDR_NAV_Freq_Hz / 100),myDR_tuning_wheel_anim,20) end -- NAV mode
    if myDR_freq_group_mode == 1 and simDR_ADF_Freq_Hz ~= myDR_tuning_wheel_anim then myDR_tuning_wheel_anim = func_animation_handler(simDR_ADF_Freq_Hz,myDR_tuning_wheel_anim,20) end -- ADF mode
    --[[ Navaid Volume ]]
    simDR_NAV_volume = myDR_volume
    simDR_ADF_volume = myDR_volume
    --[[ Signal strength ]]
    if myDR_mode_selector == 1 and simDR_NAV_id ~= "" then -- NAV mode, tuned to valid station
        myDR_radcom_needle = simDR_NAV_bearing -- Drive RMI needle
        if myDR_signal_mode == 0 and simDR_NAV_has_dme == 1 then -- DME mode
            distance = simDR_NAV_distance -- DME distance
            if distance >= 100.0 then distance = 99.0 end -- Clamp maximum value
            sigstrength = ((100 - distance) * 0.01) -- convert nm to % of 1.0 for signal strength needle
            sigstrength = tonumber(string.format("%.2f",sigstrength)) -- round and make 0.xx places
            myDR_signal_needle = func_animation_handler(sigstrength,myDR_signal_needle,7)
        elseif myDR_signal_mode == 1 then -- Bearing mode
            sigstrength = func_process_sigstrength(simDR_NAV_bearing,sigstrength)   -- process for signal strength needle
            myDR_signal_needle = func_animation_handler(sigstrength,myDR_signal_needle,7)
        else
            sigstrength = 0
            myDR_signal_needle = func_animation_handler(sigstrength,myDR_signal_needle,7)
        end
    elseif myDR_mode_selector >= 2 and simDR_ADF_id ~= "" then -- ADF mode, tuned to valid station
        myDR_radcom_needle = simDR_ADF_bearing -- Drive RMI needle
        if myDR_signal_mode == 0 and simDR_ADF_has_dme == 1 then -- DME mode
            distance = simDR_ADF_distance -- DME distance
            if distance >= 100.0 then distance = 99.0 end -- Clamp maximum value
            sigstrength = ((100 - distance) * 0.01) -- convert nm to % of 1.0 for signal strength needle
            sigstrength = tonumber(string.format("%.2f",sigstrength)) -- round and make 0.xx places
            myDR_signal_needle = func_animation_handler(sigstrength,myDR_signal_needle,7)
        elseif myDR_signal_mode == 1 then -- Bearing mode
            sigstrength = func_process_sigstrength(simDR_NAV_bearing,sigstrength)   -- process for signal strength needle
            myDR_signal_needle = func_animation_handler(sigstrength,myDR_signal_needle,7)
        else
            sigstrength = 0
            myDR_signal_needle = func_animation_handler(sigstrength,myDR_signal_needle,7)
        end
    else
        sigstrength = 0
        myDR_signal_needle = func_animation_handler(sigstrength,myDR_signal_needle,7)
        myDR_radcom_needle = 90.0
    end
end
