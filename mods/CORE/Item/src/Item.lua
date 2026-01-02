local modInfo = Mod.getInfo('smc__core__item')
local require = modInfo.require

local ItemFactory = Mod.getInfo('smc__core__item_factory').require('ItemFactory')

---@class Item
---@field itemDef         Item.ItemDefinition
---@field luantiDef       table
---@field getVisual       fun(): string
---@field defaultDef      Item.ItemDefinition
local Item = {
	defaultDef = {
		settings = {
			name = "",
			title = "",
			description = "",
		},
		callbacks = {}
	}
}

---The alias `table.merge` for EmmyLua
---@type fun(...):(NodeDefinition|ItemDefinition)
local defMerge = function(...)
	return table.merge(...)
end

---@param itemDef     Item.ItemDefinition
---@param addModName  boolean?  Whether to add the mod name to the settings.name. Default: `true`
---@return            NodeDefinition|ItemDefinition
local function itemDefToLuantiDef(itemDef, addModName)
	local modName = Mod.getInfo().shortName
	local S = core.get_translator(modName)

	if addModName == nil then
		addModName = true
	end

	itemDef = table.copy(itemDef)
	local s = itemDef.settings
	local c = itemDef.callbacks

	if addModName then
		s.name = modName .. ':' .. s.name
	end

	local title = s.title
	local description = s.description

	if title == nil or title == '' then
		title = string.match(s.name, '%S:(%S+)')..'-title'
	end

	if description == nil or description == '' then
		description = string.match(s.name, '%S:(%S+)')..'-desc'
	end

	local description = S(title)..'\n'..core.colorize('#C0C0C0', S(description))

	s.title, s.description = nil, description

	local luantiDef = defMerge(s, c)

	return luantiDef
end

---@param luantiDef  NodeDefinition|ItemDefinition
local function register3dItem(luantiDef)
	local ld = luantiDef
	local name = ld.name
	ld.name = nil
	core.register_node(':'..name, luantiDef)
end

---@param luantiDef  ItemDefinition
local function registerFlatItem(luantiDef)
	local ld = luantiDef
	local name = ld.name
	ld.name = nil
	core.register_craftitem(':'..name, luantiDef)
end

---The alias `table.merge` for EmmyLua
---@type fun(...):(Item.ItemDefinition)
local defMerge = function(...)
	return table.merge(...)
end

---@param itemDef     Item.ItemDefinition|Node.NodeDefinition
---@param addModName  boolean?  Whether to add the mod name to the settings.name. Default: `true`
---@return            Item
function Item:new(itemDef, addModName)
	---Adding default parameters
	itemDef = defMerge(itemDef, self.defaultDef, true)

	---@type Item
	local instance = setmetatable({}, {__index = self})

	local luantiDef = itemDefToLuantiDef(itemDef, addModName)
	local visual = itemDef.settings.visual

	if visual == nil then
		visual = 'item_2d'
	end

	itemDef.settings.visual = nil

	if visual == 'item_3d' then
		register3dItem(luantiDef)
	else
		visual = 'item_2d'
		registerFlatItem(luantiDef)
	end

	function instance:getVisual()
		return visual
	end

	instance.itemDef = itemDef
	instance.luantiDef = luantiDef

	return instance
end

---Allows you to create a child class of an item by specifying
---default parameters that will be added to the item's parameters
---when an instance is received.
---@param defaultDef  Item.ItemDefinition
---@return            Item
function Item:getExtended(defaultDef)
	---@type Item
	local ChildClass = Class.extend(self, {
		defaultDef = defaultDef,
	})

	return ChildClass
end

---Returns an instance of the `ItemFactory` class that can be used to mass-register identical items.
---@param defaultDef?  Item.ItemDefinition
---@return             ItemFactory
function Item:getFactory(defaultDef)
	if defaultDef == nil then
		defaultDef = self.defaultDef
	end

	---@type ItemFactory
	local instance = ItemFactory:new(self, defaultDef)

	return instance
end

return Item
