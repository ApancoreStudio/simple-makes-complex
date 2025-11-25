-- World generation runs in the mapgen environment (separate thread)
-- The Mapgen environment is isolated from the main enviroment.

core.register_mapgen_script(core.get_modpath(core.get_current_modname())..'/MapGenerator.lua')

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
	place_on = "soils:clay_soil_baren",
	sidelen = 8,
	fill_ratio = 0.1,
	decoration = "plants:plants",
})