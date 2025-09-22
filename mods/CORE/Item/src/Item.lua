local modInfo     = Mod.getInfo()
local require     = modInfo.require

local VisualEnum = require('Item.VisualEnum')

---@class Item
---@field itemDef         Item.ItemDefinition
---@field luantiDef       table
---@field getVisual       fun(): string
---@field defaultItemDef  Item.ItemDefinition
local Item = {
	defaultItemDef = {
		settings = {
			name = ""
		}
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
	return table.merge(..., true)
end

---@param itemDef Item.ItemDefinition
---@return Item
function Item:new(itemDef)
	---Adding default parameters
	itemDef = defMerge(itemDef, self.defaultItemDef)

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
---@param defaultItemDef  Item.ItemDefinition
---@return Item
function Item:getExtended(defaultItemDef)
	---@type Item
	ChildClass = Mod:getClassExtended(self, {
		defaultItemDef = defaultItemDef,
	})

	return ChildClass
end

---Returns an instance of the `Factory` class that can be used to mass-register identical items.
---@param defaultItemDef  Item.ItemDefinition
---@return                Factory
function Item:getFactory(defaultItemDef)
	if defaultItemDef == nil then
		defaultItemDef = self.defaultItemDef
	end

	local instance = Core.Factory():new(self, defaultItemDef)

	return instance
end

return Item
