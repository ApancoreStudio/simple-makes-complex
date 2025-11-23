-- Tringulation lib
-- Original code: https://github.com/iskolbin/Triangulation/blob/master/Triangulation.lua
-- Date of copying: 07.11.2025
-- Commit: e8d26241767cd6af377b5eda0c1e27122b6afe8a

-- Main changes:
-- * refactoring code to our standard;
-- * splitting code into different files (classes);
-- * Adapting the code to the mapgen concept;
-- * Adding tetrahedralization;

local assert, mathMax,  tableRemove
	= assert, math.max, table.remove

local modInfo = Mod.getInfo('smc__core__map_gen')
local require = modInfo.require

---@type MapGen.Triangle
local Triangle = require('MapGen.Triangle')
---@type MapGen.Tetrahedron
local Tetrahedron = require('MapGen.Tetrahedron')
---@type MapGen.Triangulation.FakePeak
local FakePeak = require('MapGen.Triangulation.FakePeak')

---@class MapGen.Triangulation
---@field convexMultiplier  number
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
	vertices = table.copy_with_metatables(vertices)

	-- Only peaks with a `is2d` group can be triangulated.
	for i, vertex in ipairs(vertices) do
		if vertex:getGroups().is2d == nil then
			table.remove(vertices, i)
		end
	end

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

---The Delaunay method divides space into tetrahedra based on a list of their vertices.
---
---Vertices that do not have a `is3d` group will not participate in the triangulation.
---@param vertices  table<integer, MapGen.Peak>
function Triangulation.tetrahedralize(vertices)
	vertices = table.copy_with_metatables(vertices)

	-- Only peaks with a `is3d` group can be triangulated.
	for i, vertex in ipairs(vertices) do
		if vertex:getGroups().is3d == nil then
			table.remove(vertices, i)
		end
	end

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