local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local TowerEffects = require(script.Parent.Parent.TowersEffects)
local PathConfig = require(ReplicatedStorage.Templates.PathConfig)
local InstanceCache = require(ReplicatedStorage.Utilities.InstanceCache)

return {

    [PathConfig.Effects.MovingPrecursorTestEffect] = function(p1: Vector3, packageName: string, name: string)
        
    end,

    [PathConfig.Effects.PrecursorTestEffect] = function(p1: Vector3, id: number)

        local tower = TowerEffects.GetTowerById(id)
        if (not tower) then return end

        local effect = ReplicatedStorage.Samples.Effects.AttackBeam :: Beam

        --tower.FXCache['AttackAnimation']:Play()
        --tower.FXCache['AttackSound']:Play()

        --[[
        tower.Model.AnimationController:FindFirstChildWhichIsA('Animator'):LoadAnimation(tower.Info.Animations.Attack):Play()

        local sound = tower.Info.Sounds.AttackSound:Clone()
        sound.Parent = tower.Instance
        sound.PlayOnRemove = true
        sound:Destroy()
        ]]

        local cache = InstanceCache.new(tower.Model)
        tower.Cache = cache

        for _, val: Instance in pairs(tower.Model:GetDescendants()) do
            if (val:IsA('ParticleEmitter')) then val:Emit(1) end
            if (val:IsA('Attachment') and val.Name == 'BeamAttachment') then
                
                local attachment;
                local clonnedEffect;

                if (#cache.Table < 1) then
                    attachment = Instance.new('Attachment')
                    attachment.Parent = tower.Instance
                    
                    clonnedEffect = effect:Clone()
                    clonnedEffect.Parent = tower.Instance
    
                    clonnedEffect.Attachment0 = val
                    clonnedEffect.Attachment1 = attachment
                else
                    local vals = cache:Remove()
                    
                    attachment = vals[1]
                    clonnedEffect = vals[2]
                end

                attachment.WorldCFrame = CFrame.new(p1)
                clonnedEffect.Enabled = true

                task.delay(.1, function()
                    clonnedEffect.Enabled = false
                    if (not getmetatable(cache)) then return end
                    cache:Add({ attachment, clonnedEffect })
                end)
            end
        end

        --print(test)
    end

}