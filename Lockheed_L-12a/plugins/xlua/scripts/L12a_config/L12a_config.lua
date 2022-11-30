--[[

Configuration script for S.Baugh's Lockheed L12a
By BK

]]

--[[

X-PLANE DATAREFS

]]
simDR_slider_16 = find_dataref("sim/cockpit2/switches/custom_slider_on[16]") -- Roof Windows (1 = glass)
simDR_slider_17 = find_dataref("sim/cockpit2/switches/custom_slider_on[17]") -- Modern panel
simDR_slider_18 = find_dataref("sim/cockpit2/switches/custom_slider_on[18]") -- Vintage Panel
--[[

FUNCTIONS

]]
function panel_toggle_handler()
    if myDR_config_panel_type == 0 then
        simDR_slider_17 = 0
        simDR_slider_18 = 1
    else
        simDR_slider_17 = 1
        simDR_slider_18 = 0
    end
end
function fake_handler()

end
--[[

CUSTOM DATAREFS

]]
myDR_config_panel_type = create_dataref("lockheed/L12a/panel_type","number",panel_toggle_handler) -- 0 = Vintage, 1 = Modern
