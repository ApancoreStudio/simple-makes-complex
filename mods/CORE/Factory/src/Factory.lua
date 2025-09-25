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
		itemClass  = itemClass,
	}, {__index = self})

	return instance
end

---The alias `table.merge` for EmmyLua
---@type fun(...):(Item.ItemDefinition)
local defMerge = function(...)
	return table.merge(...)
end

---@param itemDefs    Item.ItemDefinition[] | Node.NodeDefinition[]  List of nodes with parameters unique to them.
---@param addModName  boolean  Whether to add the mod name to the settings.name. Default: `true`
function Factory:registerItems(itemDefs, addModName)
	if addModName == nil then
		addModName = true
	end

	local modName = Mod.getInfo().shortName

	---@param nodeDef  Item.ItemDefinition | Node.NodeDefinition
	for _, itemDef in ipairs(itemDefs) do
		itemDef = defMerge(itemDef, self.defaultDef, true)

		if addModName then
			itemDef.settings.name = modName .. ':' .. itemDef.settings.name
		end

		self.itemClass:new(itemDef)

	end
end

---@param shortNodeDefs  table  Table of the form `{ {name, title, description, tiles},  {name, title, description, tiles}, ...}`
---@param addModName     boolean?  Whether to add the mod name to the settings.name. Default: `true`
function Factory:registerNodesByShortDef(shortNodeDefs, addModName)
	if addModName == nil then
		addModName = true
	end

	local modName = Mod.getInfo().shortName

	for _, shortNodeDef in ipairs(shortNodeDefs) do
		---@type Node.NodeDefinition
		local nodeDef = {
			settings = {
				name = shortNodeDef[1],
				title = shortNodeDef[2],
				description = shortNodeDef[3],
				tiles = shortNodeDef[4]
			}
		}
		nodeDef = defMerge(nodeDef, self.defaultDef, true)

		if addModName then
			nodeDef.settings.name = modName .. ':' .. nodeDef.settings.name
		end

		self.itemClass:new(nodeDef)

	end
end

return Factory