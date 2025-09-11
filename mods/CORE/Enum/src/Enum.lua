---Abstract class implementing enumeration. It is a table<ENUM_KEY, ENUM_KEY>. Read-only table!
---@abstract
---@class Enum
local Enum = {}

---@param enum  table[]
---@return Enum
function Enum:new(enum)
	local metaEnum = {}

	-- Create table<ENUM_KEY, ENUM_KEY>
	for _, v in ipairs(enum) do
		metaEnum[v] = v
	end

	---@type Enum
	local instance = setmetatable({}, {
		__index = metaEnum,
		__newindex = function()
			error('The Enum table is read only!')
		end,
		__metatable = false
	})

	return instance
end

---@alias Enum.EnumKey  string Key from enumeration

return Enum