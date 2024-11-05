local DEFAULT_CURVE = 3
local DEFAULT_STEP = 2

local function Bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: number) : Vector3 
	return p1 + (1-t)^2*(p0 - p1)+t^2*(p2 - p1)
end

local function BezierDerivative(p0: Vector3, p1: Vector3, p2: Vector3, t: number) : Vector3
	return 2*(1 - t)*(p1-p0) + 2*t*(p2-p1)
end

local function MakePart(inputtedCFrame: CFrame)
	local Part = Instance.new("Part")
	Part.Anchored = true
	Part.Transparency = 0.9
	Part.CanCollide = false
	Part.Size = Vector3.one * 1.2
	Part.Color = Color3.new(0.470588, 1, 0.0392157)
	Part.Material = Enum.Material.SmoothPlastic
	Part.CFrame = inputtedCFrame
	Part.Parent = workspace
end

local module = {}

function module:SetupPoints()
	
	table.insert(self.Points, self.OriginalPoints[1])
	
	for i = 2, #self.OriginalPoints - 1 do
		local prevPoint = self.OriginalPoints[i-1]
		local point = self.OriginalPoints[i]
		local nextPoint = self.OriginalPoints[i+1]
		
		local distance1 = (point.Position - nextPoint.Position).Magnitude
		local distance2 = (point.Position - prevPoint.Position).Magnitude
		
		local distance = math.min(distance1, distance2)
		
		local unit1 = (point.Position - prevPoint.Position).Unit
		local unit2 = (point.Position - nextPoint.Position).Unit
		
		local midPoint = CFrame.new(point.Position - unit1 * math.min(self.MaxCurve, distance/3))
		local midPoint2 = CFrame.new(point.Position - unit2 * math.min(self.MaxCurve, distance/3))
		
		local midDistance = (midPoint.Position - midPoint2.Position).Magnitude
		
		table.insert(self.Points, CFrame.new(midPoint.Position, point.Position))
		
		for j = 1, midDistance, self.Step do
			local t = j/midDistance
			local newPoint = Bezier(midPoint.Position, point.Position, midPoint2.Position, t)
			local derivative = BezierDerivative(midPoint.Position, point.Position, midPoint2.Position, t)

			table.insert(self.Points, CFrame.new(newPoint, newPoint + derivative))
		end
		
	end
	
	local lastPoint = self.Points[#self.Points].Position
	local lastOriginalPoint = self.OriginalPoints[#self.OriginalPoints].Position
	
	table.insert(self.Points, 
		CFrame.new(lastOriginalPoint, lastOriginalPoint + (lastOriginalPoint - lastPoint).Unit))
	
	for _, point in pairs(self.Points) do
		MakePart(point)
	end
end

function module.new(parts: {Part}, maxCurve: number?, detalization: number?)
	local points = {}
	
	for i = 1, #parts do
		table.insert(points, parts[i].CFrame)
	end
	
	local self = setmetatable({
		OriginalPoints = points,
		MaxCurve = maxCurve or DEFAULT_CURVE,
		Step = detalization or DEFAULT_STEP,
		Points = {}
	}, {__index = module})
	
	return self
end

return module