local sqrt = math.sqrt

local modInfo = Mod.getInfo()
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
	return sqrt( p )
end

---Cross product (p1-p2, p2-p3)
---@param p1  MapGen.Peak
---@param p2  MapGen.Peak
---@param p3  MapGen.Peak
local function crossProduct(p1, p2, p3)
	local pos1 = p1:getPeakPos()
	local pos2 = p2:getPeakPos()
	local pos3 = p3:getPeakPos()

	local x1, x2 = pos2.x - pos1.x, pos3.x - pos2.x
	local y1, y2 = pos2.z - pos1.z, pos3.z - pos2.z
	return x1 * y2 - y1 * x2
end

---Checks if angle (p1-p2-p3) is flat
---@param p1  MapGen.Peak
---@param p2  MapGen.Peak
---@param p3  MapGen.Peak
local function isFlatAngle(p1, p2, p3)
	return (crossProduct(p1, p2, p3) == 0)
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
	}, {__index = self})

	return instance
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

function Triangle:toString()
	return (('Triangle: \n  %s\n  %s\n  %s')
		:format(tostring(self.p1.getPeakPos()), tostring(self.p2.getPeakPos()), tostring(self.p3.getPeakPos())))
end

---Checks if the triangle is defined clockwise (sequence p1-p2-p3)
function Triangle:isCW()
	return (crossProduct(self.p1, self.p2, self.p3) < 0)
end

---Checks if the triangle is defined counter-clockwise (sequence p1-p2-p3)
function Triangle:isCCW()
	return (crossProduct(self.p1, self.p2, self.p3) > 0)
end

---Returns the length of the edges
function Triangle:getSidesLength()
	return self.e1:length(), self.e2:length(), self.e3:length()
end

---Returns the coordinates of the center
function Triangle:getCenter()
	local pos1 = self.p1:getPeakPos()
	local pos2 = self.p2:getPeakPos()
	local pos3 = self.p3:getPeakPos()

	return (pos1 + pos2 + pos3) / 3
end

---Returns the coordinates of the circumcircle center
function Triangle:getCircumCenter()
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

	return (x / D), (z / D)
end

--- Returns the radius of the circumcircle
function Triangle:getCircumRadius()
	local a, b, c = self:getSidesLength()

	return ((a * b * c) / quatCross(a, b, c))
end

---Returns the coordinates of the circumcircle center and its radius
function Triangle:getCircumCircle()
	local x, z = self:getCircumCenter()
	local r = self:getCircumRadius()

	return x, z, r
end

---Returns the area
function Triangle:getArea()
	local a, b, c = self:getSidesLength()

	return (quatCross(a, b, c) / 4)
end

---Checks if a given point lies into the triangle circumcircle
---@param p  MapGen.Peak
function Triangle:inCircumCircle(p)
	return p:isInCircle(self:getCircumCircle())
end

return Triangle