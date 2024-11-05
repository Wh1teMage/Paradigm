local ContextActionService = game:GetService('ContextActionService')

local Contexts = require(script.Contexts)

local ActionComponent = {}

function ActionComponent.UpdateControls(actions: {code: any, state: any, name: string})
	
	ContextActionService:UnbindAction('ParadigmControls')
	
	local codes = {}
	
	for _, info in pairs(actions) do
		table.insert(codes, info.code)
		info.actionString = tostring(info.code)..tostring(info.state)
	end
	
	print(codes)
	
	ContextActionService:BindAction('ParadigmControls', 
		function(actionName, inputState, inputObject)
			
			local selectedAction;
			local formattedAction = tostring(inputObject.KeyCode)..tostring(inputState)
			
			if (inputObject.KeyCode == Enum.KeyCode.Unknown) then
				formattedAction = tostring(inputObject.UserInputType)..tostring(inputState)
			end
			
			for _, action in pairs(actions) do
				if action.actionString == formattedAction then selectedAction = action; break end
			end

			if (not selectedAction or not Contexts[selectedAction.name]) then return end
			Contexts[selectedAction.name]()
			
		end, false, table.unpack(codes))
end

return ActionComponent
