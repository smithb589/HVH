---------------------------------- applies speed
function SpeedThinker(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_speed = keys.mod_speed

	if not GameRules:IsDaytime() then
		ability:ApplyDataDrivenModifier(caster, caster, mod_speed, {})
	else
		if caster:HasModifier(mod_speed) then
			caster:RemoveModifierByName(mod_speed)
		end
	end

end

--------------------------------- applies invis

function OnAttackLanded(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_invis = keys.mod_invis

	ResetInvisDelay(caster, ability, mod_invis)
end

function OnAbilityExecuted(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_invis = keys.mod_invis

	ResetInvisDelay(caster, ability, mod_invis)
end

function OnUnitMoved(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_invis = keys.mod_invis
	local timerName = "NSInvisDelay" .. caster:entindex()

	if GameRules:IsDaytime() then
		ResetInvisDelay(caster, ability, mod_invis)
	-- ugly fix
	--[[elseif caster:HasModifier(mod_invis) --mine
	  and not caster:HasModifier("modifier_invisibility") --hardcoded
	  and Timers.timers[timerName] == nil then
		ResetInvisDelay(caster, ability, mod_invis)]]
	end
end

function ResetInvisDelay(caster, ability, mod_invis)
	if caster:HasModifier(mod_invis) then
		caster:RemoveModifierByName(mod_invis)
	end

	local timerName = "NSInvisDelay" .. caster:entindex()

	Timers:RemoveTimer(timerName)

    Timers:CreateTimer(timerName, {
      useGameTime = true,
      endTime = ability:GetSpecialValueFor("invis_delay"),
      callback = function()
      	ability:ApplyDataDrivenModifier(caster, caster, mod_invis, {})
	  end
	})
	
end




--[[function InvisThinker(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_invis = keys.mod_invis
end]]

--[[
function OnOrder(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_invis = keys.mod_invis
	local timerName = "NSInvisDelay" .. caster:entindex()

	if GameRules:IsDaytime() then
		ResetInvisDelay(caster, ability, mod_invis)

	-- ugly fix
	elseif caster:HasModifier(mod_invis) --mine
	  and not caster:HasModifier("modifier_invisibility") --hardcoded
	  and Timers.timers[timerName] == nil then
		ResetInvisDelay(caster, ability, mod_invis)

	end
end]]

--[[DOTA_UNIT_ORDER_NONE
DOTA_UNIT_ORDER_MOVE_TO_POSITION 
DOTA_UNIT_ORDER_MOVE_TO_TARGET 
DOTA_UNIT_ORDER_ATTACK_MOVE
DOTA_UNIT_ORDER_ATTACK_TARGET
DOTA_UNIT_ORDER_CAST_POSITION
DOTA_UNIT_ORDER_CAST_TARGET
DOTA_UNIT_ORDER_CAST_TARGET_TREE
DOTA_UNIT_ORDER_CAST_NO_TARGET
DOTA_UNIT_ORDER_CAST_TOGGLE
DOTA_UNIT_ORDER_HOLD_POSITION
DOTA_UNIT_ORDER_TRAIN_ABILITY
DOTA_UNIT_ORDER_DROP_ITEM
DOTA_UNIT_ORDER_GIVE_ITEM
DOTA_UNIT_ORDER_PICKUP_ITEM
DOTA_UNIT_ORDER_PICKUP_RUNE
DOTA_UNIT_ORDER_PURCHASE_ITEM
DOTA_UNIT_ORDER_SELL_ITEM
DOTA_UNIT_ORDER_DISASSEMBLE_ITEM
DOTA_UNIT_ORDER_MOVE_ITEM
DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO
DOTA_UNIT_ORDER_STOP
DOTA_UNIT_ORDER_TAUNT
DOTA_UNIT_ORDER_BUYBACK
DOTA_UNIT_ORDER_GLYPH
DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH
DOTA_UNIT_ORDER_CAST_RUNE]]