-- World generation occurs in a separate thread (MapGen Environment).
-- But for the main thread, the mapgenerator object is also initialized.

local mapGeneneratorRequire = Mod.getInfo('smc__core__map_generator').require

-- Main env init
local mapGenerator = mapGeneneratorRequire('mapGenerator')

-- Async env init
core.register_mapgen_script(core.get_modpath('smc__core__map_generator')..'/src/asyncInit.lua')


-- --- Register vanilla ores & decorations ---
-- For now, the generation does not have its own support
-- for the generation of ores and decorations, so vanilla ones are used.

core.register_ore({
	ore_type       = "scatter",
	ore            = "soils:rocky_soil_baren",
	wherein        = "rocks:sylite",
	clust_scarcity = 8*8*8,
	clust_num_ores = 8,
	clust_size     = 3,
	y_min     = -31000,
	y_max     = 64,
})

core.register_decoration({
	deco_type = "simple",
	place_on = "soils:turf_swamp",
	sidelen = 8,
	fill_ratio = 0.4,
	decoration = "plants:plants",
})

core.register_decoration({
	deco_type = "simple",
	place_on = "soils:turf_swamp",
	sidelen = 8,
	fill_ratio = 0.05,
	decoration = "plants:plant0",
})

core.register_decoration({
	deco_type = "simple",
	place_on = "soils:turf_swamp",
	sidelen = 8,
	fill_ratio = 0.01,
	decoration = "plants:plant2",
})

return mapGenerator