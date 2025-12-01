---@type Enum
local Enum = Mod.getInfo('smc__core__enum').require('Enum')

---@class Item.VisualEnum : Enum
---@field ITEM_2D  Enum.EnumKey
---@field ITEM_3D  Enum.EnumKey
local VisualEnum = Enum:new({
	'ITEM_2D',
	'ITEM_3D',
})

return VisualEnum