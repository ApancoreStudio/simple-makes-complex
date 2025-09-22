---@class Factory
---@field defaultDef  Item.ItemDefinition | Node.NodeDefinition
---@field itemClass       Item | Node
local Factory = {}

---@param itemClass       Item | Node
---@param defaultDef  Item.ItemDefinition | Node.NodeDefinition  Parameters that all nodes registered with this factory must have.
---@return                Factory
function Factory:new(itemClass, defaultDef)
	---@type Factory
	local instance = setmetatable({
		defaultDef = defaultDef,
		itemClass      = itemClass,
	}, {__index = self})

	return instance
end

---The aleas `table.merge` for EmmyLua
---@type fun(...):(Item.ItemDefinition)
local defMerge = function(...)
	return table.merge(...)
end

---@param itemDefs  Item.ItemDefinition[] | Node.NodeDefinition[]  List of nodes with parameters unique to them.
function Factory:registerItems(itemDefs)
	---@param nodeDef  Item.ItemDefinition | Node.NodeDefinition
	for _, nodeDef in ipairs(itemDefs) do

		---@type Item.ItemDefinition
		local nodeDef = defMerge(nodeDef, self.defaultDef, true)

		self.itemClass:new(nodeDef)

	end
end

return Factory