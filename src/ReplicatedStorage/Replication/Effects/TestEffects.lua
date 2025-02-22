local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local TowerEffects = require(script.Parent.Parent.TowersEffects)
local PathConfig = require(ReplicatedStorage.Templates.PathConfig)
local InstanceCache = require(ReplicatedStorage.Utilities.InstanceCache)

local IgnoreFolder = game.Workspace['_ignore']

return {

    [PathConfig.Effects.MovingPrecursorTestEffect] = function(p1: Vector3, packageName: string, name: string)
        
    end,

    [PathConfig.Effects.PrecursorTestEffect] = function(p1: Vector3, id: number)

        local tower = TowerEffects.GetTowerById(id)
        
        if (not tower) then return end
        if (not tower.Model.Parent) then return end

        local effect = ReplicatedStorage.Samples.Effects.AttackBeam :: Beam

        tower.FXCache['AttackAnimation']:Play()
        tower.FXCache['AttackSound']:Play()

        --[[
        tower.Model.AnimationController:FindFirstChildWhichIsA('Animator'):LoadAnimation(tower.Info.Animations.Attack):Play()

        local sound = tower.Info.Sounds.AttackSound:Clone()
        sound.Parent = tower.Instance
        sound.PlayOnRemove = true
        sound:Destroy()
        ]]

        local cache = InstanceCache.new(tower.Model)
        tower.Cache = cache

        --[[
        local weld: Weld = tower.Model.PrimaryPart.Weld

        if (weld) then
            weld.C0 = CFrame.new(tower.Model:GetPivot().Position, p1).Rotation * CFrame.Angles(0, math.rad(180), 0)
        end
        ]]

        tower.Model:PivotTo(CFrame.new( 
            tower.Model.PrimaryPart.Position, 
            p1 * Vector3.new(1, 0, 1) + Vector3.new(0, tower.Model.PrimaryPart.Position.Y, 0) 
        ))

        for _, val: Instance in pairs(tower.Model:GetDescendants()) do
            if (val:IsA('ParticleEmitter')) then val:Emit(1) end
            if (not (val:IsA('Attachment') and val.Name == 'BeamAttachment')) then continue end
                
            local attachment;
            local clonnedEffect;

            if (#cache.Table < 1) then
                attachment = Instance.new('Attachment')
                attachment.Parent = tower.Model.PrimaryPart
                
                clonnedEffect = effect:Clone()
                clonnedEffect.Parent = tower.Model.PrimaryPart

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

        --print(test)
    end

}