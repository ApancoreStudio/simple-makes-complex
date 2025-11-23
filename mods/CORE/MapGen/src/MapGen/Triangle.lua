local mathSqrt,  mathAbs
	= math.sqrt, math.abs

local modInfo = Mod.getInfo('smc__core__map_gen')
local require = modInfo.require

---@type MapGen.Triangulation.Edge
local Edge = require('MapGen.Triangulation.Edge')
---@type MapGen.Triangulation.FakePeak
local FakePeak = require('MapGen.Triangulation.FakePeak')

-- Helpers functions --

---Triangle semi-perimeter by Heron's formula
---@param a  number
---@param b  number
---@param c  number
---@return   number
local function quatCross(a, b, c)
	local p = (a + b + c) * (a + b - c) * (a - b + c) * (-a + b + c)
	return mathSqrt(p)
end

---Checks if points p1, p2, p3 are collinear (angle p1-p2-p3 is 180 degrees)
---@param p1  MapGen.Peak
---@param p2  MapGen.Peak
---@param p3  MapGen.Peak
---@return    boolean
local function isFlatAngle(p1, p2, p3)
	local pos1 = p1:getPeakPos()
	local pos2 = p2:getPeakPos()
	local pos3 = p3:getPeakPos()

	local vec1 = pos1 - pos2  -- Vector from p2 to p1
	local vec2 = pos3 - pos2  -- Vector from p2 to p3

	-- Normalize vectors
	local len1 = vec1:length()
	local len2 = vec2:length()

	if len1 < 0 or len2 < 0 then
		return true  -- Degenerate case: points are too close
	end

	vec1 = vec1 / len1
	vec2 = vec2 / len2

	-- If dot product is -1, vectors are opposite (180° angle)
	local dot = vec1:dot(vec2)
	return mathAbs(dot + 1.0) < 0
end

-- Class registration --

---@class MapGen.Triangle
---@field p1  MapGen.Peak
---@field p2  MapGen.Peak
---@field p3  MapGen.Peak
---@field e1  MapGen.Triangulation.Edge
---@field e2  MapGen.Triangulation.Edge
---@field e3  MapGen.Triangulation.Edge
---@field h1  MapGen.Triangulation.Edge
---@field h2  MapGen.Triangulation.Edge
---@field h3  MapGen.Triangulation.Edge
local Triangle = {}

---@param p1  MapGen.Peak
---@param p2  MapGen.Peak
---@param p3  MapGen.Peak
---@return    MapGen.Triangle
function Triangle:new( p1, p2, p3 )
	assert(not isFlatAngle(p1, p2, p3), ("angle (p1, p2, p3) is flat:\n  %s\n  %s\n  %s")
		:format(tostring(p1), tostring(p2), tostring(p3)))

	local instance = setmetatable({
		p1 = p1,
		p2 = p2,
		p3 = p3,
		h1 = Triangle:getHeight(p1, p2, p3),
		h2 = Triangle:getHeight(p2, p3, p1),
		h3 = Triangle:getHeight(p3, p1, p2),
		e1 = Edge:new(p1, p2),
		e2 = Edge:new(p2, p3),
		e3 = Edge:new(p3, p1)
	},
	{
		__index    = self,
		__tostring = self.toString,
		__eq       = self.eq
	})

	return instance
end

---Returns a string describing the object in a readable form.
---@return string
function Triangle:toString()
	return ('Triangle: \n  %s\n  %s\n  %s'):format(
		tostring(self.p1.getPeakPos()),
		tostring(self.p2.getPeakPos()),
		tostring(self.p3.getPeakPos())
	)
end

---@param other  MapGen.Triangle
---@return       boolean
function Triangle:eq( other )
	return self.p1 == other.p1 and self.p2 == other.p2 and self.p3 == other.p3
end

---@param other  MapGen.Triangle
---@return       boolean
function Triangle:same(other)
	return (self.p1 == other.p1 and self.p2 == other.p2 and self.p3 == other.p3)
		or (self.p1 == other.p2 and self.p2 == other.p3 and self.p3 == other.p1)
		or (self.p1 == other.p3 and self.p2 == other.p1 and self.p3 == other.p2)
end

---Returns the coordinates of the center
---@return vector
function Triangle:getCenter()
	local pos1 = self.p1:getPeakPos()
	local pos2 = self.p2:getPeakPos()
	local pos3 = self.p3:getPeakPos()

	return (pos1 + pos2 + pos3) / 3
end

---Returns the area
---@return number
function Triangle:getArea()
	local a, b, c = self:getSidesLength()

	return (quatCross(a, b, c) / 4)
end

---Returns the length of the perpendicular
---from Peak1 to the line Peak2-Peak3
---@param p1  MapGen.Peak
---@param p2  MapGen.Peak
---@param p3  MapGen.Peak
---@return    MapGen.Triangulation.Edge
function Triangle:getHeight(p1, p2, p3)
	local pos1 = p1:getPeakPos()
	local pos2 = p2:getPeakPos()
	local pos3 = p3:getPeakPos()

	local v = pos3 - pos2
	---@type vector
	local w = pos1 - pos2

	-- Formula: (w * v) / (v * v)
	-- When * the dot product.
	local t = w:dot(v) / v:dot(v)

	local posP = pos2 + v * t

	return Edge:new(p1, FakePeak:new(posP))
end

---Returns the length of the perpendicular
---from Peak1 to the line Peak2-Peak3
---@param p1  MapGen.Peak
---@param p2  MapGen.Peak
---@param p3  MapGen.Peak
---@return    MapGen.Triangulation.Edge
function Triangle:getHeight2D(p1, p2, p3)
	local pos1 = p1:getPeakPos()
	local pos2 = p2:getPeakPos()
	local pos3 = p3:getPeakPos()

	pos1.y = 0
	pos2.y = 0
	pos3.y = 0

	local v = pos3 - pos2
	---@type vector
	local w = pos1 - pos2

	-- Formula: (w * v) / (v * v)
	-- When * the dot product.
	local t = w:dot(v) / v:dot(v)

	local posP = pos2 + v * t

	return Edge:new(p1, FakePeak:new(posP))
end

---Returns the length of the edges
---@return number, number, number
function Triangle:getSidesLength()
	return self.e1:length(), self.e2:length(), self.e3:length()
end

---Returns the length of the edges
---
---Note: This function does not take into account the Y-coordinate,
---that is, the calculation is performed on the projection of the triangle XZ
---@return number, number, number
function Triangle:getSidesLength2D()
	local pos1 = self.p1:getPeakPos()
	local pos2 = self.p2:getPeakPos()
	local pos3 = self.p3:getPeakPos()

	pos1.y = 0
	pos2.y = 0
	pos3.y = 0

	return (pos2 - pos1):length(), (pos3 - pos2):length(), (pos1 - pos3):length()
end

---Returns the coordinates of the circumcircle center
---
---Note: This function does not take into account the Y-coordinate,
---that is, the calculation is performed on the projection of the triangle XZ
---@return vector
function Triangle:getCircumCenter2D()
	local pos1 = self.p1:getPeakPos()
	local pos2 = self.p2:getPeakPos()
	local pos3 = self.p3:getPeakPos()

	local D =  ( pos1.x * (pos2.z - pos3.z) +
				pos2.x * (pos3.z - pos1.z) +
				pos3.x * (pos1.z - pos2.z)) * 2
	local x = (( pos1.x * pos1.x + pos1.z * pos1.z) * (pos2.z - pos3.z) +
				( pos2.x * pos2.x + pos2.z * pos2.z) * (pos3.z - pos1.z) +
				( pos3.x * pos3.x + pos3.z * pos3.z) * (pos1.z - pos2.z))
	local z = (( pos1.x * pos1.x + pos1.z * pos1.z) * (pos3.x - pos2.x) +
				( pos2.x * pos2.x + pos2.z * pos2.z) * (pos1.x - pos3.x) +
				( pos3.x * pos3.x + pos3.z * pos3.z) * (pos2.x - pos1.x))

	return vector.new(x / D, 0, z / D)
end

---Returns the radius of the circumcircle
---
---Note: This function does not take into account the Y-coordinate,
---that is, the calculation is performed on the projection of the triangle XZ
---@return number
function Triangle:getCircumRadius2D()
	local a, b, c = self:getSidesLength2D()

	return ((a * b * c) / quatCross(a, b, c))
end

---Returns the coordinates of the circumcircle center and its radius
---
---Note: This function does not take into account the Y-coordinate,
---that is, the calculation is performed on the projection of the triangle XZ
---@return vector, number
function Triangle:getCircumCircle2D()
	local c = self:getCircumCenter2D()
	local r = self:getCircumRadius2D()

	return c, r
end

---Checks if a given point lies into the triangle circumcircle
---
---Note: This function does not take into account the Y-coordinate,
---that is, the calculation is performed on the projection of the triangle XZ
---@param p  MapGen.Peak
---@return   boolean
function Triangle:inCircumCircle2D(p)
	local pos = p:getPeakPos()

	local c, r = self:getCircumCircle2D()

	local distance = (c - pos):length()

	return distance <= r
end

return Triangle