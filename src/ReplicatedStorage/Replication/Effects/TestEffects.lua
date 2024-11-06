local ReplicatedStorage = game:GetService('ReplicatedStorage')

local towerEffects = require(script.Parent.Parent.TowersEffects)
local PathConfig = require(ReplicatedStorage.Templates.PathConfig)

return {

    [PathConfig.Effects.PrecursorTestEffect] = function(p1: Vector3, name: string)
        local tower = towerEffects.GetTowerByName(name)
        if (not tower) then return end

        local effect = ReplicatedStorage.Samples.Effects.AttackBeam :: Beam

        local animation = Instance.new('Animation')
        animation.AnimationId = tower.Info.Animations.Attack
    
        tower.Model.AnimationController:FindFirstChildWhichIsA('Animator'):LoadAnimation(animation):Play()

        animation:Destroy()

        local sound = Instance.new('Sound')

        sound.SoundId = tower.Info.Sounds.AttackSound.SoundId
        sound.PlaybackSpeed = tower.Info.Sounds.AttackSound.PlaybackSpeed
        sound.Volume = tower.Info.Sounds.AttackSound.Volume

        sound.Parent = tower.Instance
        sound.PlayOnRemove = true
        sound:Destroy()

        for _, val: Instance in pairs(tower.Model:GetDescendants()) do
            if (val:IsA('ParticleEmitter')) then val:Emit(1) end
            if (val:IsA('Attachment') and val.Name == 'BeamAttachment') then
                local attachment = Instance.new('Attachment')
                attachment.Parent = tower.Instance
                attachment.WorldCFrame = CFrame.new(p1)

                local clonnedEffect: Beam = effect:Clone()
                clonnedEffect.Parent = tower.Instance

                clonnedEffect.Attachment0 = val
                clonnedEffect.Attachment1 = attachment
                
                clonnedEffect.Enabled = true

                task.delay(.1, function()
                    clonnedEffect:Destroy()
                    attachment:Destroy()
                end)
            end
        end

        --print(test)
    end

}