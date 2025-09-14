---@type Item.VisualEnum
local VisualEnum = Core.Item.require('Item.VisualEnum')

---@class Node : Item
local Node = Core.Item:getModClassExtended({})

---@param nodeDef Node.NodeDefinition
---@return Node
function Node:new(nodeDef)
	nodeDef.settings.visual = VisualEnum.ITEM_3D

	---@type Node
	local instance = Core.Item:getModClassInstance(nodeDef)

	return instance
end

return Node