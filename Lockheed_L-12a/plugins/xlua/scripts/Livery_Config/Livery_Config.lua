--[[

Read a config file in livery folder and set datarefs

By BK

]]
--[[

SIMULATOR DATAREFS

]]
simDR_RelativePath = find_dataref("sim/aircraft/view/acf_relative_path")
simDR_LiveryPath = find_dataref("sim/aircraft/view/acf_livery_path")
simDR_RoofType = find_dataref("sim/cockpit2/switches/custom_slider_on[16]") -- Roof Windows (1 = glass)
simDR_Panel_Modern = find_dataref("sim/cockpit2/switches/custom_slider_on[17]") -- Modern panel
simDR_Panel_Vintage = find_dataref("sim/cockpit2/switches/custom_slider_on[18]") -- Vintage Panel
--[[

SIMULATOR COMMANDS

]]
--[[

CUSTOM DATAREFS

]]
--[[

VARIABLES

]]
local Debug = 0
local ConfigOptions={
{"Roof","Solid"},
{"Panel","Vintage"},
}
configfile = "liveryconfig.txt"
local InitDelay = 1 -- Delay in seconds before applying configuration
--[[

FUNCTIONS

]]
function apply_defaults()
    simDR_RoofType = 0 -- Solid roof
    simDR_Panel_Modern = 0 -- Modern panel
    simDR_Panel_Vintage = 1 -- Vintage panel
    if Debug == 1 then print("Livery Config: Default parameters set.") end
end
--[[ Configures the aircraft according to the configuration file or defaults ]]
function apply_config()
    for i=1,#ConfigOptions do
        if ConfigOptions[i][1] == "Roof" then
            if ConfigOptions[i][2] == "Solid" then simDR_RoofType = 0
            elseif ConfigOptions[i][2] == "Glass" then simDR_RoofType = 1  end
        end
        if ConfigOptions[i][1] == "Panel" then
            if ConfigOptions[i][2] == "Vintage" then simDR_Panel_Modern = 0 simDR_Panel_Vintage = 1
            elseif ConfigOptions[i][2] == "Modern" then simDR_Panel_Modern = 1 simDR_Panel_Vintage = 0  end
        end
    end
end
--[[ Splits a line at the designated delimiter, returns a table ]]
function SplitString(input,delim)
    local output = {}
    --print("Line splitting in: "..input)
    for i in string.gmatch(input,delim) do table.insert(output,i) end
    --print("Line splitting out: "..table.concat(output,",",1,#output))
    return output
end
--[[ Reads a configuration file ]]
function read_config_file(infile)
    local file = io.open(infile, "r") -- Check if file exists
    if file then
        for line in file:lines() do
            local splitline = SplitString(line,"([^=]+)")
            --print(splitline[1].." is "..splitline[2])
            for i=1,#ConfigOptions do
                if ConfigOptions[i][1] == splitline[1] then
                    ConfigOptions[i][2] = splitline[2]
                    if Debug == 1 then print("Livery Config: "..ConfigOptions[i][1].." changed to "..ConfigOptions[i][2]) end
                end
            end
        end
        if Debug == 1 then print("Livery Config: Config file parsed.") end
        file:close()
    else
        if Debug == 1 then print("Livery Config:  No configuration file found; defaults retained.") end
    end
end
--[[

]]
function ConfigFileWrapper()
    if simDR_LiveryPath == "" then read_config_file(tostring(simDR_RelativePath):match("(.*[/\\])")..configfile) else read_config_file(simDR_LiveryPath..configfile) end
end
--[[

]]
function Livery_Config_Handler(phase, duration)
    if phase == 0 then
        apply_defaults()
        ConfigFileWrapper()
        apply_config()
    end
end
--[[

CUSTOM COMMANDS

]]
create_command("xlua/Read_Livery_Config","Read a livery configuration file",Livery_Config_Handler)
--[[

X-PLANE CALLBACKS

]]
--[[ X-Plane session start ]]
function flight_start()
    apply_defaults()
    ConfigFileWrapper()
    run_after_time(apply_config,InitDelay)
end
--[[ X-Plane session runtime ]]
--function after_physics()
--end
--[[ X-Plane session end/ user aircraft unload ]]
--function aircraft_unload() -- Currently not needed

--end

