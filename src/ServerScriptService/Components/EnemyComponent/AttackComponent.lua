local ServerScriptService = game:GetService('ServerScriptService')

local Components = ServerScriptService.Components

local MovablePackageComponent = require(Components.MovablePackageComponent)

local AttackComponent = {}

function AttackComponent:CheckCD()
	if (not self.CanAttack) then return end
	if (self.Shooting) then return end
	if (self:GetAttribute('Stunned') > 0) then return end
	if (os.clock() - self.LastShoot) < self:GetValue('Firerate') then return end
	return true
end

function AttackComponent:OnAttack()
	
end

function AttackComponent:Attack()
	if (not self:CheckCD()) then return end
	self.Shooting = true

	for _, passive in pairs(self.Session.Passives) do
		passive.OnAttack()
	end
	
	self:OnAttack()
		
	self.LastShoot = os.clock()
	self.Shooting = false
end

function AttackComponent:TakeDamage(damage: number)
	self.Health -= damage
	if (self.Health > 0) then return end
	self:Destroy()

	return true
end


return AttackComponent