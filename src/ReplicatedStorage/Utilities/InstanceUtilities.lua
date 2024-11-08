local InstanceUtilities = {}

function InstanceUtilities:Weld(p1, p2)
    local weld = Instance.new('WeldConstraint')
    weld.Part1 = p1
    weld.Part0 = p2
    weld.Parent = p1

    return weld
end

return InstanceUtilities