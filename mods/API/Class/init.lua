---@class Class
Class = {}

---Returns a child class with inherited parameters from the parent class.
---@param parent  table
---@param child   table
function Class.extend(parent ,child)
	return setmetatable(child or {}, { __index = parent })
end