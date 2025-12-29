local nodeRequire = Mod.getInfo('smc__core__node').require

---@type Node
local Node = nodeRequire('Node')

-- -@type ItemFactory
---local ItemFactory = Mod.getInfo('smc__core__item_factory').require('ItemFactory')

---@class Plant : Node
local Plant = Node:getExtended({
	settings = {
		name = 'smc__core__plant:abstract_plant',
		drawtype = "plantlike",
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = "meshoptions",
		walkable = false,
		buildable_to = true,
		groups = {dig_immediate = 3},
		selection_box = {
			type = "fixed",
			fixed = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
		},
	}
})

return Plant