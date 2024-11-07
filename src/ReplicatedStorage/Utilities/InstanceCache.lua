local Cache = {}

local InstanceCache = {}
InstanceCache.__index = InstanceCache

function InstanceCache:Add(data)
    table.insert(self.Table, data)
end

function InstanceCache:Remove()
    return table.remove(self.Table)
end

function InstanceCache:Destroy()
    table.clear(self.Table)
    self.Table = nil
    Cache[self.Id] = nil
    setmetatable(self, nil)
    self = nil
end

function InstanceCache.new(key: any)
    if (Cache[key]) then return Cache[key] end

    local self = setmetatable({
        Id = key,
        Table = {}
    }, InstanceCache)

    Cache[key] = self

    return self
end

return InstanceCache