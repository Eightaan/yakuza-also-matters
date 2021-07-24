local old_blm_set_revive_boost = PlayerDamage.set_revive_boost
local old_blm_revive = PlayerDamage.revive


Hooks:PostHook(PlayerDamage, "init", "Berserker_mod_PlayerDamage_init", function(self, ...)
    if managers.player:has_category_upgrade("player", "movement_speed_damage_health_ratio_threshold_multiplier") and tweak_data.blackmarket.projectiles["molotov"] then
	    if not Berserker_Help_mod._diff_mult_loaded then
		    Berserker_Help_mod.available_mult_num[1] = tweak_data.player.damage.REVIVE_HEALTH_STEPS[1]
		    Berserker_Help_mod._diff_mult_loaded = true
	    end
	    Berserker_Help_mod:Set_Player_Damage(self)
	    Berserker_Help_mod:Adjust_Health()
	end
end)

function PlayerDamage:set_revive_boost(revive_health_level)
	if not Berserker_Help_mod._current.combat_cancer then
		old_blm_set_revive_boost(self, revive_health_level)
	end
end

function PlayerDamage:revive(helped_self)
	tweak_data.player.damage.REVIVE_HEALTH_STEPS = { Berserker_Help_mod.available_mult_num[Berserker_Help_mod._current.multiplier] }
	old_blm_revive(self, helped_self)
end