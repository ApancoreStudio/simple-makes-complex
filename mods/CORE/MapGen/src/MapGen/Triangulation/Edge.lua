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

return Edge