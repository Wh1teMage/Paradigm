local tower = require(script.Parent)

return function(position: Vector3)
	local self = tower.new(position, 'Precursor')
	
	function self:OnAttack()
		if (not getmetatable(self.SelectedTarget)) then return end -- extra check

		self.SelectedTarget:DealDamage(self.Damage)
		print(self.SelectedTarget)

	end
	
	return self
end
