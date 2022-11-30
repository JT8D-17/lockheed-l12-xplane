--[[
Fuel logic for Lockheed L12a
by S. Baugh
mod by BK
]]
--[[

X-PLANE DATAREFS

]]
--[[ Fuel tank order in PlaneMaker: 1 = left rear, 2 = left front, 3 = right front, 4 = right rear. Controls feeding from individual tanks by turning on/off tank fuel pumps ]]
simDR_fuel_tank_pumps = find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on")	-- index/tank no in PM/location: 0/1/LR, 1/2/LF, 2/3/RF, 3/4/RR
simDR_fuel_tank_selector = find_dataref("sim/cockpit2/fuel/fuel_tank_selector") -- Master fuel tank selector (0 = off, 1 = left, 2 = center, 3 = right, 4 = all)
simDR_firewall_closed_l = find_dataref("sim/cockpit2/fuel/firewall_closed_left") -- 0 = open allows fuel through, 1 = closed and cuts off fuel to engine
simDR_firewall_closed_r = find_dataref("sim/cockpit2/fuel/firewall_closed_right") -- 0 = open allows fuel through, 1 = closed and cuts off fuel to engine
simDR_bus_voltage = find_dataref("sim/cockpit2/electrical/bus_volts")
simDR_pitch_theta = find_dataref("sim/flightmodel2/position/true_theta") -- Pitch angle of the aircraft relative to earth
simDR_fuel_quantity = find_dataref("sim/cockpit2/fuel/fuel_quantity") -- 0 to 3: LR,LF,RF,RR
simDR_fuel_crossfeed = find_dataref("sim/cockpit2/fuel/auto_crossfeed") -- not needed so turned off
simDR_start_running = find_dataref("sim/operation/prefs/startup_running") -- Is aircraft initialized with engines running?
simDR_auto_start = find_dataref("sim/flightmodel2/misc/auto_start_in_progress") -- Is autostart event happening?
--[[

FUNCTIONS

]]
--[[ Handler for playing animations ]]
function func_animation_handler(new_value, anim_value, anim_speed)
	anim_value = anim_value + ((new_value - anim_value) * (anim_speed * SIM_PERIOD))
	return anim_value
end
--[[ Wraparound handler for the fuel tank selector ]]
function fuel_tank_selector_handler()
    myDR_fuel_tank_selector = tonumber(string.format("%d",myDR_fuel_tank_selector)) -- Workaround to round to integer if manipulator is mouse dragged
    if myDR_fuel_tank_selector == -1 then myDR_fuel_tank_selector_anim = 5 myDR_fuel_tank_selector = 4 -- Animation value is different to enable smooth wrapping
    elseif myDR_fuel_tank_selector == 5 then myDR_fuel_tank_selector_anim = -1 myDR_fuel_tank_selector = 0 end -- Animation value is different to enable smooth wrapping
end
--[[ Wraparound handler for the engine fuel selector ]]
function engine_fuel_selector_handler()
    myDR_engine_fuel_selector = tonumber(string.format("%d",myDR_engine_fuel_selector)) -- Workaround to round to integer if manipulator is mouse dragged
    if myDR_engine_fuel_selector == -1 then myDR_engine_fuel_selector_anim = 4 myDR_engine_fuel_selector = 3 -- Animation value is different to enable smooth wrapping
    elseif myDR_engine_fuel_selector == 4 then myDR_engine_fuel_selector_anim = -1 myDR_engine_fuel_selector = 0 end -- Animation value is different to enable smooth wrapping
end
--[[ Alter fuel level relative to aircraft pitch to simulate unreliable sensors ]]
function calc_fuel_level(input)
    local output = input * (1 - (simDR_pitch_theta * (0.5 / 35))) -- Reference deviance from nominal fuel level shall be +/-50 % at 35° pitch
    return output
end

function fake_handler() end -- Usage of a handler, even if fake, makes custom datarefs writable
--[[

CUSTOM DATAREFS

]]
-- Animation datarefs, not writable
myDR_fuel_tank_selector_anim = create_dataref("lockheed/L12a/fuel/fuel_tank_selector_anim","number")
myDR_engine_fuel_selector_anim = create_dataref("lockheed/L12a/fuel/engine_fuel_selector_anim","number")
myDR_fuel_quantity_LR = create_dataref("lockheed/L12a/fuel_level_LR","number")	-- these are for fuel gauges
myDR_fuel_quantity_LF = create_dataref("lockheed/L12a/fuel_level_LF","number")	--		adjusting levels when on ground
myDR_fuel_quantity_RF = create_dataref("lockheed/L12a/fuel_level_RF","number")
myDR_fuel_quantity_RR = create_dataref("lockheed/L12a/fuel_level_RR","number")
-- Interactive datarefs, writable
myDR_fuel_tank_selector = create_dataref("lockheed/L12a/fuel/fuel_tank_selector","number",fuel_tank_selector_handler)
myDR_engine_fuel_selector = create_dataref("lockheed/L12a/fuel/engine_fuel_selector","number",engine_fuel_selector_handler)
myDR_fuel_indicator_front_switch = create_dataref("lockheed/L12a/fuel/fuel_indicator_front_switch","number",fake_handler)
myDR_fuel_indicator_rear_switch = create_dataref("lockheed/L12a/fuel/fuel_indicator_rear_switch","number",fake_handler)
--[[

RUNTIME INTEGRATION

]]
--[[ Runs at X-Plane session start or aircraft load ]]
function flight_start()
    simDR_fuel_crossfeed = 0    -- Crossfeed to OFF

	if simDR_start_running == 1 then
        myDR_fuel_tank_selector = 1 -- Left rear
        myDR_engine_fuel_selector = 2 -- Both on
	end
end
--[[ Runs during X-Plane session ]]
function after_physics()
    --[[ Animations ]]
    if myDR_fuel_tank_selector ~= myDR_fuel_tank_selector_anim then myDR_fuel_tank_selector_anim = func_animation_handler(myDR_fuel_tank_selector,myDR_fuel_tank_selector_anim,10) end
    if myDR_engine_fuel_selector ~= myDR_engine_fuel_selector_anim then myDR_engine_fuel_selector_anim = func_animation_handler(myDR_engine_fuel_selector,myDR_engine_fuel_selector_anim,10) end
    --[[ Fuel tank selection ]]
    --simDR_fuel_tank_pumps
    if myDR_fuel_tank_selector == 0 then -- Tank selector off
        if simDR_fuel_tank_pumps[0] ~= 0 then simDR_fuel_tank_pumps[0] = 0 end
        if simDR_fuel_tank_pumps[1] ~= 0 then simDR_fuel_tank_pumps[1] = 0 end
        if simDR_fuel_tank_pumps[2] ~= 0 then simDR_fuel_tank_pumps[2] = 0 end
        if simDR_fuel_tank_pumps[3] ~= 0 then simDR_fuel_tank_pumps[3] = 0 end
        if simDR_fuel_tank_selector ~= 0 then simDR_fuel_tank_selector = 0 end
    elseif myDR_fuel_tank_selector == 1 then -- Tank selector left rear
        if simDR_fuel_tank_pumps[0] ~= 1 then simDR_fuel_tank_pumps[0] = 1 end
        if simDR_fuel_tank_pumps[1] ~= 0 then simDR_fuel_tank_pumps[1] = 0 end
        if simDR_fuel_tank_pumps[2] ~= 0 then simDR_fuel_tank_pumps[2] = 0 end
        if simDR_fuel_tank_pumps[3] ~= 0 then simDR_fuel_tank_pumps[3] = 0 end
        if simDR_fuel_tank_selector ~= 4 then simDR_fuel_tank_selector = 4 end
    elseif myDR_fuel_tank_selector == 2 then -- Tank selector left front
        if simDR_fuel_tank_pumps[0] ~= 0 then simDR_fuel_tank_pumps[0] = 0 end
        if simDR_fuel_tank_pumps[1] ~= 1 then simDR_fuel_tank_pumps[1] = 1 end
        if simDR_fuel_tank_pumps[2] ~= 0 then simDR_fuel_tank_pumps[2] = 0 end
        if simDR_fuel_tank_pumps[3] ~= 0 then simDR_fuel_tank_pumps[3] = 0 end
        if simDR_fuel_tank_selector ~= 4 then simDR_fuel_tank_selector = 4 end
    elseif myDR_fuel_tank_selector == 3 then -- Tank selector right front
        if simDR_fuel_tank_pumps[0] ~= 0 then simDR_fuel_tank_pumps[0] = 0 end
        if simDR_fuel_tank_pumps[1] ~= 0 then simDR_fuel_tank_pumps[1] = 0 end
        if simDR_fuel_tank_pumps[2] ~= 1 then simDR_fuel_tank_pumps[2] = 1 end
        if simDR_fuel_tank_pumps[3] ~= 0 then simDR_fuel_tank_pumps[3] = 0 end
        if simDR_fuel_tank_selector ~= 4 then simDR_fuel_tank_selector = 4 end
    elseif myDR_fuel_tank_selector == 4 then -- Tank selector right rear
        if simDR_fuel_tank_pumps[0] ~= 0 then simDR_fuel_tank_pumps[0] = 0 end
        if simDR_fuel_tank_pumps[1] ~= 0 then simDR_fuel_tank_pumps[1] = 0 end
        if simDR_fuel_tank_pumps[2] ~= 0 then simDR_fuel_tank_pumps[2] = 0 end
        if simDR_fuel_tank_pumps[3] ~= 1 then simDR_fuel_tank_pumps[3] = 1 end
        if simDR_fuel_tank_selector ~= 4 then simDR_fuel_tank_selector = 4 end
    end
    --[[ Engine fuel off selection ]]
    if myDR_engine_fuel_selector == 0 then -- Both off
        if simDR_firewall_closed_l ~= 1 then simDR_firewall_closed_l = 1 end
        if simDR_firewall_closed_r ~= 1 then simDR_firewall_closed_r = 1 end
    elseif myDR_engine_fuel_selector == 1 then -- Left on, right off
        if simDR_firewall_closed_l ~= 0 then simDR_firewall_closed_l = 0 end
        if simDR_firewall_closed_r ~= 1 then simDR_firewall_closed_r = 1 end
    elseif myDR_engine_fuel_selector == 2 then -- Both on
        if simDR_firewall_closed_l ~= 0 then simDR_firewall_closed_l = 0 end
        if simDR_firewall_closed_r ~= 0 then simDR_firewall_closed_r = 0 end
    elseif myDR_engine_fuel_selector == 3 then -- Left off, right on
        if simDR_firewall_closed_l ~= 1 then simDR_firewall_closed_l = 1 end
        if simDR_firewall_closed_r ~= 0 then simDR_firewall_closed_r = 0 end
    end
    --[[ Fuel gauges ]]
    if simDR_bus_voltage[0] > 20 and myDR_fuel_indicator_front_switch == 1 then -- Front tanks
        myDR_fuel_quantity_LF = func_animation_handler(calc_fuel_level(simDR_fuel_quantity[1]),myDR_fuel_quantity_LF,2) -- LF
        myDR_fuel_quantity_RF = func_animation_handler(calc_fuel_level(simDR_fuel_quantity[2]),myDR_fuel_quantity_RF,2) -- RF
    else
        myDR_fuel_quantity_LF = func_animation_handler(0,myDR_fuel_quantity_LF,2) -- LF
        myDR_fuel_quantity_RF = func_animation_handler(0,myDR_fuel_quantity_RF,2) -- RF
    end
    if simDR_bus_voltage[0] > 20 and myDR_fuel_indicator_rear_switch == 1 then -- Rear tanks
        myDR_fuel_quantity_LR = func_animation_handler(calc_fuel_level(simDR_fuel_quantity[0]),myDR_fuel_quantity_LR,2) -- LR
        myDR_fuel_quantity_RR = func_animation_handler(calc_fuel_level(simDR_fuel_quantity[3]),myDR_fuel_quantity_RR,2) -- RR
    else
        myDR_fuel_quantity_LR = func_animation_handler(0,myDR_fuel_quantity_LR,2) -- LR
        myDR_fuel_quantity_RR = func_animation_handler(0,myDR_fuel_quantity_RR,2) -- RR
    end
    --[[ Handle autostart event ]]
    if simDR_auto_start == 1 then
        if myDR_fuel_tank_selector ~= 1 then myDR_fuel_tank_selector = 1 end
        if myDR_engine_fuel_selector ~= 2 then myDR_engine_fuel_selector = 2 end
    end
end
