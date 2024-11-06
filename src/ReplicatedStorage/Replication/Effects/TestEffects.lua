local ReplicatedStorage = game:GetService('ReplicatedStorage')

local towerEffects = require(script.Parent.Parent.TowersEffects)
local PathConfig = require(ReplicatedStorage.Templates.PathConfig)

return {

    [PathConfig.Effects.PrecursorTestEffect] = function(test: CFrame, name: string)
        local tower = towerEffects.GetTowerByName(name)
        if (not tower) then return end

        tower.Instance.CFrame = test
        --print(test)
    end

}