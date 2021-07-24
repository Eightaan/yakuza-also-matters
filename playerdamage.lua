Hooks:PostHook(PlayerDamage, "init", "LowHP_PlayerDamage_init", function(self, ...)
    if managers.player:has_category_upgrade("player", "movement_speed_damage_health_ratio_threshold_multiplier") and managers.blackmarket:equipped_grenade() == "molotov" then
	    LowHP:Set_Player_Damage(self)
	    LowHP:Adjust_Health()
	end
end)
