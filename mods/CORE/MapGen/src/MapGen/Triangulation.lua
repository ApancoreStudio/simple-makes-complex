-- SMC tringulation lib
-- Original code: https://github.com/iskolbin/Triangulation/blob/master/Triangulation.lua
-- Date of copying: 07.11.2025
-- Commit: e8d26241767cd6af377b5eda0c1e27122b6afe8a

local assert = assert
local mathMax = math.max
local tableRemove = table.remove

local modInfo = Mod.getInfo()
local require = modInfo.require

---@type MapGen.Triangle
local Triangle = require('MapGen.Triangle')
---@type MapGen.Triangulation.FakePeak
local FakePeak = require('MapGen.Triangulation.FakePeak')


---@class MapGen.Triangulation
local Triangulation = {
	convexMultiplier = 1e3,
}

---The Delaunay method divides a plane into triangles based on a list of their vertices.
---
---Doesn't take into account the Y coordinate of the vertices.
---That is, all triangles that don't lie in the XZ plane will be projected onto it.
---
---Vertices that do not have a `is2d` group will not participate in the triangulation.
---@param vertices  table<integer, MapGen.Peak>
function Triangulation.triangulate( vertices )
	-- Only peaks with a `is2d` group can be triangulated.
	--[[for i, vertex in ipairs(vertices) do
		if vertex:getGroups().is2d == nil then
			table.remove(vertices, i)
		end
	end--]]

	local nvertices = #vertices

	assert( nvertices > 2, "Cannot triangulate, needs more than 3 vertices" )

	if nvertices == 3 then
		return {Triangle:new(vertices[1], vertices[2], vertices[3])}
	end

	local minPos = vertices[1].getPeakPos()
	local minX, minY = minPos.x, minPos.z
	local maxX, maxY = minX, minY

	for i = 1, nvertices do
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
	local deltaMax = mathMax(dx, dy)
	local midx, midy = (minX + maxX) * 0.5, (minY + maxY) * 0.5

	local p1 = FakePeak:new(vector.new( midx - 2 * deltaMax,0, midy - deltaMax ))
	local p2 = FakePeak:new(vector.new(midx,0, midy + 2 * deltaMax ))
	local p3 = FakePeak:new( vector.new(midx + 2 * deltaMax,0, midy - deltaMax ))

	p1.id, p2.id, p3.id = nvertices + 1, nvertices + 2, nvertices + 3
	vertices[p1.id], vertices[p2.id], vertices[p3.id] = p1, p2, p3

	---@type MapGen.Triangle[]
	local triangles = {Triangle:new( vertices[nvertices + 1], vertices[nvertices + 2], vertices[nvertices + 3] )}

	print('uu:', tostring(triangles[1]))
	for i = 1, nvertices do
		---@type MapGen.Triangulation.Edge[]
		local edges = {}

		-- Finding bad triangles.
		for j = #triangles, 1, -1 do
			local curTriangle = triangles[j]

			if curTriangle:inCircumCircle2D(vertices[i]) then
				edges[#edges + 1] = curTriangle.e1
				edges[#edges + 1] = curTriangle.e2
				edges[#edges + 1] = curTriangle.e3
				tableRemove( triangles, j )
			end
		end

		-- Removing duplicate edges.
		for j = #edges - 1, 1, -1 do
			for k = #edges, j + 1, -1 do
				if edges[j] and edges[k] and edges[j]:same(edges[k]) then
					tableRemove( edges, j )
					tableRemove( edges, k-1 )
				end
			end
		end

		-- Create new triangles.
		for j = 1, #edges do
			triangles[#triangles + 1] = Triangle:new(edges[j].p1, edges[j].p2, vertices[i])
		end
	end

	-- Remove tetrahedra associated with the vertices of a supertriangle.
	for i = #triangles, 1, -1 do
		local triangle = triangles[i]
		if triangle.p1.id > nvertices or triangle.p2.id > nvertices or triangle.p3.id > nvertices then
			tableRemove( triangles, i )
		end
	end

	-- Removing the vertices of a super supertriangle.
	for _ = 1,3 do
		tableRemove( vertices )
	end

	return triangles
end

--- DEV ---

local modInfo = Mod.getInfo()
local require = modInfo.require

---@type MapGen.Triangle
local Triangle = require('MapGen.Triangle')
---@type MapGen.Triangulation.FakePeak
local FakePeak = require('MapGen.Triangulation.FakePeak')

-- Класс Тетраэдр
---@class MapGen.Tetrahedron
---@field p1  MapGen.Peak
---@field p2  MapGen.Peak
---@field p3  MapGen.Peak
---@field p4  MapGen.Peak
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

	if math.abs(det) < 0 then
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

---The Delaunay method divides space into tetrahedra based on a list of their vertices.
---
---Vertices that do not have a `is3d` group will not participate in the triangulation.
---@param vertices  table<integer, MapGen.Peak>
function Triangulation.tetrahedralize(vertices)
	--[[vertices = table.copy(vertices)

	-- Only peaks with a `is3d` group can be triangulated.
	for i, vertex in ipairs(vertices) do
		if vertex:getGroups().is3d == nil then
			table.remove(vertices, i)
		end
	end--]]

	print(dump(vertices))

	local nvertices = #vertices

	assert(nvertices > 3, "Cannot tetrahedralize, needs more than 4 vertices")

	if nvertices == 4 then
		return {Tetrahedron:new(vertices[1], vertices[2], vertices[3], vertices[4])}
	end

	local minPos = vertices[1].getPeakPos()
	local minX, minY, minZ = minPos.x, minPos.y, minPos.z
	local maxX, maxY, maxZ = minX, minY, minZ

	for i = 1, nvertices do
		local vertex = vertices[i]
		local vertexPos = vertex.getPeakPos()
		vertex.id = i

		if vertexPos.x < minX then
			minX = vertexPos.x
		end

		if vertexPos.y < minY then
			minY = vertexPos.y
		end

		if vertexPos.z < minZ then
			minZ = vertexPos.z
		end

		if vertexPos.x > maxX then
			maxX = vertexPos.x
		end

		if vertexPos.y > maxY then
			maxY = vertexPos.y
		end

		if vertexPos.z > maxZ then
			maxZ = vertexPos.z
		end
	end

	-- Finding the vertices of a supertetrahedron
	local convex_mult = Triangulation.convexMultiplier
	local dx, dy, dz = (maxX - minX) * convex_mult, (maxY - minY) * convex_mult, (maxZ - minZ) * convex_mult
	local deltaMax = mathMax(dx, dy, dz)
	local midx, midy, midz = (minX + maxX) * 0.5, (minY + maxY) * 0.5, (minZ + maxZ) * 0.5

	local p1 = FakePeak:new(vector.new(midx - 2 * deltaMax, midy - deltaMax, midz - deltaMax))
	local p2 = FakePeak:new(vector.new(midx + 2 * deltaMax, midy - deltaMax, midz - deltaMax))
	local p3 = FakePeak:new(vector.new(midx, midy + 2 * deltaMax, midz - deltaMax))
	local p4 = FakePeak:new(vector.new(midx, midy, midz + 2 * deltaMax))

	p1.id, p2.id, p3.id, p4.id = nvertices + 1, nvertices + 2, nvertices + 3, nvertices + 4
	vertices[p1.id], vertices[p2.id], vertices[p3.id], vertices[p4.id] = p1, p2, p3, p4

	---@type MapGen.Tetrahedron[]
	local tetrahedrons = {Tetrahedron:new(p1, p2, p3, p4)}

	for i = 1, nvertices do
		print(vertices[i]:toString())
		---@type MapGen.Triangle[]
		local faces = {}

		-- Finding bad tetrahedrons.
		for j = #tetrahedrons, 1, -1 do
			local curTetrahedron = tetrahedrons[j]

			if curTetrahedron:inCircumSphere(vertices[i]) then
				faces[#faces + 1] = curTetrahedron.f1
				faces[#faces + 1] = curTetrahedron.f2
				faces[#faces + 1] = curTetrahedron.f3
				faces[#faces + 1] = curTetrahedron.f4
				tableRemove(tetrahedrons, j)
			end
		end

		-- Removing duplicate faces.
		for j = #faces - 1, 1, -1 do
			for k = #faces, j + 1, -1 do
				if faces[j] and faces[k] and faces[j]:same(faces[k]) then
					tableRemove( faces, j )
					tableRemove( faces, k-1 )
				end
			end
		end

		-- Create new tetrahedrons.
		for j = 1, #faces do
			tetrahedrons[#tetrahedrons + 1] = Tetrahedron:new(faces[j].p1, faces[j].p2, faces[j].p3, vertices[i])
		end

		print('aboba')
	end

	-- Remove tetrahedra associated with the vertices of a supertetrahedron.
	for i = #tetrahedrons, 1, -1 do
		local tetrahedron = tetrahedrons[i]
		if tetrahedron.p1.id > nvertices or tetrahedron.p2.id > nvertices or tetrahedron.p3.id > nvertices or tetrahedron.p4.id > nvertices then
			tableRemove( tetrahedrons, i )
		end
	end

	-- Removing the vertices of a supertetrahedron.
	for i = 1, 4 do
		tableRemove( vertices )
	end

	return tetrahedrons
end


return Triangulation