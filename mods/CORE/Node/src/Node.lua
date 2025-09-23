---@type Item.VisualEnum
local VisualEnum = Core.Item.require('Item.VisualEnum')

---@class Node : Item
---@field defaultDef  Node.NodeDefinition
local Node = Core.Item:getModClassExtended({})

---@param nodeDef Node.NodeDefinition
---@return Node
function Node:new(nodeDef)
	nodeDef.settings.visual = VisualEnum.ITEM_3D

	---@type Node
	local instance = Core.Item:getModClassInstance(nodeDef)

	return instance
end

---Allows you to create a child class of an node by specifying
---default parameters that will be added to the node's parameters
---when an instance is received.
---@param defaultDef  Node.NodeDefinition
---@return Node
function Node:getExtended(defaultDef)
	---@type Node
	local ChildClass = Mod:getClassExtended(self, {
		defaultDef = defaultDef,
	})

	return ChildClass
end

---Returns an instance of the `Factory` class that can be used to mass-register identical items.
---@param defaultDef?  Node.NodeDefinition
---@return            Factory
function Node:getFactory(defaultDef)
	if defaultDef == nil then
		defaultDef = self.defaultDef
	end

	---@type Factory
	local instance = Core.Factory:getModClassInstance(self, defaultDef)

	return instance
end

return Node