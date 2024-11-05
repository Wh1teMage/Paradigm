local BuffsComponent = {}
BuffsComponent.__index = BuffsComponent

function BuffsComponent.Start()

end

function BuffsComponent.Stop()

end

function BuffsComponent.TransferData(args: {any})

end

function BuffsComponent.new()
	local self = setmetatable({}, BuffsComponent)

	return self
end

return BuffsComponent
