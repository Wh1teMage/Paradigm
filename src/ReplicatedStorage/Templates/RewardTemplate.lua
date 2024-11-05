local data = {
	Chances = {},
	Values = {
		ParaCoins = 0,
		Credits = 0,
		Exp = 0,
	}
}

return function()
	local temp = table.clone(data)
	
	temp.Values = table.clone(temp.Values)
	temp.Chances = {}

	return temp
end