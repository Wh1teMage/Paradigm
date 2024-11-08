local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local SignalComponent = require(ReplicatedStorage.Components.SignalComponent)
local PathConfig = require(ReplicatedStorage.Templates.PathConfig)

local tower = require(ServerScriptService.Components.TowerComponent)

return function(position: Vector3)
	local self = tower.new(position, 'Precursor')
	
	local preUltimatumPattern = function()
		
		for i = 1, self.BurstCount do -- check whats dropping the microprofilerstats
			task.wait(self.BurstCD/self.Amplifiers.Speed)

			if (not getmetatable(self)) then continue end
			self:GetTarget()

			if (not self.SelectedTarget) then
				repeat task.wait(.1); self:GetTarget() until self.SelectedTarget or (not getmetatable(self))
			end

			if ((not getmetatable(self.SelectedTarget)) or (not getmetatable(self))) then continue end

			local selectedCFrame = CFrame.new(self.Hitbox.Position, self.SelectedTarget.Hitbox.Position * Vector3.new(1, 0, 1) + self.Hitbox.Position * Vector3.new(0, 1, 0))

			task.spawn(function() -- not sure about this one tho
				for i = 1, 3 do
					if ((not getmetatable(self.SelectedTarget)) or (not getmetatable(self))) then continue end
					self.Hitbox.CFrame = self.Hitbox.CFrame:Lerp(selectedCFrame, i/3)
					task.wait(1/20)
				end
			end)

			SignalComponent:GetSignal('ManageEffects'):FireAllClients(
				PathConfig.Scope.ReplicateEffect, 
				PathConfig.Effects.PrecursorTestEffect, 
				self.SelectedTarget.Hitbox.Position,
				self.Hitbox.Name
			)

			self.SelectedTarget:DealDamage(self.Damage*self.Amplifiers.Damage)
		end
	end

	local function ultimatumPattern() -- example of attack pattern changing within the same tower
		
		for i = 1, self.BurstCount do
			task.wait(self.BurstCD)

			self:GetTarget()

			repeat task.wait(.1); self:GetTarget() until self.SelectedTarget or (not getmetatable(self))
			if ((not getmetatable(self.SelectedTarget)) or (not getmetatable(self))) then continue end

		end


	end

	function self:OnAttack()
		if (not getmetatable(self.SelectedTarget)) then return end -- extra check

		if (self.Level ~= 3) then preUltimatumPattern()
		else preUltimatumPattern() end

	end
	
	return self
end
