-- TODO: definite issues if multiple Night Stalkers are running around

require("lib/timers")
require("circular_queue")
require("hvh_utils")

---------------------------------- applies vision
function VisionThinker(keys)
	local caster  = keys.caster
	if not caster:IsRealHero() then return end -- illusions don't get this

	local ability   = keys.ability
	local dummy_str = keys.dummy_str
	local team      = caster:GetTeam()
	local nv_radius = ability:GetSpecialValueFor("night_vision_radius")

    local heroList = HeroList:GetAllHeroes()
    for _,target in pairs(heroList) do
    	-- target.vis_dummy_index references the associated vision dummy unit
        if not GameRules:IsDaytime() and IsValidVisionTarget(caster, target, nv_radius) then
        	if target.vis_dummy_index == nil then
        		CreateVisionDummy(target, dummy_str, team)
	        else
	        	MoveVisionDummy(target)
	        end

	    -- it's day, or target is not in range, or no longer in range
	    elseif target.vis_dummy_index ~= nil then
	    	KillVisionDummy(target)
	    end
    end
end

-- a valid target is not the caster, is alive, is in range, and cannot be seen by caster's team
function IsValidVisionTarget(caster, target, nv_radius)
    if  caster ~= target and
    	target:IsAlive() and
    	caster:GetRangeToUnit(target) < nv_radius and
    	not caster:CanEntityBeSeenByMyTeam(target) then
    		return true
    else
      		return false
	end
end

function CreateVisionDummy(target, dummy_str, caster_team)
	local target_pos = target:GetAbsOrigin()
	local vis_dummy = CreateUnitByName(dummy_str, target_pos, false, nil, nil, caster_team)
	target.vis_dummy_index = vis_dummy:entindex()
end

-- vision dummy follows the target
function MoveVisionDummy(target)
	local target_pos = target:GetAbsOrigin()
	local vis_dummy = EntIndexToHScript(target.vis_dummy_index)
	vis_dummy:SetOrigin(target_pos)
end

function KillVisionDummy(target)
	local vis_dummy = EntIndexToHScript(target.vis_dummy_index)
	vis_dummy:ForceKill(true)
	target.vis_dummy_index = nil
end	    	

function OnDeath_KillAllVisionDummies(keys)
    local heroList = HeroList:GetAllHeroes()
    for _,target in pairs(heroList) do
    	if target.vis_dummy_index ~= nil then
    		KillVisionDummy(target)
    	end
    end
end

---------------------------------- applies speed
function SpeedThinker(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_speed = keys.mod_speed

	if GameRules:IsDaytime() and caster:HasModifier(mod_speed) then
		caster:NotifyWearablesOfModelChange(true)
		caster:RemoveModifierByName(mod_speed)
	elseif not GameRules:IsDaytime() and not caster:HasModifier(mod_speed) then
		caster:NotifyWearablesOfModelChange(true)
		ability:ApplyDataDrivenModifier(caster, caster, mod_speed, {})
	end

end

--------------------------------- applies invis

function OnAttackLanded(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_invis = keys.mod_invis
	local delay = keys.delay

	ResetInvisDelay(caster, ability, mod_invis, delay)
end

function OnAbilityExecuted(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_invis = keys.mod_invis
	local delay = keys.delay

	ResetInvisDelay(caster, ability, mod_invis, delay)
end

function OnUnitMoved(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_invis = keys.mod_invis
	local delay = keys.delay

	if GameRules:IsDaytime() then
		ResetInvisDelay(caster, ability, mod_invis, delay)
	end
end

function OnTakeDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_invis = keys.mod_invis
	local delay = keys.delay
	local attack_damage = keys.attack_damage
	local minimum_dmg_to_break_invis = keys.minimum_dmg_to_break_invis

	if attack_damage >= minimum_dmg_to_break_invis then
		ResetInvisDelay(caster, ability, mod_invis, delay)
	end
end

function ResetInvisDelay(caster, ability, mod_invis, delay)
	if caster:HasModifier(mod_invis) then
		caster:RemoveModifierByName(mod_invis)
	end

  local gameTime = GameRules:GetGameTime()
  local timerName = "NSInvisDelay" .. caster:entindex()

  -- debug function
  --if caster.InvisDelayEndTime == nil then
  --  Timers:CreateTimer(0.1, function()
  --    print(caster.InvisDelayEndTime - GameRules:GetGameTime())
  --    return 0.1
  --  end)
  --end

  -- if uninitialized or delay exceeds previous delay, then reset current countdown
  if caster.InvisDelayEndTime == nil or (gameTime+delay) >= caster.InvisDelayEndTime then
    ability:StartCooldown(delay)
    caster.InvisDelayEndTime = gameTime + delay
    Timers:RemoveTimer(timerName)
    Timers:CreateTimer(timerName, {
      useGameTime = true,
      endTime = delay,
      callback = function()
     	  ability:ApplyDataDrivenModifier(caster, caster, mod_invis, {})
        return nil
  	end})
  end
end

--------------------------------- applies killing spree effects

if HVHDreadHunterKillEffect == nil then
  HVHDreadHunterKillEffect = class({})
end

function RegisterKillEffect(keys)
  local target = keys.caster
  if target:IsRealHero() then
    local listenerID = ListenToGameEvent('entity_killed', Dynamic_Wrap(HVHDreadHunterKillEffect, "KillEffect"), HVHDreadHunterKillEffect)
    HVHDreadHunterKillEffect:SetKilledEventListenerID(listenerID)
  end
end

function UnregisterKillEffect(keys)
  local target = keys.caster
  if target:IsRealHero() then
    local listenerID = HVHDreadHunterKillEffect:GetKilledEventListenerID()
    StopListeningToGameEvent(listenerID)
  end
end

function HVHDreadHunterKillEffect:SetKilledEventListenerID(id)
  self._killedEventListenerID = id
end

function HVHDreadHunterKillEffect:GetKilledEventListenerID()
  return self._killedEventListenerID
end

function HVHDreadHunterKillEffect:KillEffect(keys)
--if not GameRules:IsDaytime() then
  local attacker = EntIndexToHScript(keys.entindex_attacker)
  local target = EntIndexToHScript(keys.entindex_killed)

  local isAttackerNightStalker = IsEntityNightStalker(attacker)
  local isTargetSniper = IsEntitySniper(target)

  if isAttackerNightStalker and isTargetSniper then
    self:AttachEffectsForTargets(attacker, target, attacker)
  elseif IsEntityNightStalkerIllusion(attacker) and isTargetSniper then
    local owningHero = GetOwningHeroForIllusion(attacker)
    if IsEntityNightStalker(owningHero) then
      self:AttachEffectsForTargets(attacker, target, owningHero)
    end
  end
--end
end

function HVHDreadHunterKillEffect:AttachEffectsForTargets(attacker, victim, regenTarget)
  self:AttachBloodRushParticle(attacker, victim)
  local ability = attacker:FindAbilityByName("night_stalker_hunter_in_the_night_hvh")
  self:ApplyRegenMod(regenTarget, ability)
end

function HVHDreadHunterKillEffect:AttachBloodRushParticle(caster, target)
  local bloodRushParticle = ParticleManager:CreateParticle("particles/night_stalker_blood_rush_hvh.vpcf", PATTACH_ROOTBONE_FOLLOW, caster)
  ParticleManager:SetParticleControl(bloodRushParticle, 1, target:GetAbsOrigin())
end

function HVHDreadHunterKillEffect:AttachKillVacuumParticle(caster, target)
  local vacuumParticle = ParticleManager:CreateParticle("particles/night_stalker_blood_rush_vacuum_hvh.vpcf", PATTACH_ROOTBONE_FOLLOW, caster)
  ParticleManager:SetParticleControl(vacuumParticle, 1, target:GetAbsOrigin())

  Timers:CreateTimer(2, function()
    ParticleManager:DestroyParticle(vacuumParticle, true)
  end)
end

function HVHDreadHunterKillEffect:AttachKillExplosionParticle(target)
  local explosionParticle = ParticleManager:CreateParticle("particles/night_stalker_blood_rush_hvh.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)

  Timers:CreateTimer(1.5, function()
    ParticleManager:DestroyParticle(explosionParticle, true)
  end)
end

function HVHDreadHunterKillEffect:ApplyRegenMod(caster, ability)
  ability:ApplyDataDrivenModifier(caster, caster, "modifier_dread_hunter_kill_regen", nil)
end

--------------------------------- changes the killing spree counter

if HVHDreadHunterKillEffectRegenCounter == nil then
  HVHDreadHunterKillEffectRegenCounter = class({})
  HVHDreadHunterKillEffectRegenCounter._buffApplicationTimeQueue = HVHCircularQueue(10)
end

function IncrementKillEffectCounter(keys)
  HVHDreadHunterKillEffectRegenCounter:IncrementCounter(keys)
end

function DecrementKillEffectCounter(keys)
  HVHDreadHunterKillEffectRegenCounter:DecrementCounter(keys)
end

function HVHDreadHunterKillEffectRegenCounter:IncrementCounter(keys)
  local caster = keys.caster
  local stackModName = keys.counterModifier
  local currentStackCount = HVHDreadHunterKillEffectRegenCounter:_GetModifierStackCount(caster, stackModName)
  local ability = keys.ability
  local maxDuration = keys.duration

  local newStackCount = currentStackCount + 1
  HVHDreadHunterKillEffectRegenCounter._buffApplicationTimeQueue:Store(GameRules:GetGameTime())
  local buffDurationToDisplay = HVHDreadHunterKillEffectRegenCounter:_GetCurrentBuffTimeToDisplay(maxDuration)
  if buffDurationToDisplay <= 0 then
    buffDurationToDisplay = maxDuration
  end
  HVHDreadHunterKillEffectRegenCounter:_SetupTimedModifier(caster, ability, stackModName, buffDurationToDisplay, newStackCount)
end

function HVHDreadHunterKillEffectRegenCounter:DecrementCounter(keys)
  local caster = keys.caster
  local stackModName = keys.counterModifier
  local ability = keys.ability
  local currentStackCount = HVHDreadHunterKillEffectRegenCounter:_GetModifierStackCount(caster, stackModName)
  local maxDuration = keys.duration

  HVHDebugPrint("Decrementing night stalker blood rush counter.")

  local newStackCount = currentStackCount - 1
  HVHDreadHunterKillEffectRegenCounter._buffApplicationTimeQueue:Pop()

  if newStackCount > 0 then
    local buffDurationToDisplay = HVHDreadHunterKillEffectRegenCounter:_GetCurrentBuffTimeToDisplay(maxDuration)
    HVHDreadHunterKillEffectRegenCounter:_SetupTimedModifier(caster, ability, stackModName, buffDurationToDisplay, newStackCount)
  else
    caster:RemoveModifierByName(stackModName)
  end
end

function HVHDreadHunterKillEffectRegenCounter:_GetCurrentBuffTimeToDisplay(maxDuration)
  local timeToDisplay = 0
  if not HVHDreadHunterKillEffectRegenCounter._buffApplicationTimeQueue:IsEmpty() then
    local oldestBuffTime = HVHDreadHunterKillEffectRegenCounter._buffApplicationTimeQueue:Peek()
    local currentTime = GameRules:GetGameTime()
    local elapsedTime = currentTime - oldestBuffTime
    timeToDisplay = maxDuration - elapsedTime
  else
    HVHDebugPrint("Tried to get a night stalker buff time to display when the buff time queue is empty.")
  end

  return timeToDisplay
end

function HVHDreadHunterKillEffectRegenCounter:_GetModifierStackCount(caster, modifierName)
  local modifierCount = self._buffApplicationTimeQueue:GetCount()
  return modifierCount
end

function HVHDreadHunterKillEffectRegenCounter:_RemoveModifier(caster, modifierName)
  caster:RemoveModifierByName(modifierName)
end

function HVHDreadHunterKillEffectRegenCounter:_SetupTimedModifier(caster, ability, modifierName, duration, currentStacks)
  HVHDreadHunterKillEffectRegenCounter:_RemoveModifier(caster, modifierName)
  ability:ApplyDataDrivenModifier(caster, caster, modifierName, {Duration = duration })
  HVHDebugPrint(string.format("Applying blood rush modifier to night stalker for %s seconds with stack count: %s", duration, currentStacks))
  caster:SetModifierStackCount(modifierName, caster, currentStacks)
end