---@type Item.VisualEnum
local VisualEnum = Core.Item.require('Item.VisualEnum')

---@class Node : Item
local Node = Core.Item:getModClassExtended({
	--TODO: Че тут писать?
})

---@param itemDef Item.ItemDefinition
---@return Node
function Node:new(itemDef)
	itemDef.settings.visual = VisualEnum.ITEM_3D

	---@type Node
	local instance = Core.Item:getModClassInstance(itemDef)

	return instance
end

return Node