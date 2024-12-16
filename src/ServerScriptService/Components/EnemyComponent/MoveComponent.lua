local ServerScriptService = game:GetService('ServerScriptService')

local Components = ServerScriptService.Components

local MovablePackageComponent = require(Components.MovablePackageComponent)

local MoveComponent = {}

function MoveComponent:StartMoving(selectedTrack: number?, startingPoint: number?, direction: number?)
	if (not selectedTrack) then selectedTrack = 1 end

	if (#self.Game.Info.Paths < 1) then return end
	if (not self.Game.Info.Paths[selectedTrack]) then return end
	
	if (not startingPoint) then startingPoint = 0 end
	if (not direction) then direction = 1 end

	self.CurrentStep = startingPoint

	--MovingEnemies[self.Id] = { selectedTrack, direction, self }
	--CFrames[self.Id] = self.CFrame

	--enemyCount += 1

	MovablePackageComponent:AddToQueue({ selectedTrack, direction, self })
end

return MoveComponent