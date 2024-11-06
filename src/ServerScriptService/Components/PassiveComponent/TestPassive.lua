local passive = require(script.Parent)

return function()
	local self = passive.new()
	
	local component;
	
	function self.OnAttack()
		--print('Attack', component.Damage)
		--component.Damage += 1
	end

	function self.Start()
		--print('Placed')
	end
	
	function self.TransferData(args: {any})
		component = args[1]
	end
	
	return self
end
