

if HVHConvars == nil then
  HVHConvars = class({})
end

require("internal/convars")
require("../hvh_constants")

function HVHConvars:Setup()
	self:RegisterConvars()
	self:RegisterCommands()
end

function HVHConvars:RegisterConvars()
	-- Register custom console variables here.
  	local debugOutput = 0
  	if HVH_DEBUG_OUTPUT then
  		debugOutput = 1
  	end

  	Convars:RegisterConvar("hvh_debug_output", tostring(debugOutput), "Set to 1 for debug output. Default: 0", 0)
end


function HVHConvars:RegisterCommands()
	-- Register custom console command handlers here.

  	-- this is already built into the engine
  	--Convars:RegisterCommand( "set_time_of_day", Dynamic_Wrap(self, 'ConvarSetTimeOfDay'), "Sets the time of day to the indicated value.", FCVAR_CHEAT )
end