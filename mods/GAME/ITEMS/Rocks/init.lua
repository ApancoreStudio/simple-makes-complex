---@type Node.NodeDefinition
local defaultRockDef = {
	settings = {
		name = "",
		description = "A rocks",
		tiles = {},
		groups = {
			dig_immediate = 2,
		}
	},
}

---@type Node
local defaultRock = Core.Node.Class:getExtended(defaultRockDef)

local rockFactory = defaultRock:getFactory()

---@type TileSheet
local ts = Core.TileSheet:getModClassInstance("rocks_sheet.png", 7, 15)

rockFactory:registerNodesByShortDef({
	{"sylite",    "Sylite",    nil, {ts:t(0, 0)}},
	{"tauitite",  "Tauitite",  nil, {ts:t(0, 2)}},
	{"iyellite",  "Iyellite",  nil, {ts:t(0, 4)}},
	{"falmyte",   "Falmyte",   nil, {ts:t(0, 6)}},
	{"hapcoryte", "Hapcoryte", nil, {ts:t(0, 8)}},
	{"burcite",   "Burcite",   nil, {ts:t(0, 10)}},
	{"felhor",    "Felhor",    nil, {ts:t(0, 12)}},
	{"malachite", "malachite", nil, {ts:t(0, 14)}}
})

--[[
rockFactory:registerItems({
	---@type Node.NodeDefinition
	{
		settings = {
			name = "sylite",
			title = "Sylite",
			--description = "",
			tiles = {"rocks_sheet.png^[sheet:7x15:0,0"},
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "tauitite",
			title = "Tauitite",
			--description = "",
			tiles = {"rocks_sheet.png^[sheet:7x15:0,2"},
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "iyellite",
			title = "Iyellite",
			--description = "",
			tiles = {"rocks_sheet.png^[sheet:7x15:0,4"},
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "falmyte",
			title = "Falmyte",
			--description = "",
			tiles = {"rocks_sheet.png^[sheet:7x15:0,6"},
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "hapcoryte",
			title = "Hapcoryte",
			--description = "",
			tiles = {"rocks_sheet.png^[sheet:7x15:0,8"},
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "burcite",
			title = "Burcite",
			--description = "",
			tiles = {"rocks_sheet.png^[sheet:7x15:0,10"},
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "felhor",
			title = "Felhor",
			--description = "",
			tiles = {"rocks_sheet.png^[sheet:7x15:0,12"},
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "malachite",
			title = "Malachite",
			--description = "",
			tiles = {"rocks_sheet.png^[sheet:7x15:0,14"},
		},
	},
})

--]]