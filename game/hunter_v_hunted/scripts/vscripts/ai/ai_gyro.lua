--------------------------------------------------------------------------------------------------------
-- Gyrocopter AI
--------------------------------------------------------------------------------------------------------
function Spawn( entityKeyValues )
	-- preview pane is now spawning creatures in it, as of ~7.00
	if not IsServer() then return end

	-- force the ambient eidolon effects
	ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, thisEntity)
	StartAnimation(thisEntity, {duration=999.0, activity=ACT_DOTA_CONSTANT_LAYER, rate=1.0})
end
