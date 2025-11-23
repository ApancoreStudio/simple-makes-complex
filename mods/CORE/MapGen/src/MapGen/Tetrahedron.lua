local mathAbs = math.abs

local modInfo = Mod.getInfo('smc__core__map_gen')
local require = modInfo.require

---@type MapGen.Triangle
local Triangle = require('MapGen.Triangle')
---@type MapGen.Triangulation.Edge
local Edge = require('MapGen.Triangulation.Edge')
---@type MapGen.Triangulation.FakePeak
local FakePeak = require('MapGen.Triangulation.FakePeak')

---@class MapGen.Tetrahedron
---@field p1  MapGen.Peak
---@field p2  MapGen.Peak
---@field p3  MapGen.Peak
---@field p4  MapGen.Peak
---@field h1  MapGen.Triangulation.Edge
---@field h2  MapGen.Triangulation.Edge
---@field h3  MapGen.Triangulation.Edge
---@field h4  MapGen.Triangulation.Edge
---@field f1  MapGen.Triangle
---@field f2  MapGen.Triangle
---@field f3  MapGen.Triangle
---@field f4  MapGen.Triangle
local Tetrahedron = {}

---@param p1  MapGen.Peak
---@param p2  MapGen.Peak
---@param p3  MapGen.Peak
---@param p4  MapGen.Peak
---@return    MapGen.Tetrahedron
function Tetrahedron:new(p1, p2, p3, p4)
	local instance = setmetatable({
		p1 = p1,
		p2 = p2,
		p3 = p3,
		p4 = p4,
		h1 = self:getHeight(p1, p2, p3, p4),
		h2 = self:getHeight(p2, p3, p4, p1),
		h3 = self:getHeight(p3, p4, p1, p2),
		h4 = self:getHeight(p4, p1, p2, p3),
		f1 = Triangle:new(p1, p2, p3),
		f2 = Triangle:new(p1, p2, p4),
		f3 = Triangle:new(p1, p3, p4),
		f4 = Triangle:new(p2, p3, p4),
	}, {
		__index    = self,
		__tostring = self.toString
	})

	return instance
end

---Returns a string describing the object in a readable form.
---@return string
function Tetrahedron:toString()
	return ('Tetrahedron: \n  %s\n  %s\n  %s\n  %s'):format(
			tostring(self.p1.getPeakPos()),
			tostring(self.p2.getPeakPos()),
			tostring(self.p3.getPeakPos()),
			tostring(self.p4.getPeakPos())
		)
end

---@param p1  MapGen.Peak
---@param p2  MapGen.Peak
---@param p3  MapGen.Peak
---@param p4  MapGen.Peak
function Tetrahedron:getHeight(p1, p2, p3, p4)
	local pos1 = p1:getPeakPos()
	local pos2 = p2:getPeakPos()
	local pos3 = p3:getPeakPos()
	local pos4 = p4:getPeakPos()

	-- Векторы, лежащие в плоскости
	local AB = pos3 - pos2
	local AC = pos4 - pos2

	-- Нормаль к плоскости
	local normal = AB:cross(AC)
	local normal_length = normal:length()

	-- Если плоскость вырождена (точки на одной прямой)
	if normal_length < 1e-10 then
		return nil  -- или другая обработка ошибки
	end

	-- Вектор от точки на плоскости к нашей точке
	local AP = pos1 - pos2

	-- Расстояние от точки до плоскости
	local distance = AP:dot(normal) / normal_length

	-- Проекция точки на плоскость (вектор!)
	local projection = pos1 - (normal * (distance / normal_length))

	return Edge:new(p1, FakePeak:new(projection))
end

---Returns the center of the circumscribed sphere.
---@return vector
function Tetrahedron:getCircumSphereCenter()
	local pos1 = self.p1.getPeakPos()
	local pos2 = self.p2.getPeakPos()
	local pos3 = self.p3.getPeakPos()
	local pos4 = self.p4.getPeakPos()

	local a = pos2 - pos1
	local b = pos3 - pos1
	local c = pos4 - pos1

	local a2 = a:dot(a)
	local b2 = b:dot(b)
	local c2 = c:dot(c)

	local cross_bc = b:cross(c)
	local cross_ca = c:cross(a)
	local cross_ab = a:cross(b)

	local det = a:dot(b:cross(c)) * 2

	if mathAbs(det) < 0 then
		return (pos1 + pos2 + pos3 + pos4) / 4
	end

	local center = pos1 + (cross_bc * a2 + cross_ca * b2 + cross_ab * c2) / det

	return center
end

---Returns the radius of the circumscribed sphere.
---@return  number
function Tetrahedron:getCircumSphereRadius()
	local center = self:getCircumSphereCenter()
	local pos1 = self.p1.getPeakPos()
	return (pos1 - center):length()
end

---Checks whether a given point lies within the circumscribed sphere of a tetrahedron.
---@param p  MapGen.Peak
function Tetrahedron:inCircumSphere(p)
	local pos = p.getPeakPos()
	local c = self:getCircumSphereCenter()
	local r = self:getCircumSphereRadius()

	local distance = (pos - c):length()

	return distance <= r
end

return Tetrahedron
