-- If new options, search for FIXME

local function func_and(bool_a, bool_b)
	if type(bool_b) ~= 'boolean' then
			return bool_a
	end
	
	return bool_a and bool_b
end

local function func_min(int_a, int_b)
	if type(int_b) ~= 'number' then
		return int_a
	end
	return math.min(int_a, int_b)
end

if not _G.Berserker_Help_mod then
	_G.Berserker_Help_mod = _G.Berserker_Help_mod or {}
	Berserker_Help_mod._path = ModPath
	Berserker_Help_mod._data_path = SavePath .. "berserker_live_matters.txt"
	Berserker_Help_mod.available_mult_num = {1,0.1,0.001}
	Berserker_Help_mod._settings = {}
	Berserker_Help_mod._settings.default = {}
	Berserker_Help_mod._settings.profiles = {}
	Berserker_Help_mod._current = {}
	Berserker_Help_mod._host_restrictions = {}
	Berserker_Help_mod._restrictions = {}
	Berserker_Help_mod._settings.force_host_values = false
	Berserker_Help_mod._version = "1.4"
	Berserker_Help_mod._client_answer = {{}, {}, {}, {}}
	Berserker_Help_mod._player_damage = nil
	Berserker_Help_mod._diff_mult_loaded = nil
	Berserker_Help_mod._enabled = true
	Berserker_Help_mod._network = {}
	Berserker_Help_mod._network.id = "BerserkerLiveMatters"
	Berserker_Help_mod._network.confirm = "OK"
	Berserker_Help_mod._network.force_host = "HostReq"
	Berserker_Help_mod._legacy = {}
	Berserker_Help_mod._legacy._disable_msg = "BLM: Disable mod"
	Berserker_Help_mod._legacy._disable_dlg = "BLM: Show disable message"
	Berserker_Help_mod._legacy._enable_dlg = "BLM: Enable mod"
end

function Berserker_Help_mod:Load()
	local file = io.open(self._data_path, "r")
	if file then
		local decoded = json.decode(file:read("*all")) or {}
		for k, v in pairs(decoded) do
			self._settings[k] = v
		end
		file:close()
		self:Upgrade()
	else
		self:Set_Default_Settings()
	end
	self:On_Setting_Changed(true)
	self:Load_Current_Profile()
end

function Berserker_Help_mod:Save()
	local file = io.open(self._data_path, "w+")
	if file then
		file:write(json.encode(self._settings))
		file:close()
	end
end


function Berserker_Help_mod:Set_Default_Settings()
	self._settings.force_host_values = self._settings.force_host_values or false
	self._settings.default = self._settings.default or {}
	self._settings.profiles = self._settings.profiles or {}
	self:Fill_Default()
	local profile_table = self._settings.profiles
	while #profile_table < #tweak_data.skilltree.skill_switches do
		self:Add_Profile(profile_table)
	end
	self._settings.version = self._version
end

function Berserker_Help_mod:Fill_Default()
	local profile = self._settings.default
	if profile.multiplier == nil then
		profile.multiplier = 1
	end
	if profile.fixed == nil then
		profile.fixed = false
	end
	if profile.combat_cancer == nil then
		profile.combat_cancer = true
	end
	if profile.hacker_cancer == nil then
		profile.hacker_cancer = true
	end
	if profile.tag_team_cancer == nil then
		profile.tag_team_cancer = true
	end
end

function Berserker_Help_mod:Set_Default(profile)
	if not self._settings.default then
		self._settings.default = {}
	end
	local default_vals = self._settings.default

	-- FIXME
	profile.multiplier = default_vals.multiplier or 1
	profile.fixed = default_vals.fixed and true or false
	profile.combat_cancer = default_vals.combat_cancer and true or false
	profile.hacker_cancer = default_vals.hacker_cancer and true or false
	profile.tag_team_cancer = default_vals.tag_team_cancer and true or false
end

function Berserker_Help_mod:Set_Disabled(profile)
	-- FIXME
	profile.multiplier = 1
	profile.fixed = false
	profile.combat_cancer = false
	profile.hacker_cancer = false
	profile.tag_team_cancer = false
end

function Berserker_Help_mod:Add_Profile(profile_table)
	local new_profile = {}
	new_profile.use_default = true
	new_profile.force = false
	self:Set_Default(new_profile)
	table.insert(profile_table, new_profile)
end


function Berserker_Help_mod:Upgrade()
	-- FIXME
	if not self._settings.version then
		-- 1.3 or lower
		local default_profile = {}
		default_profile.multiplier = self._settings["multiplier"]
		default_profile.combat_cancer = self._settings["combat_cancer"]
		default_profile.hacker_cancer = self._settings["hacker_cancer"]
		default_profile.fixed = self._settings.fixed
		local disable = self._settings.disable
		local active = self._settings.active or 3
		self._settings = {}
		self._settings.default = default_profile
		self._settings.force_host_values = disable
		self:Set_Default_Settings()

		if active ~= 3 then
			if active == 1 then
				for _, profile in ipairs(self._settings.profiles) do
					profile.force = true
				end
			end

			local dialog_data = {
				title = managers.localization:text("Berserker_Help_mod_main_menu_title"),
				text = managers.localization:text("Berserker_Help_mod_upgrade_problem")
			}
			local ok_button = {
				text = managers.localization:text("dialog_ok")
			}
			dialog_data.button_list = {
				ok_button
			}
			managers.system_menu:add_init_show(dialog_data)
		end
		self:Save()
	else
		if self._version ~= self._settings.version then
			-- Error; we come from the future?????
			-- In that case do nothing and hope for the best
			local dialog_data = {
				title = managers.localization:text("Berserker_Help_mod_main_menu_title"),
				text = managers.localization:text("Berserker_Help_mod_upgrade_error")
			}
			local ok_button = {
				text = managers.localization:text("dialog_ok")
			}
			dialog_data.button_list = {
				ok_button
			}
			managers.system_menu:add_init_show(dialog_data)
		end
	end
end

function Berserker_Help_mod:Load_Current_Profile()
	local profile_nr = managers.skilltree and managers.skilltree._global and managers.skilltree._global.selected_skill_switch or 1
	local current_profile = self._settings.profiles[managers.skilltree._global.selected_skill_switch]
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

	if lowhp_maps and managers.player:has_category_upgrade("player", "movement_speed_damage_health_ratio_threshold_multiplier") then
		if not current_profile or current_profile.use_default then
			self._current = {}
			self:Set_Default(self._current)
		else
			self._current = table.deep_map_copy(current_profile)
		end
	end

	for id, restriction in pairs(self._restrictions) do
		if self._current[id] then
			self._current[id] = restriction.func(self._current[id], restriction.val)
		end
	end
	self:Adjust_Health()
end


function Berserker_Help_mod:Get_Current_Restrictions()
	local new_restrictions = {}
	local fixed = self._settings.default.fixed
	local multiplier = self._settings.default.multiplier
	for _, profile in ipairs(self._settings.profiles) do
		if not profile.use_default then
			fixed = fixed or profile.fixed
			multiplier = math.max(multiplier, profile.multiplier)
		end
	end
	if not fixed then
		new_restrictions.fixed = false
	end
	if multiplier < 3 then
		new_restrictions.multiplier = multiplier
	end

	return new_restrictions
end

function Berserker_Help_mod:On_Setting_Changed(stealth)
	-- FIXME
	local new_restrictions = {}
	if self._settings.force_host_values then
		new_restrictions = self:Get_Current_Restrictions()
	end
	local diff = false
	for id, val in pairs(new_restrictions) do
		diff = diff or val ~= self._host_restrictions[id]
	end
	for id, val in pairs(self._host_restrictions) do
		diff = diff or val ~= new_restrictions[id]
	end
	if diff then
		self._host_restrictions = new_restrictions
		for i=2,4 do
			self:Send_Disable_Message(i, not stealth)
		end
	end
end

function Berserker_Help_mod:Fix_Menu_Names(overwrite)
	if not (managers.skilltree and managers.skilltree._global and managers.skilltree._global.skill_switches) then
		return
	end

	-- Fix names in menu
	local skill_switches =  managers.skilltree._global.skill_switches
	local menu_items = (MenuHelper:GetMenu("Berserker_Help_mod_menu_profiles"))._items
	local i = 1
	while i <= #skill_switches and i < #menu_items do
		local params = menu_items[i]._parameters
		local name = managers.skilltree:get_skill_switch_name(i)
		params.text_id = name
		params.help_id = managers.localization:text("Berserker_Help_mod_indiv_profile_menu_desc", {skillset_name = name})
		params.localize = false
		params.localize_help = false
		i = i + 1
	end
end

local _count_front = 0
local _count_behind = 0

function Berserker_Help_mod:Check_Client_Answers()
	_count_behind = _count_behind + 1
	if _count_behind < _count_front then
		return
	end
	for i=2,4 do
		local response = self._client_answer[i]
		local peer =  managers.network:session() and managers.network:session():peer(i)
		if not peer or not response.active then
			return
		end

		response.active = false

		if not response.version then
			-- Client has version 1.3 or lower / or failed to answer
			if next(self._host_restrictions) == nil then
				if response.show_prompt then
					peer:send("send_chat_message", 4, self._legacy._enable_dlg)
				end
			else
				if response.show_prompt then
					peer:send("send_chat_message", 4, self._legacy._disable_dlg)
				end
				peer:send("send_chat_message", 4, self._legacy._disable_msg)
			end
		else
			-- do nothing
		end
	end
end


function Berserker_Help_mod:Send_Message(peer_id, msg_id, show_prompt, data)
	local transmit_table = table.map_copy(data)
	transmit_table._show_prompt = show_prompt
	transmit_table._id = msg_id
	LuaNetworking:SendToPeer(peer_id, self._network.id, LuaNetworking:TableToString(transmit_table))
end


function Berserker_Help_mod:Send_Disable_Message(peer_id, is_update)
	if not is_update then
		is_update = nil
	end
	if LuaNetworking:IsHost() and managers.network then
		local peer = managers.network:session() and managers.network:session():peer(peer_id)
		if peer then
			for _, mod in ipairs(peer:synced_mods()) do
				if mod.name == "Berserker Live Matters" then
					_count_front = _count_front + 1
					DelayedCalls:Add("Delayed_Berserker_Help_mod_disable_msg_" .. tostring(_count_front), 5, function()
						Berserker_Help_mod:Check_Client_Answers()
					end)
					self._client_answer[peer_id] = {show_prompt = is_update, active = true}
					self:Send_Message(peer_id, self._network.force_host, is_update, self._host_restrictions)
				end
			end
		end			
	end
end

function Berserker_Help_mod:Extract_Restrictions(transmit_table)
	-- FIXME
	self._restrictions = {}
	if transmit_table.fixed == "false" then
		self._restrictions.fixed = {val = false, func = func_and}
	end
	local multiplier = tonumber(transmit_table.multiplier)
	if multiplier ~= nil then
		multiplier = math.floor(multiplier)
		if 0 < multiplier and multiplier < 3 then
			self._restrictions.multiplier = {val = multiplier, func = func_min}
		end
	end
end

function Berserker_Help_mod:Set_Player_Damage(plDam)
	self._player_damage = plDam
	self:Adjust_Health()
end

function Berserker_Help_mod:Adjust_Health()
	if self._player_damage and next(self._current) ~= nil then
		if self._current.fixed then
			self._player_damage._max_health_reduction = self.available_mult_num[self._current.multiplier]
		else
			self._player_damage._max_health_reduction = managers.player:upgrade_value("player", "max_health_reduction", 1)
		end
		local new_max_health = self._player_damage:_max_health() * self._player_damage._max_health_reduction
		local health = math.clamp(self._player_damage:get_real_health(), 0, new_max_health)
		self._player_damage:set_health(health)
	end
end



------------------------------------------------- HOOKS ----------------------------------------------------

---------------------------------------------- Networking --------------------------------------------------

Hooks:Add("NetworkReceivedData", "NetworkReceivedData_Berserker_Help_mod", function(sender, id, data)

    if id ~= Berserker_Help_mod._network.id then
		return
	end
	local transmit_table = LuaNetworking:StringToTable(data)
	if sender ~= 1 then
		if not LuaNetworking:IsHost() then
			return
		end
		if transmit_table._id ~= Berserker_Help_mod._network.confirm then
			return
		end
		Berserker_Help_mod._client_answer[sender].version = transmit_table.version
		return
	end
	
	if transmit_table._id ~= Berserker_Help_mod._network.force_host then
		return
	end

	Berserker_Help_mod:Extract_Restrictions(transmit_table)
	Berserker_Help_mod:Send_Message(1, Berserker_Help_mod._network.confirm, false, {version = Berserker_Help_mod._version})

	if transmit_table._show_prompt then
		if next(Berserker_Help_mod._restrictions) ~= nil then
			DelayedCalls:Add("Delayed_Berserker_Help_mod_disable_msg", 1, function()
					local mod_name = "[" .. managers.localization:text("Berserker_Help_mod_main_menu_title") .. "]"
					managers.chat:_receive_message(1, mod_name, managers.localization:text("Berserker_Help_mod_lobby_restricted") , Color.yellow)
					if Berserker_Help_mod._restrictions.multiplier ~= nil then
						local text  = managers.localization:text("Berserker_Help_mod_lobby_mult_restr", {
								multiplier = managers.localization:text("Berserker_Help_mod_" .. tostring(Berserker_Help_mod._restrictions.multiplier.val) .. "mult")
						})
						managers.chat:_receive_message(1, mod_name, text , Color.yellow)
					end
					if Berserker_Help_mod._restrictions.fixed ~= nil and Berserker_Help_mod._restrictions.fixed.val == false then 
						managers.chat:_receive_message(1, mod_name, managers.localization:text("Berserker_Help_mod_lobby_fixed_restr") , Color.yellow)
					end
				end)
		else
		DelayedCalls:Add("Delayed_Berserker_Help_mod_enable_msg", 1, function()
					managers.chat:_receive_message(1, "[" .. managers.localization:text("Berserker_Help_mod_main_menu_title") .. "]", managers.localization:text("Berserker_Help_mod_lobby_unrestricted") , Color.yellow)
				end)
		end
	end
	Berserker_Help_mod:Load_Current_Profile()
end)


---------------------------------------------- Localization ------------------------------------------------



Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_Berserker_Help_mod", function(loc)
	local loc_lang = BLT.Localization._current
	if loc_lang == 'cht' or BLT.Localization._current == 'zh-cn' then
		loc_lang = "ch"
	end
	for _, filename in pairs(file.GetFiles(Berserker_Help_mod._path .. "loc/")) do
		local str = filename:match('^(.*).txt$')
		if str and loc_lang == str then
			loc:load_localization_file(Berserker_Help_mod._path .. "loc/" .. filename)
			break
		end
	end

	loc:load_localization_file(Berserker_Help_mod._path .. "loc/en.txt", false)
end)


----------------------------------------------- Menu ------------------------------------------------------



Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_Berserker_Help_mod", function(menu_manager)
	local dirty = false
	MenuCallbackHandler.Berserker_Help_mod_profile_host_item_callback = function(this, item)
		MenuCallbackHandler.Berserker_Help_mod_profile_item_callback(this, item)
		dirty = true
	end

	MenuCallbackHandler.Berserker_Help_mod_profile_item_callback = function(this, item)
		local name = item._parameters["name"]:gsub("Berserker_Help_mod_item_","")
		local next_under = name:find("_")
		local profile = tonumber(name:sub(1, next_under - 1))
		name = name:sub(next_under + 1)
		local value = item:value()
		if type(value) == "string" then
			value = (value == "on") and true or false
		end
		Berserker_Help_mod._settings.profiles[profile][name] = value

	end

	MenuCallbackHandler.Berserker_Help_mod_default_host_item_callback = function(this, item)
		MenuCallbackHandler.Berserker_Help_mod_default_item_callback(this, item)
		dirty = true
	end

	MenuCallbackHandler.Berserker_Help_mod_default_item_callback = function(this, item)
		local name = item._parameters["name"]:gsub("Berserker_Help_mod_item_default_","")
		local value = item:value()
		if type(value) == "string" then
			value = (value == "on") and true or false
		end
		Berserker_Help_mod._settings.default[name] = value


		-- Update all profile values and all menu items in profiles that use default
		for i=1, #Berserker_Help_mod._settings.profiles do
			local profile = Berserker_Help_mod._settings.profiles[i]
			if profile.use_default then
				profile[name] = value
				local menu_items = MenuHelper:GetMenu("Berserker_Help_mod_menu_profiles_" .. tostring(i))._items
				local searched_item = "Berserker_Help_mod_item_" .. tostring(i) .. "_" .. tostring(name)
				for _, men_item in pairs(menu_items) do
					if men_item._parameters.name == searched_item then
						men_item:set_value(item:value())
					end
				end
			end
		end

	end

	MenuCallbackHandler.Berserker_Help_mod_use_default_item_callback = function(this, item)
		local name = item._parameters["name"]:gsub("Berserker_Help_mod_item_","")
		local profile = tonumber(name:sub(1, name:find("_") - 1))
		local value = (item:value() == "on") and true or false
		Berserker_Help_mod._settings.profiles[profile].use_default = value
		local menu =  MenuHelper:GetMenu("Berserker_Help_mod_menu_profiles_" .. tostring(profile))
		local itm_pre = "Berserker_Help_mod_item_" .. tostring(profile) .. "_"
		value = not value

		-- FIXME: Insert here
		menu:item(itm_pre .. "fixed"):set_enabled(value)
		menu:item(itm_pre .. "multiplier"):set_enabled(value)
		menu:item(itm_pre .. "combat_cancer"):set_enabled(value)
		menu:item(itm_pre .. "hacker_cancer"):set_enabled(value)
		menu:item(itm_pre .. "tag_team_cancer"):set_enabled(value)
		
		dirty = true
	end

	MenuCallbackHandler.Berserker_Help_mod_force_host_values = function(this,item)
		Berserker_Help_mod._settings.force_host_values = Utils:ToggleItemToBoolean(item)
		dirty = true
	end

	MenuCallbackHandler.Berserker_Help_mod_back = function(this, item)
		Berserker_Help_mod:Save()
		Berserker_Help_mod:Load_Current_Profile()
		if dirty then
			Berserker_Help_mod:On_Setting_Changed()
			dirty = false
		end
	end

	MenuCallbackHandler.Berserker_Help_mod_display_restrictions = function(this, item)
		local restrictions = Berserker_Help_mod:Get_Current_Restrictions()
		local my_text
		if next(restrictions) ~= nil then
			if Berserker_Help_mod._settings.force_host_values then
				my_text = managers.localization:text("Berserker_Help_mod_lobby_restricted_host_real")
			else
				my_text = managers.localization:text("Berserker_Help_mod_lobby_restricted_host_poss")
			end
			if restrictions.multiplier then
				my_text = my_text .. "\n" .. managers.localization:text("Berserker_Help_mod_lobby_mult_restr", {
					multiplier = managers.localization:text("Berserker_Help_mod_" .. tostring(restrictions.multiplier) .. "mult")
				})
			end
			if restrictions.fixed == false then
				my_text = my_text .. "\n" .. managers.localization:text("Berserker_Help_mod_lobby_fixed_restr")
			end
		else
			if Berserker_Help_mod._settings.force_host_values then
				my_text = managers.localization:text("Berserker_Help_mod_lobby_unrestricted_host_real")
			else
				my_text = managers.localization:text("Berserker_Help_mod_lobby_unrestricted_host_poss")
			end
		end
		local dialog_data = {
			title = managers.localization:text("Berserker_Help_mod_disable_title"),
			text = my_text
		}
		local ok_button = {
			text = managers.localization:text("dialog_ok")
		}
		dialog_data.button_list = {
			ok_button
		}
		managers.system_menu:show(dialog_data)
	end
	
	Berserker_Help_mod:Load()
	-- Main Menu
	Hooks:Add("MenuManagerSetupCustomMenus", "Base_SetupCustomMenus_Json_Berserker_Help_mod_main_menu", function( menu_manager, nodes )
			MenuHelper:NewMenu( "Berserker_Help_mod_main_menu" )
			MenuHelper:NewMenu( "Berserker_Help_mod_menu_profiles" )
			for i=1, #Berserker_Help_mod._settings.profiles do
				MenuHelper:NewMenu( "Berserker_Help_mod_menu_profiles_" .. tostring(i) )
			end
		end)

	Hooks:Add("MenuManagerBuildCustomMenus", "Base_BuildCustomMenus_Json_Berserker_Help_mod_main_menu", function( menu_manager, nodes )

			local parent_menu = "blt_options"
			local menu_id = "Berserker_Help_mod_main_menu"
			local menu_name = "Berserker_Help_mod_main_menu_title"
			local menu_desc = "Berserker_Help_mod_main_menu_desc"

			local data = {
				focus_changed_callback = nil,
				back_callback = "Berserker_Help_mod_back",
				area_bg = nil,
			}
			nodes[menu_id] = MenuHelper:BuildMenu( menu_id, data )

			MenuHelper:AddMenuItem( nodes[parent_menu], menu_id, menu_name, menu_desc, nil )

			parent_menu = menu_id
			menu_id = "Berserker_Help_mod_menu_profiles"
			local data = {
				focus_changed_callback = nil,
				back_callback = nil,
				area_bg = nil
			}
			nodes[menu_id] = MenuHelper:BuildMenu( menu_id, data )

			parent_menu = menu_id
			for i=1, #Berserker_Help_mod._settings.profiles do
				local skillset_name = "___tmp_name_skillset_" .. tostring(i)
				menu_id = "Berserker_Help_mod_menu_profiles_" .. tostring(i)
				menu_name = skillset_name
				menu_desc = skillset_name

				local data = {
					focus_changed_callback = nil,
					back_callback = "Berserker_Help_mod_back",
					area_bg = nil
				}
				nodes[menu_id] = MenuHelper:BuildMenu( menu_id, data )
				MenuHelper:AddMenuItem( nodes[parent_menu], menu_id, menu_name, menu_desc, nil )
			end
			Berserker_Help_mod:Fix_Menu_Names()
		end)

	local function fill_menu(prefix, menu, tbl, is_profile, last_index)
		last_index = (last_index or 0) + 6
		local clbk = is_profile and "Berserker_Help_mod_profile_item_callback" or "Berserker_Help_mod_default_item_callback"
		local clbk_host = is_profile and "Berserker_Help_mod_profile_host_item_callback" or "Berserker_Help_mod_default_host_item_callback"

		if is_profile then
			last_index = last_index + 3
			MenuHelper:AddToggle({
				id = prefix .. "use_default",
				title = "Berserker_Help_mod_use_default_title",
				desc = "Berserker_Help_mod_use_default_desc",
				callback = "Berserker_Help_mod_use_default_item_callback",
				value = tbl.use_default,
				menu_id = menu,
				priority = last_index,
				localized = true
			})
			last_index = last_index - 1

			MenuHelper:AddToggle({
				id = prefix .. "force",
				title = "Berserker_Help_mod_force_application_title",
				desc = "Berserker_Help_mod_force_application_desc",
				callback = clbk,
				value = tbl.force,
				menu_id = menu,
				priority = last_index,
				localized = true
			})
			last_index = last_index - 1

			MenuHelper:AddDivider({
				id = prefix .. "_divider_0",
				size = 24,
				menu_id = menu,
				priority = last_index
			})
			last_index = last_index - 1

		end

		to_add = {}
		for k, _ in pairs(Berserker_Help_mod.available_mult_num) do
			table.insert(to_add, "Berserker_Help_mod_" .. k .. "_mult")
		end
		MenuHelper:AddMultipleChoice({
			id = prefix .. "multiplier",
			title = "Berserker_Help_mod_mult_title",
			desc = "Berserker_Help_mod_mult_desc",
			callback = clbk_host,
			items = to_add,
			value = tbl.multiplier,
			menu_id = menu,
			disabled = tbl.use_default,
			priority = last_index,
			localized = true
		})
		last_index = last_index - 1

		MenuHelper:AddToggle({
			id = prefix .. "fixed",
			title = "Berserker_Help_mod_fixed_title",
			desc = "Berserker_Help_mod_fixed_desc",
			callback = clbk_host,
			value = tbl.fixed,
			menu_id = menu,
			disabled = tbl.use_default,
			priority = last_index,
			localized = true
		})
		last_index = last_index - 1

		MenuHelper:AddDivider({
			id = prefix .. "_divider_1",
			size = 8,
			menu_id = menu,
			priority = last_index
		})
		last_index = last_index - 1
		
		MenuHelper:AddToggle({
			id = prefix .. "combat_cancer",
			title = "Berserker_Help_mod_combat_cancer_title",
			desc = "Berserker_Help_mod_combat_cancer_desc",
			callback = clbk,
			value = tbl.combat_cancer,
			menu_id = menu,
			disabled = tbl.use_default,
			priority = last_index,
			localized = true
		})
		last_index = last_index - 1

		MenuHelper:AddToggle({
			id = prefix .. "hacker_cancer",
			title = "Berserker_Help_mod_hacker_cancer_title",
			desc = "Berserker_Help_mod_hacker_cancer_desc",
			callback = clbk,
			value = tbl.hacker_cancer,
			menu_id = menu,
			disabled = tbl.use_default,
			priority = last_index,
			localized = true
		})
		last_index = last_index - 1

		MenuHelper:AddToggle({
			id = prefix .. "tag_team_cancer",
			title = "Berserker_Help_mod_tag_team_cancer_title",
			desc = "Berserker_Help_mod_tag_team_cancer_desc",
			callback = clbk,
			value = tbl.tag_team_cancer,
			menu_id = menu,
			disabled = tbl.use_default,
			priority = last_index,
			localized = true
		})

	end

	Hooks:Add("MenuManagerPopulateCustomMenus", "Base_PopulateCustomMenus_Json_Berserker_Help_mod_main_menu", function( menu_manager, nodes )

			fill_menu("Berserker_Help_mod_item_default_", "Berserker_Help_mod_main_menu", Berserker_Help_mod._settings.default, false, 5)

			MenuHelper:AddDivider({
				id = "Berserker_Help_mod_main_menu_divider_0",
				size = 12,
				menu_id = "Berserker_Help_mod_main_menu",
				priority = 4
			})
 
			MenuHelper:AddButton({
				id = "Berserker_Help_mod_menu_profiles_button",
				title = "Berserker_Help_mod_profile_menu_title",
				desc = "Berserker_Help_mod_profile_menu_desc",
				menu_id = "Berserker_Help_mod_main_menu",
				priority = 3,
				next_node = "Berserker_Help_mod_menu_profiles"
			})

			MenuHelper:AddDivider({
				id = "Berserker_Help_mod_main_menu_divider_1",
				size = 24,
				menu_id = "Berserker_Help_mod_main_menu",
				priority = 2
			})

			MenuHelper:AddToggle({
				id = "Berserker_Help_mod_oppressing_host",
				title = "Berserker_Help_mod_disable_title",
				desc = "Berserker_Help_mod_disable_desc",
				callback = "Berserker_Help_mod_force_host_values",
				value = Berserker_Help_mod._settings.force_host_values,
				menu_id = "Berserker_Help_mod_main_menu",
				priority = 1
			})

			MenuHelper:AddButton({
				id = "Berserker_Help_mod_chk_oppressing_host",
				title = "Berserker_Help_mod_opp_host_diplay_title",
				desc = "Berserker_Help_mod_opp_host_diplay_desc",
				callback = "Berserker_Help_mod_display_restrictions",
				menu_id = "Berserker_Help_mod_main_menu",
				priority = 0
			})

			for i=1, #Berserker_Help_mod._settings.profiles do
				fill_menu("Berserker_Help_mod_item_" .. tostring(i) .. "_", "Berserker_Help_mod_menu_profiles_" .. tostring(i), Berserker_Help_mod._settings.profiles[i], true)
			end
		end)
	
end)
