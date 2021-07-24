if not _G.LowHP then
	_G.LowHP = _G.LowHP or {}
	LowHP._current = {}
	LowHP._player_damage = nil
end

function LowHP:Load()
	local lowhp_maps = Global.game_settings.level_id == 'roberts'
	or Global.game_settings.level_id == 'ukrainian_job' 
	or Global.game_settings.level_id == 'sand' 
	or Global.game_settings.level_id == 'framing_frame_1' 
	or Global.game_settings.level_id == 'framing_frame_2' 
	or Global.game_settings.level_id == 'framing_frame_3' 
	or Global.game_settings.level_id == 'dark' 
	or Global.game_settings.level_id == 'four_stores' 
	or Global.game_settings.level_id == 'bex' 
	or Global.game_settings.level_id == 'fex' 
	or Global.game_settings.level_id == 'nightclub' 
	or Global.game_settings.level_id == 'kosuji' 
	or Global.game_settings.level_id == 'arm_for' 
	or Global.game_settings.level_id == 'sah' 
	or Global.game_settings.level_id == 'chas' 
	or Global.game_settings.level_id == 'crojob2' 
	or Global.game_settings.level_id == 'jewelry_store' 
	or Global.game_settings.level_id == 'friend' 
	or Global.game_settings.level_id == 'welcome_to_the_jungle_2' 
	or Global.game_settings.level_id == 'firestarter_1' 
	or Global.game_settings.level_id == 'firestarter_2' 
	or Global.game_settings.level_id == 'firestarter_3' 
	or Global.game_settings.level_id == 'gallery' 
	or Global.game_settings.level_id == 'pex' 
	or Global.game_settings.level_id == 'mex' 
	or Global.game_settings.level_id == 'cage' 
	or Global.game_settings.level_id == 'election_day_1' 
	or Global.game_settings.level_id == 'election_day_2' 
	or Global.game_settings.level_id == 'family' 
	or Global.game_settings.level_id == 'mus' 
	or Global.game_settings.level_id == 'branchbank' 
	or Global.game_settings.level_id == 'hox_3'
	
	if lowhp_maps then
		self._current = {}
		self:Set_Default(self._current)
	end
	self:Adjust_Health()
end

function LowHP:Set_Default(profile)
	profile.multiplier = 1
end

function LowHP:Set_Player_Damage(plDam)
	self._player_damage = plDam
	self:Adjust_Health()
end

function LowHP:Adjust_Health()
	if self._player_damage and next(self._current) ~= nil then
	    self._player_damage._max_health_reduction = 0.001
		local new_max_health = self._player_damage:_max_health() * self._player_damage._max_health_reduction
		local health = math.clamp(self._player_damage:get_real_health(), 0, new_max_health)
		self._player_damage:set_health(health)
	end
end

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_LowHP", function(menu_manager)
	LowHP:Load()
end)