local ServerScriptService = game:GetService('ServerScriptService')

local Components = ServerScriptService.Components

local enemy = require(Components.EnemyComponent)

return function()
	local self = enemy.new('TowerWalker')
    --[[
	local patterns = {
		[1] = function()
			--print(1)
		end,

		[2] = function()
			--print(2)
		end,

		[3] = function()
			--print(3)
		end,
	}
	
	function self:OnAttack()
		patterns[math.random(1, #patterns)]()
	end

	
	task.delay(4, function() 
		print('Triggered 1')
		self.Speed = math.random(3, 50)
	end)
	
	task.delay(8, function() 
		print('Triggered 2')
		self.Speed = 10
	end)
	]]
	
	return self
end
