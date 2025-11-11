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
	local deltaMax = mathMax(dx, dy)
	local midx, midy = (minX + maxX) * 0.5, (minY + maxY) * 0.5
	local p1 = FakePeak:new(vector.new( midx - 2 * deltaMax,0, midy - deltaMax ))
	local p2 = FakePeak:new(vector.new(midx,0, midy + 2 * deltaMax ))
	local p3 = FakePeak:new( vector.new(midx + 2 * deltaMax,0, midy - deltaMax ))

	p1.id, p2.id, p3.id = nvertices + 1, nvertices + 2, nvertices + 3
	vertices[p1.id], vertices[p2.id], vertices[p3.id] = p1, p2, p3

	---@type MapGen.Triangle[]
	local triangles = {Triangle:new( vertices[nvertices + 1], vertices[nvertices + 2], vertices[nvertices + 3] )}
	print('Tria:', tostring(triangles[1]))

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
				tableRemove( triangles, j )
			end
		end

		for j = #edges - 1, 1, -1 do
			for k = #edges, j + 1, -1 do
				if edges[j] and edges[k] and edges[j]:same(edges[k]) then
					tableRemove( edges, j )
					tableRemove( edges, k-1 )
				end
			end
		end

		for j = 1, #edges do
			local n = #triangles
			assert(n <= trmax, "Generated more than needed triangles")
			triangles[n + 1] = Triangle:new(edges[j].p1, edges[j].p2, vertices[i])
		end
	end

	for i = #triangles, 1, -1 do
		local triangle = triangles[i]
		if triangle.p1.id > nvertices or triangle.p2.id > nvertices or triangle.p3.id > nvertices then
			tableRemove( triangles, i )
		end
	end

	for _ = 1,3 do
		tableRemove( vertices )
	end

	return triangles
end

return Triangulation