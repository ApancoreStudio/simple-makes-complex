---@class Item
---@field itemDef    Item.ItemDefinition
---@field luantiDef  table
local Item = {}

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

---@param itemDef Item.ItemDefinition
---@return Item
function Item:new(itemDef)
	---@type Item
	local instance = setmetatable({}, {__index = self})

	local luantiDef = itemDefToLuantiDef(itemDef)
	local visual = itemDef.settings.visual
	itemDef.settings.visual = nil

	if visual == '3d' then
		register3dItem(luantiDef)
	else
		visual = 'flat'
		registerFlatItem(luantiDef)
	end

	function instance:getVisual()
		return visual
	end

	instance.itemDef = itemDef
	instance.luantiDef = luantiDef
	return instance
end


return Item
