local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Info = ReplicatedStorage.Info

local DataModifiers = require(ReplicatedStorage.Utilities.DataModifiers)
local GlobalInfo = require(Info.GlobalInfo)

--{"AwardCash", 1000},--awardcash type, amount of cash
--{"Spawn", "Normal", 6, 1.2},--zombie, amount, timebetween
--{"Music", 14062290296, 0.9, 1}, --music type, {"Music", id, volume, pitch, showvisualizer}
--{"Dialogue", "Get ready for a new enemy!", 3},--dialogue type, text, duration
--{"DialogueLink", "SirZeltron"} --name of required module
--{"Wait", 3},
--{"Music", 15914222986, 1, true}, --id, volume, loop
--{"WaitForClear"}, --wait for every zombie killed
--{"StopMusic"},

local data = {
	['Settings'] = GlobalInfo,
	['Waves'] = {},
}

return function()
	local self = table.clone(data)

	self.Settings = DataModifiers:DeepTableClone(self.Settings)
	
	return self
end
