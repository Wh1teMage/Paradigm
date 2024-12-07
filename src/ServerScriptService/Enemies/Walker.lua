local ServerScriptService = game:GetService('ServerScriptService')

local Components = ServerScriptService.Components

local enemy = require(Components.EnemyComponent)

return function()
	local self = enemy.new('Walker')

	return self
end
