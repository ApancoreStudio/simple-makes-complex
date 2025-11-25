core.register_node(":plants:plants", {
	description = 'Plant',
	drawtype = "plantlike",
	tiles = { "test_plant.png" },
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	waving = 1,
	walkable = false,
	buildable_to = true,
	groups = {dig_immediate = 2},
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
	on_construct = function(pos)
		local node = core.get_node(pos)

		node.param2 = 3
	end,
})

