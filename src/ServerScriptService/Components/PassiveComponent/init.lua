local PassiveComponent = {}
PassiveComponent.__index = PassiveComponent

function PassiveComponent.OnAttack()
	
end

function PassiveComponent.OnHit()
	
end

function PassiveComponent.OnAction()

end

function PassiveComponent.OnTick()

end

function PassiveComponent.OnUpgrade()

end

function PassiveComponent.OnTowerAdded(tower: any) -- prefer tower type

end

function PassiveComponent.OnTowerRemoved(tower: any) -- prefer tower type

end

function PassiveComponent.OnDeath()

end

function PassiveComponent.Start()

end

function PassiveComponent.Stop()

end

function PassiveComponent.TransferData(args: {any})

end

function PassiveComponent.new()
	local self = setmetatable({}, PassiveComponent)
	
	return self
end

return PassiveComponent
