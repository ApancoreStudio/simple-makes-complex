---@type TileSheet
local TileSheet = Mod.getInfo('smc__core__tilesheet').require('TileSheet')

---@type  Node
local Node = Mod.getInfo('smc__core__node').require('Node')

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
local defaultRock = Node:getExtended(defaultRockDef)

local rockFactory = defaultRock:getFactory()

---@type TileSheet
local ts = TileSheet:new("rocks_sheet.png", 16, 16)

rockFactory:registerNodesByShortDef({
	{"sylite",    {ts:t(0, 0)}},
	{"tauitite",  {ts:t(0, 2)}},
	{"iyellite",  {ts:t(0, 4)}},
	{"falmyte",   {ts:t(0, 6)}},
	{"hapcoryte", {ts:t(0, 8)}},
	{"burcite",   {ts:t(0, 10)}},
	{"felhor",    {ts:t(0, 12)}},
	{"malachite", {ts:t(0, 14)}}
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