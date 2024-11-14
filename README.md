# Paradigm

## [Structure](https://miro.com/app/board/uXjVLKPyetg=/?share_link_id=227356778849)

## Paths
ReplicatedStorage -> Info (All configs)

ReplicatedStorage -> Templates (All templates)

ReplicatedStorage -> Components (All client components)

ServerScriptService -> Components (All server components)

ReplicatedStorage -> Replication (All client replication callbacks)


## How to create a new tower
### Setting up info
To create tower info  go to $${\color{orange}ReplicatedStorage -> Info -> Towers -> /newfile/}$$

To check all possible fields go to $${\color{orange}ReplicatedStorage -> Templates -> TowerTemplate}$$ 

To create add skin/model go to $${\color{orange} ReplicatedStorage -> Samples -> TowerModels -> /towername/ -> /skinname/ -> /levelname/}$$ 

To see an example go to $${\color{orange}ReplicatedStorage -> Info -> Towers -> Precursor}$$  

```lua


local Towers: {[number]: () -> typeof(Template())} = {}

Towers[1] = function() -- index corresponds to level
	local tower = Template() -- created by default template

	tower.ModelsFolder = TowerSamples.Precursor -- all skins/models should be located here
	tower.Price = 460
	tower.Range = 18
	tower.Damage = 1
	tower.Firerate = 2.05

	tower.ShootType = Enums.ShootType.Burst
	tower.BurstCount = 6
	tower.BurstCD = .11

	tower.Level = 1

	local idleAnim = Instance.new('Animation')
	idleAnim.AnimationId = 'rbxassetid://14253606347'

	local attackAnim = Instance.new('Animation')
	attackAnim.AnimationId = 'rbxassetid://14535901409'

	local attackSound = Instance.new('Sound')
	attackSound.SoundId = 'rbxassetid://7131411690'
	attackSound.PlaybackSpeed = 1.3
	attackSound.Volume = 0.35

	tower.Animations = {
		Idle = idleAnim,
		Attack = attackAnim
	}

	tower.Sounds = {
		AttackSound = attackSound
	}

	tower.Passives = {
		{Name = 'TestPassive2', Level = 1, Requirements = {}}
	}

	return tower
end


```


### Creating attack pattern
ReplicatedStorage -> Towers -> /newfile/

To check all possible methods go to ServerScriptService -> ServerScriptService -> TowerComponent

To check all default attack patterns go to ServerScriptService -> ServerScriptService -> Static -> TowerAttackPatterns

To see an example go to ServerScriptService -> Towers -> Precursor


## How to create a new enemy
### Setting up info
ReplicatedStorage -> Info -> EnemiesInfo

To check all possible fields go to ReplicatedStorage -> Templates -> EnemyTemplate

To see an example go to ReplicatedStorage -> Info -> EnemiesInfo

### Creating attack pattern
ReplicatedStorage -> Enemies -> /newfile/

To check all possible methods go to ServerScriptService -> Components -> EnemyComponent

To see an example go to ServerScriptService -> Enemies -> Part


## How to create a new lobby
ReplicatedStorage -> Info -> Lobbies -> /newfile/

To check all possible fields go to ReplicatedStorage -> Templates -> LobbyTemplate

To see an example go to ReplicatedStorage -> Info -> Lobbies -> TestLobby


## How to create a new passive
ServerScriptService -> Components -> PassiveComponent -> /newfile/

To check all possible methods go to ServerScriptService -> Components -> PassiveComponent

To see an example go to ServerScriptService -> Components -> PassiveComponent -> TestPassive2


## How to create a new ability
ServerScriptService -> Components -> AbilityComponent -> /newfile/

To check all possible methods go to ServerScriptService -> Components -> AbilityComponent

To see an example go to ServerScriptService -> Components -> AbilityComponent -> Fireball


## How to create a new buff
ServerScriptService -> Components -> BuffsComponent -> /newfile/

To check all possible methods go to ServerScriptService -> Components -> BuffsComponent

To see an example go to ServerScriptService -> Components -> BuffsComponent -> TestBuff


## How to create a new signal
```lua
local SignalComponent = require(ReplicatedComponents.SignalComponent)

SignalComponent:GetSignal('TestEvent')
-- for bindable do SignalComponent:GetSignal('TestEvent', true)

--Connection
SignalComponent:GetSignal('ManageTowers'):Connect(
	function(scope, ...)
    print(scope, ...)
  end
)

--Firing
SignalComponent:GetSignal('ManageTowers'):FireAllClients('TestScope', 'someparams')
```
Signal **MUST** be created on server before client connects to it

To check all possible methods go to ReplicatedStorage -> Components -> SignalComponent

...indev...
