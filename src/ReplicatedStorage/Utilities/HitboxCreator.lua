local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local HitsManager = {} 

local function CompareHits( convert, old, new )

	for index, value in ipairs(new) do
		if table.find(old, value) ~= nil then continue end
		table.insert(convert, value)
	end

	return convert
end


function HitsManager.SetupHits()

	local hits = setmetatable({}, 
	{
		__add = function(old, new)
			return CompareHits(old, old, new)
		end,

		__sub = function(old, new)
			return CompareHits({}, old, new)
		end,
	})
	
	return hits
	
end


local Hitbox = {}


function Hitbox:TransferParams()
	
	self.CFrame = self.Part.CFrame
	self.Size = self.Part.Size
	
end

function Hitbox:LaunchRunService()
	
	local oldHits = HitsManager.SetupHits()
	

	local connection
	connection = RunService.Stepped:Connect(function()
		if not getmetatable(self) then return end 
		
		if self.Part ~= nil then self:TransferParams() end
		local hits = workspace:GetPartBoundsInBox( self.CFrame, self.Size, self.Filter ) 
		
		if #(oldHits - hits) == 0 then return end
		self(oldHits - hits)
		oldHits += hits
		
	end)
	
	task.delay( self.Period, function()
		connection:Disconnect()
	end)
	
end

function Hitbox:Activate()
	
	task.spawn(function() 
		
		for i=1, self.Iterations do
			if not getmetatable(self) then continue end
			
			self.Enemies = {}
			self:LaunchRunService()
			task.wait(self.Period)
		end
		
	end)
	
	task.delay( self.Duration, function()
		if not getmetatable(self) then return end
		
		self:Destroy()
	end)
	
end

function Hitbox:BindCallback(callback: (parts: {BasePart}) -> {})
	self.Callback = callback
end

function Hitbox:Destroy()
	self.Callback = nil
 	if self.Part ~= nil then self.Part:Destroy() end

	--self('Finished')

	setmetatable(self, nil)
	self = {}
end


function Hitbox:GetPlayersInHits( hits, enemies )
	local players = {}
	if enemies then self.Enemies = enemies end
	
	local ancestor = 'FindFirstAncestorWhichIsA'

	--[[
	for i, part in pairs( hits ) do
		local player = PlayersService:GetPlayerFromCharacter(part[ancestor](part, 'Model'))
		local npc = NPCModifier[ part:FindFirstAncestorWhichIsA('Model') ]
		
		if PlayersService:GetPlayerFromCharacter(part[ancestor](part, 'Model')) and not self.Enemies[player.UserId] then
			
			players[player.UserId] = PlayersService:GetPlayerFromCharacter(part[ancestor](part, 'Model'))
			self.Enemies[player.UserId] = PlayersService:GetPlayerFromCharacter(part[ancestor](part, 'Model'))

		elseif NPCModifier[ part:FindFirstAncestorWhichIsA('Model') ] and not self.Enemies[npc.UserId] then
			
			players[npc.UserId] = part[ancestor](part, 'Model')
			self.Enemies[npc.UserId] = part[ancestor](part, 'Model')

		end 
	end
	]]

	return players
end



local HitboxCreator = {}


function HitboxCreator.NewHitbox( name, size, cframe, duration, ... )
	
	local additionalInfo = ... or {}
	local filter = OverlapParams.new()

	filter.FilterDescendantsInstances = {workspace.Hitboxes}
	filter.FilterType = Enum.RaycastFilterType.Exclude
	
	local hitbox;
	hitbox = setmetatable(
		{
			Name = name,
			Size = size,
			CFrame = cframe,
			Filter = filter, --добавить парт в фильтр
			Duration = duration,
			
			Iterations = additionalInfo.Iterations or 1,
			Period = additionalInfo.Period or duration,	
			Part = additionalInfo.Part,
			
			Callback = function(parts: {BasePart}) end
		},
		{
			__index = Hitbox, --maybe add function so it can redirect hitbox index to event
			
			__call = function(self, ...)
				hitbox.Callback(...)
			end,
		})
	
	hitbox.OverallTime = hitbox.Iterations * (hitbox.Duration + hitbox.Period)

	hitbox:Activate()
	
	return hitbox
	
end



return HitboxCreator
