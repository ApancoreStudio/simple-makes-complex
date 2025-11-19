---@type Item.Settings
local ItemSettings = Core.Item.require('Item.Settings')

---@class Node.Settings : Item.Settings
local Settings = Mod:getClassExtended(ItemSettings, {})

---See "Node drawtypes"
---@type string?
Settings.drawtype = nil

---Supported for drawtypes "plantlike", "signlike", "torchlike",
---"firelike", "mesh", "nodebox", "allfaces".
---For plantlike and firelike, the image will start at the bottom of the
---node. For torchlike, the image will start at the surface to which the
---node "attaches". For the other drawtypes the image will be centered
---on the node.
---@type number?
Settings.visual_scale = nil



---Textures of node: +Y, -Y, +X, -X, +Z, -Z.
---
---List can be shortened to needed length.
---@type (string[]|TileDefinition[])?
Settings.tiles = {}

---Same as `tiles`, but these textures are drawn on top of the base
---tiles. You can use this to colorize only specific parts of your
---texture. If the texture name is an empty string, that overlay is not
---drawn. Since such tiles are drawn twice, it is not recommended to use
---overlays on very common nodes.
---@type (string[]|TileDefinition[])?
Settings.overlay_tiles = nil

---Special textures of node; used rarely.
---
---List can be shortened to needed length.
---@type (string[]|TileDefinition[])?
Settings.special_tiles = nil



---The node's original color will be multiplied with this color.
---If the node has a palette, then this setting only has an effect in
---the inventory and on the wield item.
---@type (string|ColorSpec)?
Settings.color = nil

---Specifies how the texture's alpha channel will be used for rendering.
---Possible values:
---* `"opaque"`:
---  Node is rendered opaque regardless of alpha channel.
---* `"clip"`:
---  A given pixel is either fully see-through or opaque
---  depending on the alpha channel being below/above 50% in value.
---  Use this for nodes with fully transparent and fully opaque areas.
---* `"blend"`:
---  The alpha channel specifies how transparent a given pixel
---  of the rendered node is. This comes at a performance cost.
---  Only use this when correct rendering
---  among semitransparent nodes is necessary.
---
---The default is `"opaque"` for drawtypes normal, liquid and flowingliquid,
---mesh and nodebox or "clip" otherwise.
---If set to a boolean value (deprecated): true either sets it to blend
---or clip, false sets it to clip or opaque mode depending on the drawtype.
---@type string?
Settings.use_texture_alpha = nil

---The node's `param2` is used to select a pixel from the image.
---Pixels are arranged from left to right and from top to bottom.
---The node's color will be multiplied with the selected pixel's color.
---Tiles can override this behavior.
---
---Only when `paramtype2` supports palettes.
---@type string?
Settings.palette = nil



---Screen tint if a player is inside this node, see `ColorSpec`.
---Color is alpha-blended over the screen.
---@type string?
Settings.post_effect_color = nil

---Determines whether `post_effect_color` is affected by lighting.
---@type boolean?
Settings.post_effect_color_shaded = nil



---See "Nodes"
---@type string?
Settings.paramtype = nil

---See "Nodes"
---@type string?
Settings.paramtype2 = nil



---Value for param2 that is set when player places node.
---@type number?
Settings.place_param2 = nil

---If true, place_param2 is nil, and this is a wallmounted node,
---this node might use the special 90° rotation when placed
---on the floor or ceiling, depending on the direction.
---See the explanation about wallmounted for details.
---Otherwise, the rotation is always the same on vertical placement.
---@type boolean?
Settings.wallmounted_rotate_vertical = nil

---If false, the cave generator and dungeon generator will not carve
---through this node.
---Specifically, this stops mod-added nodes being removed by caves and
---dungeons when those generate in a neighbor mapchunk and extend out
---beyond the edge of that mapchunk.
---@type boolean?
Settings.is_ground_content = nil

---If true, sunlight will go infinitely through this node.
---@type boolean?
Settings.sunlight_propagates = nil

---If true, objects collide with node.
---@type boolean?
Settings.walkable = nil

---Can be `true` if it is pointable, `false` if it can be pointed through,
---or `"blocking"` if it is pointable but not selectable.
---Clients older than 5.9.0 interpret `pointable = "blocking"` as `pointable = true`.
---Can be overridden by the `pointabilities` of the held item.
---A client may be able to point non-pointable nodes, since it isn't checked server-side.
---@type boolean?
Settings.pointable = nil

---If false, can never be dug.
---@type boolean?
Settings.diggable = nil

---If true, can be climbed on like a ladder.
---@type boolean?
Settings.climbable = nil

---Slows down movement of players through this node (max. 7).
---If this is nil, it will be equal to liquid_viscosity.
---Note: If liquid movement physics apply to the node
---(see `liquid_move_physics`), the movement speed will also be
---affected by the `movement_liquid_*` settings.
---@type number?
Settings.move_resistance = nil

---If true, placed nodes can replace this node.
---@type boolean?
Settings.buildable_to = nil

---If true, liquids flow into and replace this node.
---
---Warning: making a liquid node 'floodable' will cause problems.
---@type boolean?
Settings.floodable = nil

---specifies liquid flowing physics
---* `"none"`:    no liquid flowing physics
---* `"source"`:  spawns flowing liquid nodes at all 4 sides and below;
---             recommended drawtype: "liquid".
---* `"flowing"`: spawned from source, spawns more flowing liquid nodes
---             around it until `liquid_range` is reached;
---             will drain out without a source;
---             recommended drawtype: "flowingliquid".
---
---If it's "source" or "flowing", then the
---`liquid_alternative_*` fields _must_ be specified
---@type string?
Settings.liquidtype = nil

---These fields may contain node names that represent the
---flowing version (`liquid_alternative_flowing`) and
---source version (`liquid_alternative_source`) of a liquid.
---
---Specifically, these fields are required if `liquidtype ~= "none"` or
---`drawtype == "flowingliquid"`.
---
---Liquids consist of up to two nodes: source and flowing.
---
---There are two ways to define a liquid:
---1) Source node and flowing node. This requires both fields to be
---   specified for both nodes.
---2) Standalone source node (cannot flow). `liquid_alternative_source`
---   must be specified and `liquid_range` must be set to 0.
---
---Example:
---
---    liquid_alternative_flowing = `"example:water_flowing"`,
---    liquid_alternative_source = `"example:water_source"`,
---@type string?
Settings.liquid_alternative_flowing = nil

---See `Node.Settings.liquid_alternative_flowing`.
---@type string?
Settings.liquid_alternative_source = nil

---Controls speed at which the liquid spreads/flows (max. 7).
---0 is fastest, 7 is slowest.
---By default, this also slows down movement of players inside the node
---(can be overridden using `move_resistance`)
---@type number?
Settings.liquid_viscosity = nil

---If true, a new liquid source can be created by placing two or more
---sources nearby.
---@type boolean?
Settings.liquid_renewable = nil

---specifies movement physics if inside node
---* `false`: No liquid movement physics apply.
---* `true`: Enables liquid movement physics. Enables things like
---  ability to "swim" up/down, sinking slowly if not moving,
---  smoother speed change when falling into, etc. The `movement_liquid_*`
---  settings apply.
---* `nil`: Will be treated as true if `liquidtype ~= "none"`
---  and as false otherwise.
---@type boolean?
Settings.liquid_move_physics = nil

---Unclear meaning, the engine sets this to true for 'air' and 'ignore'
---deprecated.
---@type string?
Settings.air_equivalent = nil

---Only valid for "nodebox" drawtype with 'type = "leveled"'.
---Allows defining the nodebox height without using param2.
---The nodebox height is 'leveled' / 64 nodes.
---The maximum value of 'leveled' is `leveled_max`.
---@type number?
Settings.leveled = nil

---Maximum value for `leveled` (0-127), enforced in
---`core.set_node_level` and `core.add_node_level`.
---Values above 124 might causes collision detection issues.
---@type number?
Settings.leveled_max = nil

---Maximum distance that flowing liquid nodes can spread around
---source on flat land;
---maximum = 8; set to 0 to disable liquid flow.
---@type number?
Settings.liquid_range = nil

---Player will take this amount of damage if no bubbles are left.
---@type number?
Settings.drowning = nil

---If player is inside node, this damage is caused.
---@type number?
Settings.damage_per_second = nil



---See "Node boxes"
---@type table?
Settings.node_box = nil

---Used for nodebox nodes with the type == "connected".
---Specifies to what neighboring nodes connections will be drawn.
---e.g. `{"group:fence", "default:wood"}` or `"default:stone"`
---@type table?
Settings.connects_to = nil

---Tells connected nodebox nodes to connect only to these sides of this
---node. possible: "top", "bottom", "front", "left", "back", "right"
---@type table?
Settings.connect_sides = nil

---File name of mesh when using "mesh" drawtype
---The center of the node is the model origin.
---For legacy reasons, this uses a different scale depending on the mesh:
---1. For glTF models: 10 units = 1 node (consistent with the scale for entities).
---2. For obj models: 1 unit = 1 node.
---3. For b3d and x models: 1 unit = 1 node if static, otherwise 10 units = 1 node.
---
---Using static glTF or obj models is recommended.
---
---You can use the `visual_scale` multiplier to achieve the expected scale.
---@type string?
Settings.mesh = nil

---Custom selection box definition. Multiple boxes can be defined.
---If "nodebox" drawtype is used and selection_box is nil, then node_box
---definition is used for the selection box
---@type table?
Settings.selection_box = nil

---Custom collision box definition. Multiple boxes can be defined.
---If "nodebox" drawtype is used and collision_box is nil, then node_box
---definition is used for the collision box.
---@type table?
Settings.collision_box = nil



---Support maps made in and before January 2012
---@type boolean?
Settings.legacy_facedir_simple = nil

---Support maps made in and before January 2012
---@type boolean?
Settings.legacy_wallmounted = nil



---Valid for drawtypes:
---mesh, nodebox, plantlike, allfaces_optional, liquid, flowingliquid.
---* 1 - wave node like plants (node top moves side-to-side, bottom is fixed)
---* 2 - wave node like leaves (whole node moves side-to-side)
---* 3 - wave node like liquids (whole node moves up and down)
---
---Not all models will properly wave.
---plantlike drawtype can only wave like plants.
---allfaces_optional drawtype can only wave like leaves.
---liquid, flowingliquid drawtypes can only wave like liquids.
---@type number?
Settings.waving = nil

---Definition of node sounds to be played at various events.
---All fields in this table are optional.
---
---@type nil|table<string,SimpleSoundSpec|string?>
Settings.sounds = nil

---Name of dropped item when dug.
---Default dropped item is the node itself.
---
---Using a table allows multiple items, drop chances and item filtering
---@type (table|string)?
Settings.drop = nil

return Settings