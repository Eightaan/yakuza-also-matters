local _fresh_joined = {}
local _seen = {}


Hooks:PostHook(NetworkPeer,"register_mod","Berserker_Help_mod_check_mods", function(self, id, friendly)
	if self:id() == 1 then
		return
	end

	if Berserker_Help_mod._settings.force_host_values and friendly == "Berserker Live Matters" and LuaNetworking:IsHost() then
		if _seen[self:id()] == self then
			return
		end

		_seen[self:id()] = self
		if _fresh_joined[self:id()] then
			Berserker_Help_mod:Send_Disable_Message(self:id(), true)
			_fresh_joined[self:id()] = false
		else
			Berserker_Help_mod:Send_Disable_Message(self:id(), false)
		end
	end
end)

Hooks:Add("NetworkManagerOnPeerAdded", "Berserker_Help_mod_PeerAdded", function(peer, peer_id)
	_fresh_joined[peer_id] = true
end)