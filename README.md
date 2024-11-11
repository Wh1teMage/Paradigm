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
ReplicatedStorage -> Info -> Towers -> /newfile/

To check all possible fields go to ReplicatedStorage -> Templates -> TowerTemplate

To see an example go to ReplicatedStorage -> Info -> Towers -> Precursor


### Creating attack pattern
ReplicatedStorage -> Towers -> /newfile/

To check all possible methods go to ServerScriptService -> Components -> TowerComponent

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
