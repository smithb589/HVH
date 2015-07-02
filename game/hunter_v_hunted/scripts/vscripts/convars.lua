

if HVHConvars == nil then
  HVHConvars = class({})
end

require("internal/convars")

function HVHConvars:RegisterConvars()
	-- Register custom console command handlers here.
  	
  	-- this is already built into the engine
  	--Convars:RegisterCommand( "set_time_of_day", Dynamic_Wrap(self, 'ConvarSetTimeOfDay'), "Sets the time of day to the indicated value.", FCVAR_CHEAT )
end


