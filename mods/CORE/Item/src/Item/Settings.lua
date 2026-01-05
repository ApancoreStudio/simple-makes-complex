---@class Item.Settings
local Settings = {}

---Technical name of the item. Must be unique and have the format `mod_name:item_name`
---@type string
Settings.name = ''

---Whether to add the mod name to the settings.name. Default: `true`
---@type boolean?
Settings.addModName = nil

---Item description. 1st line of item description.
---@type string?
Settings.title = nil

---Item description. The rest of item description.
---@type string?
Settings.description = nil

---Item title color in description.
---
---Default: `#FFFFFF`
---@type ColorString?
Settings.titleColor = nil

---Item description color in description.
---
---Default: `#C0C0C0`
---@type ColorString?
Settings.descriptionColor = nil

---@alias Item.Visual
---'item_2d'|
---'item_3d'

---Visual node type.
---@type Item.Visual?
Settings.visual = nil



---Table of groups-characteristics of Item.
---`key` = name, `value` = rating; `rating` = number.
---
---If rating not applicable, use 1.
---@type table<string,number>?
Settings.groups = nil



---Texture shown in the inventory GUI.
---Defaults to a 3D rendering of the node if left empty.
---@type string?
Settings.inventory_image = nil

---An overlay texture which is not affected by colorization.
---@type string?
Settings.inventory_overlay = nil



---Texture shown when item is held in hand.
---Defaults to a 3D rendering of the node if left empty.
---@type string?
Settings.wield_image = nil

---Like `inventory_overlay` but only used in the same situation as `wield_image`.
---@type string?
Settings.wield_overlay = nil

---Scale for the item when held in hand.
---@type Position?
Settings.wield_scale = nil



---An image file containing the palette of a node.
---You can set the currently used color as the "palette_index" field of
---the item stack metadata.
---The palette is always stretched to fit indices between 0 and 255, to
---ensure compatibility with "colorfacedir" (and similar) nodes.
---@type string?
Settings.palette = nil

---Color the item is colorized with. The palette overrides this.
---It is a colorspec.
---@type string|ColorSpec|nil
Settings.color = nil

---Maximum amount of items that can be in a single stack.
---The default can be changed by the setting `default_stack_max`.
---@type number?
Settings.stack_max = nil

---Range of node and object pointing that is possible with this item held.
---Can be overridden with itemstack meta.
---@type number?
Settings.range = nil

---If true, item can point to all liquid nodes (`liquidtype ~= "none"`),
---even those for which `pointable = false`.
---@type boolean?
Settings.liquids_pointable = nil

---Contains lists to override the `pointable` property of nodes and objects.
---The index can be a node/entity name or a group with the prefix `"group:"`.
---For objects `armor_groups` are used and for players the entity name is irrelevant.)
---If multiple fields fit, the following priority order is applied:
---1. value of matching node/entity name
---2. `true` for any group
---3. `false` for any group
---4. `"blocking"` for any group
---5. `liquids_pointable` if it is a liquid node
---6. `pointable` property of the node or object
---@type table?
Settings.pointabilities = nil

---When used for nodes: Defines amount of light emitted by node.
---Otherwise: Defines texture glow when viewed as a dropped item.
---To set the maximum (14), use the value `core.LIGHT_MAX`.
---A value outside the range 0 to `core.LIGHT_MAX` causes undefined
---behavior.
---@type number?
Settings.light_source = nil



---See "Tool Capabilities" section for an example including explanation.
---TODO: сделать или подтянуть из какого-нибудь helpers тип этой таблицы
---@type table?
Settings.tool_capabilities = nil

---Set wear bar color of the tool by setting color stops and blend mode.
---See "Wear Bar Color" section for further explanation including an example.
---TODO: сделать или подтянуть из какого-нибудь helpers тип этой таблицы
---@type table?
Settings.wear_color = nil

---If nil and item is node, prediction is made automatically.
---If nil and item is not a node, no prediction is made.
---If "" and item is anything, no prediction is made.
---Otherwise should be name of node which the client immediately places
---on ground when the player places the item. Server will always update
---with actual result shortly.
---@type string?
Settings.node_placement_prediction = nil

---if "", no prediction is made.
---if "air", node is removed.
---Otherwise should be name of node which the client immediately places
---upon digging. Server will always update with actual result shortly.
---`default: "air"`
---@type string?
Settings.node_dig_prediction = nil

---Only affects touchscreen clients.
---Defines the meaning of short and long taps with the item in hand.
---If specified as a table, the field to be used is selected according to
---the current `pointed_thing`.
---There are three possible TouchInteractionMode values:
---* "long_dig_short_place" (long tap  = dig, short tap = place)
---* "short_dig_long_place" (short tap = dig, long tap  = place)
---* "user":
---* * For `pointed_object`: Equivalent to "short_dig_long_place" if the
---    client-side setting "touch_punch_gesture" is "short_tap" (the
---    default value) and the item is able to punch (i.e. has no on_use
---    callback defined).
---    Equivalent to "long_dig_short_place" otherwise.
---* * For `pointed_node` and `pointed_nothing`:
---    Equivalent to "long_dig_short_place".
---* * The behavior of "user" may change in the future.
---The default value is "user".
---
---@type table<string,SimpleSoundSpec>?
Settings.touch_interaction = nil



---Definition of item sounds to be played at various events.
---All fields in this table are optional.
---
---@type table<string,SimpleSoundSpec>?
Settings.sound = nil


return Settings