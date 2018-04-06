if HVHCycles == nil then
	HVHCycles = class({})

	-- SetTimeOfDay() takes a float from 0.0 to 1.0, where ~0.25 is sunrise and ~0.75 is sunset
	TIME_NEXT_DAWN    = 0.25
	TIME_NEXT_EVENING = 0.75
end

-- Cycle: Full day + night
-- Half-cycle: Either day OR night

-- accessible by panorama
function HVHCycles:SetupCycleTimer()
  GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(self, "OrderFilter"), self)

  CustomNetTables:SetTableValue("cycle", "TimeRemaining", { value = 60 })
  CustomNetTables:SetTableValue("cycle", "IsDaytime", { value = false })

  local t = 1.0
  Timers:CreateTimer(t, function()
    CustomNetTables:SetTableValue("cycle", "IsDaytime", { value = GameRules:IsDaytime() })
    return t
  end)
end

-- If NS issues a pickup order on a sun shard, change the order to attack/deny target instead
function HVHCycles:OrderFilter(event)
  if event.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM then --and event.entindex_target == "item_sun_shard_hvh" then

    -- catch errors
    if not event.entindex_target or not EntIndexToHScriptNillable(event.entindex_target) then
      return true
    end
    
    local worldItem = EntIndexToHScriptNillable(event.entindex_target)
    local itemContained = worldItem:GetContainedItem()
    local itemName = itemContained:GetName()

    if itemName == "item_sun_shard_hvh" then
      for _,unitNum in pairs(event.units) do
        local unit =  EntIndexToHScriptNillable(unitNum)
        if unit:GetTeam() ~= DOTA_TEAM_GOODGUYS then
          event.order_type = DOTA_UNIT_ORDER_ATTACK_TARGET
        end
      end
    end
  end

  --Return true by default to keep all other orders the same
  return true
end

-- Allows manual adjustment of day/night durations
function HVHCycles:SetupFastTime()
  local mode = GameRules:GetGameModeEntity()

  -- dota starts during day, but we can instead start at night
  if START_WITH_DAY then
  	mode.HalfCycleTimeRemaining = self:GenerateHalfCycleTime(START_WITH_DAY)
  else
  	self:TransitionToNextHalfCycle() -- this will set mode.HalfCycleTimeRemaining (global) for us
  end

  Timers:CreateTimer(1.0, function()
    --print("starting clock")
    self:StartClockHUD()
  end)
 
  local t = 1.0
  Timers:CreateTimer(t, function()
    mode.HalfCycleTimeRemaining = mode.HalfCycleTimeRemaining - t
    CustomNetTables:SetTableValue("cycle", "TimeRemaining", { value = mode.HalfCycleTimeRemaining })
    --print(mode.HalfCycleTimeRemaining .. " seconds left.")
    if mode.HalfCycleTimeRemaining <= 0.0 then
      self:TransitionToNextHalfCycle()
      --self:StartClockHUD()
    end
    return t
  end)
end

function HVHCycles:StartClockHUD()
  CustomGameEventManager:Send_ServerToAllClients("display_timer",
      {msg="Remaining", duration=0, mode=0, endfade=false, position=1, warning=5, paused=false, sound=true} )
end


function HVHCycles:GenerateHalfCycleTime(day)
  local time,rng = 0,0

  -- if phoenix disabled, always use night duration for both day and night
  if HVHGameMode.HostOptions["DisablePhoenix"] then
    rng = RandomFloat(-1 * NIGHT_SECONDS_RANDOM_EXTRA, NIGHT_SECONDS_RANDOM_EXTRA)
    time = NIGHT_SECONDS + rng
  elseif day then
    rng = RandomFloat(-1 * DAY_SECONDS_RANDOM_EXTRA, DAY_SECONDS_RANDOM_EXTRA)
    time = DAY_SECONDS + rng
  else
    rng = RandomFloat(-1 * NIGHT_SECONDS_RANDOM_EXTRA, NIGHT_SECONDS_RANDOM_EXTRA)
    time = NIGHT_SECONDS + rng
  end

  return time
end

function HVHCycles:TransitionToNextHalfCycle()
  local mode = GameRules:GetGameModeEntity()
  local extraSec = math.abs(mode.HalfCycleTimeRemaining) -- convert a deficit to a positive
  local nextTimeTransition = nil

  -- if it's day, generate time for night half-cycle (false)
  -- if it's night, then generate time for day half-cycle (true)
  if GameRules:IsDaytime() then
	nextTimeTransition = TIME_NEXT_EVENING
    mode.HalfCycleTimeRemaining = self:GenerateHalfCycleTime(false) + extraSec
  else
    nextTimeTransition = TIME_NEXT_DAWN
    mode.HalfCycleTimeRemaining = self:GenerateHalfCycleTime(true) + extraSec
  end

  -- finally, do the transition from current day/night to next day/night
  GameRules:SetTimeOfDay(nextTimeTransition) 
end

-- heal the NS for a small percentage of max hp
function HVHCycles:MoonRockPickup(unit)
  if HVHGameMode.HostOptions["DisablePhoenix"] then return end

  local hp = unit:GetMaxHealth() * NS_CHEST_HEAL
  unit:Heal(hp, unit)
  PopupHealing(unit, hp)

  local partString = "particles/moonrock_heal.vpcf"
  local sfxString = "n_creep_ForestTrollHighPriest.Heal"
  ParticleManager:CreateParticle(partString,  PATTACH_ABSORIGIN_FOLLOW, unit )
  unit:EmitSound(sfxString) 
end

-- grant a sun shard item, usable on phoenix
function HVHCycles:SunShardPickup(unit)
  if HVHGameMode.HostOptions["DisablePhoenix"] then return end

  local r = RandomFloat(0.0, 1.0)
  if r <= SUN_SHARD_PICKUP_CHANCE then
    HVHItemUtils:AddItemOrLaunchIt(unit, "item_sun_shard_hvh")
  	--unit:AddItemByName("item_sun_shard_hvh")
    local partString = "particles/ui/ui_generic_treasure_impact.vpcf"
    local sfxString = "ui.treasure_reveal"
    ParticleManager:CreateParticle(partString,  PATTACH_ABSORIGIN_FOLLOW, unit )
    unit:EmitSound(sfxString)
  end
end