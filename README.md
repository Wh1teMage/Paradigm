# Paradigm

## [Structure](https://miro.com/app/board/uXjVLKPyetg=/?share_link_id=227356778849)

## Project Initialization

This article will help you to set up the whole system correctly

Preraration
+ Download Visual Studio Code [Here](https://code.visualstudio.com/download)
+ Download Git [Here](https://git-scm.com/downloads/win) (Standalone Installer -> Git for Windows/x64 Setup)
+ Create a Github account [Here](https://github.com/)
+ Install Rojo plugin in RS [Here](https://create.roblox.com/store/asset/6415005344/Rojo-7)

VSC Controls
+ Ctrl + Shift + X to open extensions tab
+ Ctrl + Shift + P to open command palette (or press F1)
+ Ctrl + Shift + G + G to open source control (or find something similar to graphs on your left pannel)

List of extensions to install
+ Rojo - Roblox Studio Sync
+ Roblox LSP
+ Luau Language Server

Now for the project itself

+ Open VSC command palette (F1)
+ Type Git Clone
+ Select the 1st result
+ Paste this link https://github.com/Wh1teMage/Paradigm.git
+ Select the desired destination
+ Login into your github account
+ Head to the lower left corner of the screen (button should have something like master or main on it), click on it
+ In the corresponding menu click "create new branch from"
+ Select dev (or origin/dev) 
+ Name the branch however you want (this will be your main working branch)
+ Now, the lower left corner of the screen should say yours branch name

This branch that you have just created will be mostly used only by you, lets continue to set it up

+ Open VSC command palette
+ Type Tasks Configure Task
+ Select create tasks.json from template
+ Select Other option
+ Delete everything in tasks.json file and paste the following code (should be in #rewrite-discussion, pinned and saved as file)

The whole setup process is done. Moving onto syncing this with RS

+ Open command palette (F1) and type in Rojo: Open Menu
+ Select Install Rojo option (ignore this step if already installed)
+ Now you should be able to run Rojo (command pallete -> Rojo: Open Menu -> default.project.json)

+ Go to Roblox Creator Hub -> Paradigm-Shift Studios
+ Click on PSTD New Core Structure Testing
+ Go to Configure -> Places
+ Find a place with your nickname on it
+ Click Edit in Studio
+ Go to plugins -> Rojo -> Connect
+ Now you should be ready to develop

## Workflow rules

> [!NOTE]
> Whenever you are done with your task (E.x you did a skin system module)
> you should go to command palette, type "Tasks Run Task" and run "Git Sync with Dev"
> that way your local branch will push changes to the dev branch.

Whenever dev branch has enough stable updates, you (one of head devs) should push changes to the main branch
That way the main branch can have a clear update history while the dev one will consist only of small changes

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
