local InstanceUtilities = {}

function InstanceUtilities:Weld(p1, p2)
    local weld = Instance.new('Weld')
    weld.Part1 = p1
    weld.Part0 = p2
    weld.Parent = p1

    return weld
end

function InstanceUtilities:FindAttribute(part: Part, name: string)
    local value = part:GetAttribute(name)
    if (not value) then return end

    return value
end


return InstanceUtilities