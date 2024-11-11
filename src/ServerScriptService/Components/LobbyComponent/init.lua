local ServerScriptService = game:GetService('ServerScriptService')

local GameComponent = require(ServerScriptService.Components.GameComponent)

local loaded = false

local LobbyComponent = {}

function LobbyComponent:Survival(name: string, mapName: string)
    if (loaded) then return end
    loaded = true

    local component = GameComponent.new(name)
    component:SetupMap(mapName, CFrame.new(0, 2, 0))
    component:Start()

    return component
end

--add pvp method

return LobbyComponent