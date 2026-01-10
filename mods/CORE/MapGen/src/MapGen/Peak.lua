---@class MapGen.Peak
---@field id                   number
---@field getPeakPos           fun():vector
---@field getColor             fun():ColorString
---@field getGroups            fun():table<string, number>
local Peak = {
	id = 0,
}

-- --- Class registration ---

---Definition table for the `MapGen.Peak`.
---
---**Only for EmmyLua.**
---@class MapGen.PeakDef
---@field pos      vector
---@field color    ColorString
---@field groups?  table<string, number>

---@param def  MapGen.PeakDef
---@return     MapGen.Peak
function Peak:new(def)
	local _pos = def.pos
	local _color = def.color
	local _groups

	if def.groups == nil then
		_groups = {}
	else
		_groups = def.groups
	end

	---@type MapGen.Peak
	local instance = setmetatable({},
	{
		__index    = self,
		__tostring = self.toString,
		__eq       = self.eq
	})

	function instance:getPeakPos()
		return _pos:copy()
	end

	function instance:getColor()
		return _color
	end

	function instance:getGroups()
		return table.copy_with_metatables(_groups)
	end

	return instance
end

---Returns a string describing the object in a readable form.
---@return string
function Peak:toString()
	local pos = self:getPeakPos()
	return ('Peak (%s) x: %.2f y: %.2f z: %.2f'):format( self.id, pos.x, pos.y, pos.z)
end

---Returns true if the peaks are equivalent.
---@param other  MapGen.Peak
---@return       boolean
function Peak:eq(other)
	local pos1 = self:getPeakPos()
	local pos2 = other:getPeakPos()

	return pos1.x == pos2.x and pos1.z == pos2.z
end

return Peak
