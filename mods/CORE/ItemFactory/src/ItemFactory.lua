---@class ItemFactory
---@field defaultDef  Item.ItemDefinition|Node.NodeDefinition
---@field itemClass   Item|Node
local ItemFactory = {}

---@param itemClass   Item|Node
---@param defaultDef  Item.ItemDefinition|Node.NodeDefinition  Parameters that all nodes registered with this ItemFactory must have.
---@return            ItemFactory
function ItemFactory:new(itemClass, defaultDef)
	---@type ItemFactory
	local instance = setmetatable({
		defaultDef = defaultDef,
		itemClass  = itemClass,
	}, {__index = self})

	return instance
end

---The alias `table.merge` for EmmyLua
---@type fun(...):(Item.ItemDefinition)
local defMerge = function(...)
	return table.merge(...)
end

---@param itemDefs  Item.ItemDefinition[]|Node.NodeDefinition[]  List of nodes with parameters unique to them.
function ItemFactory:registerItems(itemDefs)
	---@param nodeDef  Item.ItemDefinition | Node.NodeDefinition
	for _, itemDef in ipairs(itemDefs) do
		itemDef = defMerge(itemDef, self.defaultDef, true)

		self.itemClass:new(itemDef)

	end
end

---The alias `table.merge` for EmmyLua
---@type fun(...):(Node.NodeDefinition)
local defMerge = function(...)
	return table.merge(...)
end

---@param shortNodeDefs  [string, (string[]|TileDefinition[])?][]  Format list {{name, tiles}, {name, tiles}, ...}
function ItemFactory:registerNodesByShortDef(shortNodeDefs)
	for _, shortNodeDef in ipairs(shortNodeDefs) do
		---@type Node.NodeDefinition
		local nodeDef = {
			settings = {
				name  = shortNodeDef[1],
				tiles = shortNodeDef[2]
			}
		}

		nodeDef = defMerge(nodeDef, self.defaultDef, true)

		self.itemClass:new(nodeDef)
	end
end

return ItemFactory