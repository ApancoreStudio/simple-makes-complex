local modInfo     = Mod.getInfo()
local require     = modInfo.require

local VisualEnum = require('Item.VisualEnum')

---@class Item
---@field itemDef         Item.ItemDefinition
---@field luantiDef       table
---@field getVisual       fun(): string
---@field defaultDef  Item.ItemDefinition
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

---@param itemDef  Item.ItemDefinition
local function itemDefToLuantiDef(itemDef)
	itemDef = table.copy(itemDef)
	local s = itemDef.settings
	local c = itemDef.callbacks
	local description = s.title .. "\n" .. s.description
	s.title, s.description = nil, description

	local luantiDef = table.merge(s, c)

	return luantiDef
end

---@param luantiDef  table
local function register3dItem(luantiDef)
	local ld = luantiDef
	local name = ld.name
	ld.name = nil
	core.register_node(':'..name, luantiDef)
end

---@param luantiDef  table
local function registerFlatItem(luantiDef)
	local ld = luantiDef
	local name = ld.name
	ld.name = nil
	core.register_craftitem(':'..name, luantiDef)
end

---The aleas `table.merge` for EmmyLua
---@type fun(...):(Item.ItemDefinition)
local defMerge = function(...)
	return table.merge(...)
end

---@param itemDef Item.ItemDefinition
---@return Item
function Item:new(itemDef)
	---Adding default parameters
	itemDef = defMerge(itemDef, self.defaultDef, true)

	---@type Item
	local instance = setmetatable({}, {__index = self})

	local luantiDef = itemDefToLuantiDef(itemDef)
	local visual = itemDef.settings.visual

	if visual == nil then
		visual = VisualEnum.ITEM_2D
	end

	itemDef.settings.visual = nil

	if visual == VisualEnum.ITEM_3D then
		register3dItem(luantiDef)
	else
		visual = VisualEnum.ITEM_2D
		registerFlatItem(luantiDef)
	end

	---@return string
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
---@return Item
function Item:getExtended(defaultDef)
	---@type Item
	local ChildClass = Mod:getClassExtended(self, {
		defaultDef = defaultDef,
	})

	return ChildClass
end

---Returns an instance of the `Factory` class that can be used to mass-register identical items.
---@param defaultDef?  Item.ItemDefinition
---@return            Factory
function Item:getFactory(defaultDef)
	if defaultDef == nil then
		defaultDef = self.defaultDef
	end

	local instance = Core.Factory():new(self, defaultDef)

	return instance
end

return Item
