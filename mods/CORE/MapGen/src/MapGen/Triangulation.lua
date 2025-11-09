-- SMC tringulation lib
-- Original code: https://github.com/iskolbin/Triangulation/blob/master/Triangulation.lua
-- Date of copying: 07.11.2025
-- Commit: e8d26241767cd6af377b5eda0c1e27122b6afe8a

local setmetatable, tostring, assert = setmetatable, tostring, assert
local max, sqrt = math.max, math.sqrt
local remove = table.remove

local modInfo = Mod.getInfo()
local require = modInfo.require

---@type MapGen.Peak
local Peak = require("MapGen.Peak")

--local isffi = false, ffi = pcall( require, 'ffi' )

--local ffiPoint, ffiEdge, ffiTriangle

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

---@class MapGen.Triangulation.FakePeak : MapGen.Peak
---@field id          number
---@field getPeakPos  fun():vector
local FakePeak = Mod:getClassExtended(Peak, {})

---@param peakPos  vector
---@return         MapGen.Peak
function FakePeak:new(peakPos)
	local instance = Peak:new(peakPos, {}, 1)

	return instance
end

---@class MapGen.Triangulation.Edge
---@field p1  MapGen.Peak
---@field p2  MapGen.Peak
local Edge = {}

---@param p1  MapGen.Peak
---@param p2  MapGen.Peak
---@return    MapGen.Triangulation.Edge
function Edge:new( p1, p2 )
	local instance = setmetatable({
		p1 = p1,
		p2 = p2
	}, {__index = self})

	return instance
end

---@param other  MapGen.Triangulation.Edge
function Edge:__eq( other )
	return self.p1 == other.p1 and self.p2 == other.p2
end

function Edge:__tostring()
	return (('Edge :\n  %s\n  %s'):format(tostring(self.p1), tostring(self.p2)))
end

function Edge:same(otherEdge)
	return ((self.p1 == otherEdge.p1) and (self.p2 == otherEdge.p2))
		or ((self.p1 == otherEdge.p2) and (self.p2 == otherEdge.p1))
end

function Edge:length()
	return self.p1:dist(self.p2)
end

---@return vector
function Edge:getMidPoint()
	local pos1 = self.p1:getPeakPos()
	local pos2 = self.p2:getPeakPos()

	return (pos1 + pos2 )/2
end

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

function Triangle:__tostring()
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

---@class MapGen.Triangulation
local Triangulation = {
	convexMultiplier = 1e3,
}

---Triangulates a set of given vertices
---@param vertices  table<integer, MapGen.Peak>
function Triangulation.triangulate( vertices )
	local nvertices = #vertices

	assert( nvertices > 2, "Cannot triangulate, needs more than 3 vertices" )

	if nvertices == 3 then
		return {Triangle:new(vertices[1], vertices[2], vertices[3])}
	end

	local trmax = nvertices * 4
	local minX, minY = vertices[1].getPeakPos().x, vertices[1].getPeakPos().z
	local maxX, maxY = minX, minY

	for i = 1, #vertices do
		local vertex = vertices[i]
		local vertexPos = vertex.getPeakPos()
		vertex.id = i

		if vertexPos.x < minX then
			minX = vertexPos.x
		end

		if vertexPos.z < minY then
			minY = vertexPos.z
		end

		if vertexPos.x > maxX then
			maxX = vertexPos.x
		end

		if vertexPos.z > maxY then
			maxY = vertexPos.z
		end
	end

	---Finding the vertices of a supertriangle
	local convex_mult = Triangulation.convexMultiplier
	local dx, dy = (maxX - minX) * convex_mult, (maxY - minY) * convex_mult
	local deltaMax = max(dx, dy)
	local midx, midy = (minX + maxX) * 0.5, (minY + maxY) * 0.5
	local p1 = FakePeak:new(vector.new( midx - 2 * deltaMax,0, midy - deltaMax ))
	local p2 = FakePeak:new(vector.new(midx,0, midy + 2 * deltaMax ))
	local p3 = FakePeak:new( vector.new(midx + 2 * deltaMax,0, midy - deltaMax ))

	p1.id, p2.id, p3.id = nvertices + 1, nvertices + 2, nvertices + 3
	vertices[p1.id], vertices[p2.id], vertices[p3.id] = p1, p2, p3

	---@type MapGen.Triangle[]
	local triangles = {Triangle:new( vertices[nvertices + 1], vertices[nvertices + 2], vertices[nvertices + 3] )}

	for i = 1, nvertices do
		---@type MapGen.Triangulation.Edge[]
		local edges = {}
		local ntriangles = #triangles

		for j = #triangles, 1, -1 do
			local curTriangle = triangles[j]

			if curTriangle:inCircumCircle(vertices[i]) then
				edges[#edges + 1] = curTriangle.e1
				edges[#edges + 1] = curTriangle.e2
				edges[#edges + 1] = curTriangle.e3
				remove( triangles, j )
			end
		end

		for j = #edges - 1, 1, -1 do
			for k = #edges, j + 1, -1 do
				if edges[j] and edges[k] and edges[j]:same(edges[k]) then
					remove( edges, j )
					remove( edges, k-1 )
				end
			end
		end

		for j = 1, #edges do
			local n = #triangles
			assert(n <= trmax, "Generated more than needed triangles")
			triangles[n + 1] = Triangle:new(edges[j].p1, edges[j].p2, vertices[i])
		end
	end
	for _, tri in ipairs(triangles) do
		print('tria:', tri:__tostring())
	end
	print('---')
	for _, v in ipairs(vertices) do
		print('v: ', tostring(v:getPeakPos()))
	end
	print('---')
	for i = #triangles, 1, -1 do
		local triangle = triangles[i]
		if triangle.p1.id > nvertices or triangle.p2.id > nvertices or triangle.p3.id > nvertices then
			remove( triangles, i )
		end
	end

	for _ = 1,3 do
		remove( vertices )
	end

	return triangles
end

--[[
function Triangulation.setffi( set )
	if ffi then
		isffi = set
	end
end

if isffi then
	ffi.cdef(([[
	typedef struct { %s x, z; uint32_t id; } Point;
	typedef struct { Point p1, p2; } Edge;
	typedef struct { Point p1, p2, p3; Edge e1, e2, e3; } Triangle;
	] ]):format( _G.DELAUNAY_FFI_TYPE or 'double' ))

	ffiPoint = ffi.metatype( "Point", Point )
	ffiEdge = ffi.metatype( "Edge", Edge )
	ffiTriangle = ffi.metatype( "Triangle", Triangle )
end --]]

return Triangulation