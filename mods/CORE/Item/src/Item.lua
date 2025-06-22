local Item = {}

--- @class ItemDefinition
--- @field settings table
local ItemDefinition = {
	settings = {
		name = '',
		title = '',
		description = '',
		visual = '', -- '3d' | 'flat'
	},
	callbacks = {
		...
	},
}

--- @param itemDef  ItemDefinition
local function itemDefToLuantiDef(itemDef)
	local s = itemDef.settings
	local c = itemDef.callbacks
	local luantiDef = table.copy(c)

	return luantiDef
end

local function register3dItem(luantiDef)
	local ld = luantiDef
	core.register_node(ld.name, {
		description = ld.description
	})
end

local function registerFlatItem(luantiDef)

end

function Item:new(itemDef)
	local item = {}

	
end
