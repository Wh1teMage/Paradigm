# Paradigm

## [Structure](https://miro.com/app/board/uXjVLKPyetg=/?share_link_id=227356778849)

## Project Initialization

This article will help you to set up the whole system correctly

Preraration
+ Download Visual Studio Code [Here](https://code.visualstudio.com/download)
+ Create a Github account [Here](https://github.com/)
+ Open VSC and download Rojo extension (Ctrl + Shift + X to open extensions tab)
+ Install Rojo plugin in RS
+ Download Luau and Luau Language Server extensions in VSC


Now for the project itself
+ Download [this](https://github.com/Wh1teMage/Paradigm#) file as zip
+ Unzip this file anywhere you like and open VSC in that folder
+ Go to Source Control Tab (Ctrl + Shift + G + G) and login into your github


Sync project with RS
+ Open menu (Ctrl + Shift + P) and type in Rojo: Open Menu
+ Select Install Rojo option
+ Now you should be able to run Rojo (run default file through VSC menu -> Rojo menu)
+ Go to RS, open Rojo plugin, click Connect and you should be ready to develop

> [!NOTE]
> Only ONE person can connect to the studio via Rojo
> Multiple people connecting will result in an error
> 
> You can use VSC without opening RS, thats the key for modifing the same project by multiple people

## Paths
```diff
Configs
+ ReplicatedStorage -> Info 

Templates
+ ReplicatedStorage -> Templates 

Client components
+ ReplicatedStorage -> Components 

Server components
+ ServerScriptService -> Components 

Client replication callbacks
+ ReplicatedStorage -> Replication

Client contexts / binds
+ ReplicatedStorage -> Components -> PlayerComponent
+ ReplicatedStorage -> Components -> PlayerComponent -> Contexts
```

## How to create a new tower
### Setting up info

```diff
To create tower info go to
+ ReplicatedStorage -> Info -> Towers -> /newfile/

To check all possible fields go to
+ ReplicatedStorage -> Templates -> TowerTemplate

To create add skin/model go to
+ ReplicatedStorage -> Samples -> TowerModels -> /towername/ -> /skinname/ -> /levelname/

To see an example go to
+ ReplicatedStorage -> Info -> Towers -> Precursor
```
> [!NOTE]
> Tower indexes should ALWAYS be numbers
> 
> Tower Models should be able to be called via `tonumber(model.Name)`

> [!TIP]
> It's better to inherit previous tower level in the info


### Creating attack pattern

```diff
To create attack pattern go to
+ ServerScriptService -> Towers -> /newfile/

To check all possible methods go to
+ ServerScriptService -> ServerScriptService -> TowerComponent

To check all default attack patterns go to
+ ServerScriptService -> ServerScriptService -> Static -> TowerAttackPatterns

To see an example go to
+ ServerScriptService -> Towers -> Precursor
```
> [!NOTE]
> Remember to create tower with correct name `local self = tower.new(position, 'towername')`
> 
> Damage method should be activated in callbacks for attack patterns

## How to create a new enemy
### Setting up info
```diff
To create enemy info go to
+ ReplicatedStorage -> Info -> EnemiesInfo

To check all possible fields go to
+ ReplicatedStorage -> Templates -> EnemyTemplate

To create add skin/model go to
+ ReplicatedStorage -> Samples -> EnemyModels -> /enemyname/

To see an example go to
+ ReplicatedStorage -> Info -> EnemiesInfo
```

### Creating attack pattern
```diff
To create attack pattern go to
+ ReplicatedStorage -> Enemies -> /enemyname/

To check all possible methods go to
+ ServerScriptService -> Components -> EnemyComponent

To see an example go to
+ ServerScriptService -> Enemies -> Part
```
> [!NOTE]
> Remember to create enemies with correct name `local self = enemy.new('enemyname')`

## How to create a new game pattern
```diff
To create game pattern go to
+ ReplicatedStorage -> Info -> Games -> /newfile/

To check all possible fields go to
+ ReplicatedStorage -> Templates -> GameTemplate

To see an example go to
+ ReplicatedStorage -> Info -> Games -> TestGame
```

## How to create a new passive
```diff
To create passive go to
+ ServerScriptService -> Components -> PassiveComponent -> /newfile/

To check all possible methods go to
+ ServerScriptService -> Components -> PassiveComponent

To see an example go to
+ ServerScriptService -> Components -> PassiveComponent -> TestPassive2
```
> [!TIP]
> If you cant find specific trigger, you can always create one

## How to create a new ability
```diff
To create ability go to
+ ServerScriptService -> Components -> AbilityComponent -> /newfile/

To check all possible methods go to
+ ServerScriptService -> Components -> AbilityComponent

To see an example go to
+ ServerScriptService -> Components -> AbilityComponent -> Fireball
```
> [!TIP]
> Abilities can be used by enemy, tower and player

## How to create a new buff
```diff
To create buff go to
+ ServerScriptService -> Components -> BuffsComponent -> /newfile/

To check all possible methods go to
+ ServerScriptService -> Components -> BuffsComponent

To see an example go to
+ ServerScriptService -> Components -> BuffsComponent -> TestBuff
```
> [!TIP]
> You can create buff with duration by simply using `task.delay(buffTime, function())`


## How to create a new signal
```diff
To check all possible methods go to
+ ReplicatedStorage -> Components -> SignalComponent
```

**Example**
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
> [!NOTE]
> Signal **MUST** be created on server before client connects to it
>
> Make sure to create any new scopes within the PathConfig `ReplicatedStorage -> Templates -> PathConfig`


...indev...
