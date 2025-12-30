local modInfo = Mod.getInfo('smc__core__plant')

---@type  Plant
local Plant = modInfo.require('Plant')

Plant:new({
	settings = {
		name = 'plants:plants',
		description = 'Plant',
		tiles = { "test_plant.png" },
		place_param2 = 3,
	},
})