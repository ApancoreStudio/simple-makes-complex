local modInfo = Mod.getInfo('smc__core__plant')

---@type TileSheet
local TileSheet = Mod.getInfo('smc__core__tilesheet').require('TileSheet')

---@type  Plant
local Plant = modInfo.require('Plant')

Plant:new({
	settings = {
		name = 'plants',
		tiles = { "test_plant.png" },
		place_param2 = 3,
	},
})

local ts = TileSheet:new('plants_test_sheet.png', 16, 16)


for i=0, 3 do
	Plant:new({
		settings = {
			name = 'plant'..tostring(i),
			title = 'Plant',
			tiles = { ts:t(i,0) },
			place_param2 = 3,
		},
	})
end
