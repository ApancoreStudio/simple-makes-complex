---@type  Node
local Node = Mod.getInfo('smc__core__node').require('Node')

---@type TileSheet
local TileSheet = Mod.getInfo('smc__core__tilesheet').require('TileSheet')

---@type Node.NodeDefinition
local defaultRockDef = {
	settings = {
		name = "",
		description = "A log",
		tiles = {},
		groups = {
			dig_immediate = 2,
		},
		paramtype2 = "facedir",
	},
}

---@type Node.NodeDefinition
local defaultPlanksDef = {
	settings = {
		name = "",
		description = "A planks",
		tiles = {},
		groups = {
			dig_immediate = 2,
		},
		paramtype2 = "facedir",
	},
}

local defaultLog = Node:getExtended(defaultRockDef)
local defaultPlanks = Node:getExtended(defaultPlanksDef)

local logFactory = defaultLog:getFactory()
local planksFactory = defaultPlanks:getFactory()

---@type TileSheet
local logTileSheet = TileSheet:new("wood_sheet.png", 16, 16)

local function getLogTiles(x, y)
	return {
		logTileSheet:t(x, y),
		logTileSheet:t(x, y),
		logTileSheet:t(x, y+1),
	}
end

local t = getLogTiles

logFactory:registerItems({
	---@type Node.NodeDefinition
	{
		settings = {
			name = "marentine_log",
			title = "Marentine Log",
			--description = "",
			tiles = t(0, 1),
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "allwhere_log",
			title = "Allwhere Log",
			--description = "",
			tiles = t(2, 1),
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "fis_log",
			title = "Fis Log",
			--description = "",
			tiles = t(4, 1),
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "tammoy_log",
			title = "Tammoy Log",
			--description = "",
			tiles = t(6, 1),
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "dallalia_log",
			title = "Dallalia Log",
			--description = "",
			tiles = t(8, 1),
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "zuph_log",
			title = "Zuph Log",
			--description = "",
			tiles = t(10, 1),
		},
	},
})

planksFactory:registerItems({
	---@type Node.NodeDefinition
	{
		settings = {
			name = "marentine_planks",
			title = "Marentine Planks",
			--description = "",
			tiles = { logTileSheet:t(0, 4) },
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "allwhere_planks",
			title = "Allwhere Planks",
			--description = "",
			tiles = { logTileSheet:t(2, 4) },
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "fis_planks",
			title = "Fis Planks",
			--description = "",
			tiles = { logTileSheet:t(4, 4) },
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "tammoy_planks",
			title = "Tammoy Planks",
			--description = "",
			tiles = { logTileSheet:t(6, 4) },
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "dallalia_planks",
			title = "Dallalia Planks",
			--description = "",
			tiles = { logTileSheet:t(8, 4) },
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "zuph_planks",
			title = "Zuph Planks",
			--description = "",
			tiles = { logTileSheet:t(10, 4) },
		},
	},
})

-- сундучки

---@type TileSheet
local caseTileSheet = TileSheet:new("cases_sheet.png", 16, 16)

local function getCaseTiles(x, y)
	return {
		caseTileSheet:t(x, y),
		caseTileSheet:t(x, y),
		caseTileSheet:t(x, y+1),
	}
end

local t = getCaseTiles

planksFactory:registerItems({
	---@type Node.NodeDefinition
	{
		settings = {
			name = "case_closed",
			title = "Case",
			--description = "",
			tiles = t(0,0)
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "case_open",
			title = "Case",
			--description = "",
			tiles = t(1,0);
			drawtype = 'nodebox';
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, -0.5, 0.5, 0.5 - 1/16*2, 0.5},
				}
			}
		},
	},
})