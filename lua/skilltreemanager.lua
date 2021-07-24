Hooks:PostHook(SkillTreeManager,"load", "Berserker_mod_Skilltree_load", function(self, ...)
	Berserker_Help_mod:Load_Current_Profile()
	Berserker_Help_mod:Fix_Menu_Names()
end)

Hooks:PostHook(SkillTreeManager,"switch_skills", "Berserker_mod_Skilltree_switch_skills", function(...)
	Berserker_Help_mod:Load_Current_Profile()
end)