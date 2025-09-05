---@class Item.VisualEnum : Enum
---@field ITEM_2D  Enum.EnumKey
---@field ITEM_3D  Enum.EnumKey
local VisualEnum = Core.Enum:getModClassInstance({
	'ITEM_2D',
	'ITEM_3D',
})

return VisualEnum