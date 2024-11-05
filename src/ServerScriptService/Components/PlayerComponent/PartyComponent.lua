local PartyComponent = {}

function PartyComponent:AddPlayerToParty(player)
	self.Session.Party[player.Instance] = true
	player.Session.Party[self.Instance] = true
end

function PartyComponent:RemovePlayerFromParty(player)
	self.Session.Party[player.Instance] = nil
	player.Session.Party[self.Instance] = nil
end

return PartyComponent
