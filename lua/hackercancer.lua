Hooks:PostHook(PlayerInventory,"_start_feedback_effect", "Berserker_mod_start_feedback_effect", function(self, ...)
	local is_player = managers.player:player_unit() == self._unit
	if not is_player and self._jammer_data and self._jammer_data.heal and Berserker_Help_mod._current.hacker_cancer then
		self._jammer_data.heal = 0
	end
end )