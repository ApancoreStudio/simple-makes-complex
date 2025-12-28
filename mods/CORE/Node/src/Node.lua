local itemRequire = Mod.getInfo('smc__core__item').require

---@type Item
local Item = itemRequire('Item')

---@type ItemFactory
local ItemFactory = Mod.getInfo('smc__core__item_factory').require('ItemFactory')

---@class Node : Item
---@field defaultDef  Node.NodeDefinition
local Node = Class.extend(Item, {})

---@param nodeDef Node.NodeDefinition
---@return        Node
function Node:new(nodeDef)
	nodeDef.settings.visual = 'item_3d'

	---@type Node
	local instance = Item:new(nodeDef)

	return instance
end

---Allows you to create a child class of an node by specifying
---default parameters that will be added to the node's parameters
---when an instance is received.
---@param defaultDef  Node.NodeDefinition
---@return            Node
function Node:getExtended(defaultDef)
	---@type Node
	local ChildClass = Class.extend(self, {
		defaultDef = defaultDef,
	})

	return ChildClass
end

---Returns an instance of the `ItemFactory` class that can be used to mass-register identical items.
---@param defaultDef?  Node.NodeDefinition
---@return             ItemFactory
function Node:getFactory(defaultDef)
	if defaultDef == nil then
		defaultDef = self.defaultDef
	end

	---@type ItemFactory
	local instance = ItemFactory:new(self, defaultDef)

	return instance
end

return Node