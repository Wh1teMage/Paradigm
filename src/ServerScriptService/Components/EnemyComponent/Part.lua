local enemy = require(script.Parent)

return function()
	local self = enemy.new('Part')
	
	self:StartMoving()
	
	--[[
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
