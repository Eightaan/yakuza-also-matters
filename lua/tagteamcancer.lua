local BLM_old_tag_team_tagged_function = PlayerAction.TagTeamTagged.Function

PlayerAction.TagTeamTagged.Function = function (...)
	if not Berserker_Help_mod._current.tag_team_cancer then
		BLM_old_tag_team_tagged_function(...)
	end
end