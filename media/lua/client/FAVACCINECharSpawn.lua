local MOD_ID = "SVACCINESPLUS";
local MOD_NAME = "Simple Vaccines Plus";
local MOD_VERSION = '1.0';
local MOD_AUTHOR = "BlueBerry Gravy and MacedonianMafia";
local MOD_DESCRIPTION = "Adds easier ways to level first aid skill and craftable vaccines to help prevent zombie infections and possibly cure them"


local function info()
	print("MOD Loaded: " .. MOD_NAME .. " by " .. MOD_AUTHOR .. " (v" .. MOD_VERSION .. ")");
end


Events.OnGameBoot.Add(info);
