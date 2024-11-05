local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService('TweenService')
local StarterGui = game:GetService('StarterGui')

local Components = StarterGui.Components
local Events = ReplicatedStorage.Events
local Templates = ReplicatedStorage.Templates
local TemplateInfo = ReplicatedStorage.Info

local Enums = require(Templates.Enums)

local ItemsInfo = require(TemplateInfo.ItemsInfo)

local OrbsGuiEffects = require(script.OrbsGuiEffects)

local ButtonComponent = require(Components.UIButtonComponent)
local PlayerComponent = require(ReplicatedStorage.Components.PlayerComponent) 

local sessionData = {}
local profileData = {}

local itemsMap = {}
local mainUI: typeof(StarterGui.MainUI);

local spendPoints = 1

local function setBarValue(bar, val, maxval)
	local frame: Frame = bar.Frame
	local value = bar.Value
	
	--print(val/maxval, 'val/maxval', val, maxval)
	
	TweenService:Create(frame, TweenInfo.new(1), 
		{ Size = UDim2.fromScale(val/maxval, 1) }):Play()
	
	value.Text = tostring(val)..' / '..tostring(maxval)
end

local function generateItem(info)
	local template = mainUI.Inventory.Templates.ItemTemplate:Clone()
	
	template.Name = info.Name
	if (table.find(profileData.EquippedPassiveItems, info.Id)) then
		template.Equip.Visible = true
	end
	
	if (table.find(profileData.EquippedActiveItems, info.Id)) then
		template.Equip.Visible = true
	end
	
	return template
end

local function findEquippedIdBySlot(slot: number)
	
	for slotName, newinfo in pairs(profileData.EquippedPassiveItems) do
		local newslot = tonumber( string.match(slotName, '%d+') )
		if (newslot == slot) then return newinfo end
	end

	for slotName, newinfo in pairs(profileData.EquippedActiveItems) do
		local newslot = tonumber( string.match(slotName, '%d+') )
		if (newslot == slot) then return newinfo end
	end

end

local function findSlotById(id: number)

	for slotName, newid in pairs(profileData.EquippedPassiveItems) do
		local newslot = tonumber( string.match(slotName, '%d+') )
		if (newid == id) then return newslot end
	end

	for slotName, newid in pairs(profileData.EquippedActiveItems) do
		local newslot = tonumber( string.match(slotName, '%d+') )
		if (newid == id) then return newslot end
	end

end

local function findSlotForEquippedItem(info)
	local hotbar = mainUI.Hotbar
	local slot = 1

	local callbacks = {
		[Enums.ItemType.Passive] = function()
			for _, obj in pairs(hotbar.LeftButtons.Buttons:GetChildren()) do
				if (not obj:IsA('ImageButton')) then continue end
				if (obj.Image == '') then slot = obj.LayoutOrder; break end
			end
		end,
		
		[Enums.ItemType.Active] = function()
			for _, obj in pairs(hotbar.RightButtons.ActiveButtons:GetChildren()) do
				if (not obj:IsA('ImageButton')) then continue end
				if (obj.Image == '') then slot = obj.LayoutOrder; break end
			end
		end,
	}
	
	if (callbacks[info.Type]) then callbacks[info.Type]() end
	
	return slot
end

local function isEquipped(info)
	local equipped = false

	for slotName, id in pairs(profileData.EquippedPassiveItems) do
		if (info.Id ~= id) then continue end
		equipped = true; 
		break
	end

	for slotName, id in pairs(profileData.EquippedActiveItems) do
		if (info.Id ~= id) then continue end
		equipped = true; 
		break
	end
	
	return equipped
end

local function appendItem(info, parent)
	local itemUI = generateItem(info)
	itemUI.Parent = parent
	itemUI.Visible = true
	
	local wasEquipped = isEquipped(info)
	local itemInfo = mainUI.Inventory.Info
	
	--print(wasEquipped, 'wasEquipped', profileData.EquippedPassiveItems, info.Id)
	
	if (wasEquipped) then
		itemUI.Name = '00'..itemUI.Name
		itemUI.Equip.Visible = true
	end
	
	ButtonComponent.new(itemUI)
	ButtonComponent.new(itemUI):BindToClick(function()
		local equipped = isEquipped(info)
		
		if (equipped) then
			local slot = findSlotById(info.Id)
			Events.ManageInventory:FireServer('Unequip', info.Id, slot)
		else
			local slot = findSlotForEquippedItem(info)
			Events.ManageInventory:FireServer('Equip', info.Id, slot)
		end
	end)
	ButtonComponent.new(itemUI):BindToEnter(function()
		print(info.Name, ItemsInfo[info.Name])
		if (not ItemsInfo[info.Name]) then return end
		local data = ItemsInfo[info.Name](info)
		
		itemInfo.ItemName.Text = data.Name
		itemInfo.Stats.Text = data.Stats
		itemInfo.Description.Text = data.Description
	end)
	
	itemsMap[info.Id] = { UI = itemUI, Info = info }
end

local function removeItem(info)
	if (not itemsMap[info.Id]) then return end
	itemsMap[info.Id].UI:Destroy()
	itemsMap[info.Id].Info = nil
	itemsMap[info.Id] = nil
end

local function modifyItem(info)
	if (not itemsMap[info.Id]) then return end
	local UIParent = itemsMap[info.Id].UI.Parent
	
	removeItem(itemsMap[info.Id].Info)
	appendItem(info, UIParent)
end


local function clearItems()
	local items = mainUI.Inventory.Items
	
	for _, obj in pairs(items:GetDescendants()) do
		if (not obj:IsA('GuiButton')) then continue end
		obj:Destroy()
	end
end

local function clearEquippedItems()
	local hotbar = mainUI.Hotbar
	
	for _, obj in pairs(hotbar.LeftButtons.Buttons:GetChildren()) do
		if (not obj:IsA('ImageButton')) then continue end
		obj.Image = ''
	end
	
	for _, obj in pairs(hotbar.RightButtons.ActiveButtons:GetChildren()) do
		if (not obj:IsA('ImageButton')) then continue end
		obj.Image = ''
	end
end

local function generateEquippedItems()
	clearEquippedItems()
	local hotbar = mainUI.Hotbar
	
	--print(profileData.EquippedPassiveItems)
	
	for slotName, info in pairs(profileData.EquippedPassiveItems) do
		local slot = string.match(slotName, '%d+')
		if (not slot) then continue end
		
		local selectedUI = nil
		
		for _, obj in pairs(hotbar.LeftButtons.Buttons:GetChildren()) do
			if (not obj:IsA('ImageButton')) then continue end
			if (obj.LayoutOrder == tonumber(slot)) then selectedUI = obj break end
		end
		
		selectedUI.Image = 'http://www.roblox.com/asset/?id=6937742258'
	end
	
	for slotName, info in pairs(profileData.EquippedActiveItems) do
		local slot = string.match(slotName, '%d+')
		if (not slot) then continue end

		local selectedUI = nil

		for _, obj in pairs(hotbar.RightButtons.ActiveButtons:GetChildren()) do
			if (not obj:IsA('ImageButton')) then continue end
			if (obj.LayoutOrder == tonumber(slot)) then selectedUI = obj; break end
		end

		selectedUI.Image = 'http://www.roblox.com/asset/?id=6937742258'
	end

end

local function generateItems()
	clearItems()
	local itemsUI = mainUI.Inventory.Items
	
	for _, item in pairs(profileData.Inventory.PassiveItems) do
		appendItem(item, itemsUI.Passive.ScrollingFrame)
	end
	
	for _, item in pairs(profileData.Inventory.ActiveItems) do
		appendItem(item, itemsUI.Active.ScrollingFrame)
	end
end

local function setupHotbarButtons()
	local hotbar = mainUI.Hotbar
	
	for _, obj: ImageButton in pairs(hotbar.LeftButtons.Buttons:GetChildren()) do
		if (not obj:IsA('ImageButton')) then continue end
		local slot = obj.LayoutOrder
		
		--print(slot)

		ButtonComponent.new(obj):BindToClick(function()
			local id = findEquippedIdBySlot(slot)
			if (not id) then return end
			Events.ManageInventory:FireServer('Unequip', id, slot)
		end)
	end
	
	for _, obj: ImageButton in pairs(hotbar.RightButtons.ActiveButtons:GetChildren()) do
		if (not obj:IsA('ImageButton')) then continue end
		local slot = obj.LayoutOrder

		ButtonComponent.new(obj):BindToClick(function()
			local id = findEquippedIdBySlot(slot)
			if (not id) then return end
			Events.ManageInventory:FireServer('Unequip', id, slot)
		end)
	end
end

local function setupStatUpgrades()
	local upgrades = mainUI.Stats.Screens.Character.Upgrades

	for _, obj in pairs(upgrades:GetChildren()) do
		if (not obj:IsA('Frame')) then continue end
		if (not profileData.Stats[obj.Name]) then continue end

		ButtonComponent.new(obj.plus):BindToClick(function()
			if (type(spendPoints) ~= 'number') then spendPoints = 1 end
			Events.ManageStats:FireServer('Spend', spendPoints, obj.Name)
		end)
	end

	ButtonComponent.new(upgrades.Reset.plus):BindToClick(function()
		Events.ManageStats:FireServer('Reset')
	end)
	
	upgrades.Points.Frame.TextBox.InputEnded:Connect(function()
		spendPoints = tonumber( upgrades.Points.Frame.TextBox.Text )
	end)
end


local function replicateStats()
	local upgrades = mainUI.Stats.Screens.Character.Upgrades

	for _, obj in pairs(upgrades:GetChildren()) do
		if (not obj:IsA('Frame')) then continue end
		if (not profileData.Stats[obj.Name]) then continue end
		obj.Value.Text = tostring(profileData.Stats[obj.Name])
	end
	
	upgrades.Points.Value.Text = tostring(profileData.Config.Points)
end

local function replicateFinalStats()
	local stats = mainUI.Stats.Screens.Character.Stats

	for scope, v in pairs(sessionData.OverallStats) do
		local scopeUI = stats:FindFirstChild(scope)
		if (not scopeUI) then continue end
		scopeUI.Value.Text = tostring(v)
	end

	stats.Damage.Value.Text = tostring(sessionData.OverallStats.MinDamage)..
		'-'..tostring(sessionData.OverallStats.MaxDamage)
	
	local required =
		math.round( profileData.Values.LevelValue*100*(1.01^profileData.Values.LevelValue) + 100)
	
	stats.Level.Stat.Text = tostring('Lv.')..tostring(profileData.Values.LevelValue)
	stats.Level.Value.Text = tostring(profileData.Values.ExpValue)..' / '..tostring(required)
end

local enemies = {}

local function createEnemy(args)
	local enemy = args[1]
	local enemyUI = mainUI.EnemiesBar.Templates.EnemyTemplate:Clone()
	
	enemyUI.Main.EnemyName.Text = 'Lv.'..tostring(enemy.Level)..' '..tostring(enemy.Name)
	enemyUI.Main.CanvasGroup.Value.Text = tostring(enemy.Health)..' / '..tostring(enemy.MaxHealth)
	enemyUI.Size = UDim2.fromScale(0, .2)
	enemyUI.Parent = mainUI.EnemiesBar
	enemyUI.Visible = true
	
	TweenService:Create(enemyUI, TweenInfo.new(1), { Size = UDim2.fromScale(.803, .2) }):Play()
	
	enemies[enemy.Hitbox] = {UI = enemyUI, data = enemy}
end

local function destroyEnemy(args)
	local name = args[1]
	if (not enemies[name]) then return end
	
	local enemyUI = enemies[name].UI
	
	TweenService:Create(enemyUI, TweenInfo.new(.5, 
		Enum.EasingStyle.Quad, Enum.EasingDirection.In), 
		{ Size = UDim2.fromScale(0, .2) }):Play()
	
	task.wait(1)
	
	enemyUI:Destroy()
	enemies[name] = nil
end

local function dealDamageToEnemy(args)
	local name = args[1]
	if (not enemies[name]) then return end
	local enemyUI = enemies[name].UI
	local enemy = enemies[name].data
	
	local health = math.max(args[2][3], 0)
	
	enemyUI.Main.CanvasGroup.Value.Text = tostring(health)..' / '..tostring(enemy.MaxHealth)
	TweenService:Create(enemyUI.Main.CanvasGroup.Frame, TweenInfo.new(1), 
		{ Size = UDim2.fromScale(health/enemy.MaxHealth, 1) }):Play()
end

local function destroyAll()
	for i, v in pairs(enemies) do
		destroyEnemy({v.data.Name})
	end
end

local function claimOrbEffect(name: string)
	if (not OrbsGuiEffects[name]) then return end
	OrbsGuiEffects[name](PlayerComponent:GetPlayer(), mainUI)
end


return function(UI: typeof(StarterGui.MainUI))
	local component = PlayerComponent:GetPlayer()
	local replica = component.Replica
	
	print(replica, component.Replica, component)
	
	mainUI = UI
	
	sessionData = replica.Data.Session
	profileData = replica.Data.Profile
	
	local hotbar = UI.Hotbar
	local values = hotbar.Values
	
	setBarValue(values.Health, sessionData.Attributes.Health, sessionData.Attributes.MaxHealth)
	--setBarValue(values.Level, sessionData.Attributes.Health, sessionData.Attributes.MaxHealth)
	setBarValue(values.Shield, sessionData.Attributes.Shield, sessionData.Attributes.MaxShield)
	setBarValue(values.Mana, sessionData.Attributes.Mana, sessionData.Attributes.MaxMana)
	
	local required =
		math.round( profileData.Values.LevelValue*100*(1.01^profileData.Values.LevelValue) + 100)
	setBarValue(values.Level, profileData.Values.ExpValue, required)
	
	generateItems()
	generateEquippedItems()
	setupHotbarButtons()
	setupStatUpgrades()
	replicateStats()
	replicateFinalStats()

	values.Level.TextLabel.Text = 'Lv.'..tostring(profileData.Values.LevelValue)
	
	replica:ListenToChange('Session.Attributes.Health', function()
		setBarValue(values.Health, sessionData.Attributes.Health, sessionData.Attributes.MaxHealth)
	end)
	
	replica:ListenToChange('Session.Attributes.Shield', function()
		setBarValue(values.Shield, sessionData.Attributes.Shield, sessionData.Attributes.MaxShield)
	end)
	
	replica:ListenToChange('Session.Attributes.Mana', function()
		setBarValue(values.Mana, sessionData.Attributes.Mana, sessionData.Attributes.MaxMana)
	end)
	
	replica:ListenToChange('Profile.Values.ExpValue', function()
		local required = 
			math.round( profileData.Values.LevelValue*100*(1.01^profileData.Values.LevelValue) + 100)
		setBarValue(values.Level, profileData.Values.ExpValue, required)
		values.Level.TextLabel.Text = 'Lv.'..tostring(profileData.Values.LevelValue)
	end)
	
	replica:ListenToChange('Profile.EquippedPassiveItems', function()
		generateEquippedItems()
	end)
	
	--[[
	local statsArray = { 'Health', 'Damage', 'Magic', 'Mana', 'Shield' }
	
	for _, stat in pairs(statsArray) do
		replica:ListenToChange('Profile.Stats.'..stat, function()
			replicateStats()
		end)
	end
	]]
	
	replica:ListenToChange('Profile.Config.Points', function()
		replicateStats()
	end)
	
	--[[
	replica:ListenToChange('Profile.EquippedActiveItems', function()
		generateEquippedItems()
	end)
	]]
	
	local itemsUI = mainUI.Inventory.Items
	
	Events.ManageInventory.OnClientEvent:Connect(function(scope, ...)
		local args = {...}
		
		--print(scope, args)
		
		if (scope == 'Append') then
			local item = args[1]
			
			if (item.Type == Enums.ItemType.Passive) then
				appendItem(item, itemsUI.Passive.ScrollingFrame)
			end
			
			if (item.Type == Enums.ItemType.Active) then
				appendItem(item, itemsUI.Active.ScrollingFrame)
			end
		end
		
		if (scope == 'Remove') then
			local item = args[1]
			removeItem(item)
		end
		
		if (scope == 'Modify') then
			local item = args[1]
			modifyItem(item)
		end
		
	end)
	
	Events.ManageFightGui.Event:Connect(function(scope: string, ...)
		local args = {...}
		
		print(args, scope)
		
		if (scope == 'CreateEnemy') then
			createEnemy(args)
		end
		
		if (scope == 'DealDamage') then
			dealDamageToEnemy(args)
		end
		
		if (scope == 'DestroyEnemy') then
			destroyEnemy(args)
		end
		
		if (scope == 'DestroyAll') then
			destroyAll(args)
		end
		
		if (scope == 'ClaimOrbEffect') then
			claimOrbEffect(args[1])
			--destroyAll(args)
		end
		
	end)
	
	task.spawn(function()
		while task.wait(.2) do
			replicateFinalStats()
		end
	end)
end
