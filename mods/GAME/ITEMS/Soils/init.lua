---@type Node.NodeDefinition
local defaultSoilDef = {
	settings = {
		name = "",
		description = "A soil",
		tiles = {},
		groups = {
			dig_immediate = 2,
			soil_fertiliry = 100, -- Soil fertility for agriculture
		}
	},
}

---@type Node
local defaultSoil = Core.Node.Class:getExtended(defaultSoilDef)

local soilFactory = defaultSoil:getFactory()

---@type TileSheet
local ts = Core.TileSheet:getModClassInstance("soils_sheet.png", 7, 1)

local clayTiles = {
	ts:t(0,0)
}

local sandyTiles = {
	ts:t(2,0)
}

local mixedTiles = {
	ts:t(4,0)
}

local rockyTiles = {
	ts:t(6,0)
}

soilFactory:registerItems({
	--- Clay soils
	---@type Node.NodeDefinition
	{
		settings = {
			name = "clay_soil_baren",
			title = "Barren Clay Soil",
			--description = "",
			tiles = clayTiles,
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "clay_soil_poor",
			title = "Poor Clay Soil",
			--description = "",
			tiles = clayTiles,
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "clay_soil_moderate",
			title = "Moderate Clay Soil",
			--description = "",
			tiles = clayTiles,
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "clay_soil_fertile",
			title = "Fertile Clay Soil",
			--description = "",
			tiles = clayTiles,
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "clay_soil_rich",
			title = "Rich Clay Soil",
			--description = "",
			tiles = clayTiles,
		},
	},



	--- Sandy soils
	---@type Node.NodeDefinition
	{
		settings = {
			name = "sandy_soil_baren",
			title = "Barren Sandy Soil",
			--description = "",
			tiles = sandyTiles,
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "sandy_soil_poor",
			title = "Poor Sandy Soil",
			--description = "",
			tiles = sandyTiles,
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "sandy_soil_moderate",
			title = "Moderate Sandy Soil",
			--description = "",
			tiles = sandyTiles,
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "sandy_soil_fertile",
			title = "Fertile Sandy Soil",
			--description = "",
			tiles = sandyTiles,
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "sandy_soil_rich",
			title = "Rich Sandy Soil",
			--description = "",
			tiles = sandyTiles,
		},
	},



	--- Mixed soils
	---@type Node.NodeDefinition
	{
		settings = {
			name = "mixed_soil_baren",
			title = "Barren Mixed Soil",
			--description = "",
			tiles = mixedTiles,
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "mixed_soil_poor",
			title = "Poor Mixed Soil",
			--description = "",
			tiles = mixedTiles,
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "mixed_soil_moderate",
			title = "Moderate Mixed Soil",
			--description = "",
			tiles = mixedTiles,
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "mixed_soil_fertile",
			title = "Fertile Mixed Soil",
			--description = "",
			tiles = mixedTiles,
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "mixed_soil_rich",
			title = "Rich Mixed Soil",
			--description = "",
			tiles = mixedTiles,
		},
	},



	--- Rocky soils
		---@type Node.NodeDefinition
	{
		settings = {
			name = "rocky_soil_baren",
			title = "Barren Rocky Soil",
			--description = "",
			tiles = rockyTiles,
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "rocky_soil_poor",
			title = "Poor Rocky Soil",
			--description = "",
			tiles = rockyTiles,
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "rocky_soil_moderate",
			title = "Moderate Rocky Soil",
			--description = "",
			tiles = rockyTiles,
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "rocky_soil_fertile",
			title = "Fertile Rocky Soil",
			--description = "",
			tiles = rockyTiles,
		},
	},
	---@type Node.NodeDefinition
	{
		settings = {
			name = "rocky_soil_rich",
			title = "Rich Rocky Soil",
			--description = "",
			tiles = rockyTiles,
		},
	},

}, true)