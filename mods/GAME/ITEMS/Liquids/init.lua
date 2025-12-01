---@type  Node
local Node = Mod.getInfo('smc__core__node').require('Node')

---@type Node.NodeDefinition
local defaultLiquidDef = {
	settings = {
		name = '',
		tiles = {},
		waving = 3,
		use_texture_alpha = "blend",
		paramtype = "light",
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		is_ground_content = false,
		drop = "",
		drowning = 1,
		liquid_viscosity = 1,
		groups = {water = 3, liquid = 3,}
	}
}

---@type Node
local defaultLiquid = Node:getExtended(defaultLiquidDef)

local liquidFactory = defaultLiquid:getFactory()

liquidFactory:registerItems({
	---@type Node.NodeDefinition
	{
		settings = {
			name = "liquids:water_source",
			drawtype = "liquid",
			tiles = {
				{
					name = "liquids_water_source.png",
					backface_culling = false,
					animation = {
						type = "vertical_frames",
						aspect_w = 16,
						aspect_h = 16,
						length = 2.0,
					},
				},
				{
					name = "liquids_water_source.png",
					backface_culling = true,
					animation = {
						type = "vertical_frames",
						aspect_w = 16,
						aspect_h = 16,
						length = 2.0,
					},
				},
			},
			liquidtype = "source",
			liquid_alternative_flowing = "liquids:water_flowing",
			liquid_alternative_source = "liquids:water_source",
		}
	},

	---@type Node.NodeDefinition
	{
		settings = {
			name = "liquids:water_flowing",
			drawtype = "flowingliquid",
			tiles = {"default_water.png"},
			special_tiles = {
				{
					name = "default_water_flowing_animated.png",
					backface_culling = false,
					animation = {
						type = "vertical_frames",
						aspect_w = 16,
						aspect_h = 16,
						length = 0.5,
					},
				},
				{
					name = "default_water_flowing_animated.png",
					backface_culling = true,
					animation = {
						type = "vertical_frames",
						aspect_w = 16,
						aspect_h = 16,
						length = 0.5,
					},
				},
			},
			liquidtype = "flowing",
			liquid_alternative_flowing = "liquids:water_flowing",
			liquid_alternative_source = "liquids:water_source",
			paramtype2 = "flowingliquid",
		}
	}
}, false)