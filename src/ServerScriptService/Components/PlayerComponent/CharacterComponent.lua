local CharacterComponent = {}

function CharacterComponent:SetupCharacter()
	local player: Player = self.Instance
	local character = player.Character
	if (not character) then character = player.CharacterAdded:Wait() end
	
	local sessionData = self.Session
	sessionData.Character = character
	
	local humanoid: Humanoid = character:WaitForChild('Humanoid')
	
	local connection;
	connection = humanoid.Died:Connect(function()
		for name, callback in pairs(sessionData.OnDeath) do
			callback()
		end
		
		connection:Disconnect()
		connection = nil
	end)
	
	player.CharacterAdded:Connect(function(newCharacter)
		humanoid = newCharacter:WaitForChild('Humanoid')
		
		connection = humanoid.Died:Connect(function()
			for name, callback in pairs(sessionData.OnDeath) do
				callback()
			end

			connection:Disconnect()
			connection = nil
		end)
		
		sessionData.Character = newCharacter
		sessionData.Attributes.Health = sessionData.Attributes.MaxHealth
	end)
	
	
	self:BindToDeath('Passives', function()
		for _, passive in pairs(self.Session.Passives) do
			passive.OnDeath()
		end
	end)
	
end

function CharacterComponent:BindToDeath(name: string, callback: () -> {})
	local character = self.Instance.Character
	if (not character) then return end
	
	local sessionData = self.Session
	
	local humanoid = character:FindFirstChild("Humanoid")
	if (not humanoid) then return end
	
	sessionData.OnDeath[name] = callback
	
	--[[
	local deathConnection
	deathConnection = humanoid.Died:Connect(function()
		deathConnection:Disconnect()
	end)
	]]
	
end

function CharacterComponent:UnbindFromDeath(name: string)
	local sessionData = self.Session
	sessionData.OnDeath[name] = nil
end

return CharacterComponent
