local Enums = require(script.Parent.Enums)

local data = {

    TrackId = 1,
    Track = nil,
    Direction = 1,

    Speed = 1,
    CurrentStep = 0,

    CFrame = CFrame.new(10000, 10000, 10000),
    Distance = 0,
    EntityCount = 0,

    Game = nil,
    Entities = {},
    PackageType = Enums.PackageType.Enemy,

    Id = 1,

}

return function()
	local temp = table.clone(data)

    temp.Entities = {}

	return temp
end