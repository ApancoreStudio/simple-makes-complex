---@type Item.Callbacks
local ItemCallbacks = Core.Item.require('Item.Callbacks')

---@class Node.Callbacks : Item.Callbacks
local Callbacks = Mod:getClassExtended(ItemCallbacks, {})

---Node constructor; called after adding node.
---Can set up metadata and stuff like that.
---Not called for bulk node placement (i.e. schematics and VoxelManip).
---Note: Within an `on_construct` callback, `core.set_node` can cause an
---infinite loop if it invokes the same callback.
---Consider using `core.swap_node` instead.
---
---default: nil
---* `pos`: node position
---@type fun(pos:Position)?
Callbacks.on_construct = nil

---Node destructor; called before removing node.
---Not called for bulk node placement.
---
---default: nil
---* `pos`: node position
---@type fun(pos:Position)?
Callbacks.on_destruct = nil

---Node destructor; called after removing node.
---Not called for bulk node placement.
---
---default: nil
---* `pos`: node position
---* `oldnode`: node table of node before it was deleted
---@type fun(pos:Position, old_node)?
Callbacks.after_destruct = nil

---Called when a liquid (newnode) is about to flood oldnode, if it has
---`floodable = true` in the nodedef. Not called for bulk node placement
---(i.e. schematics and VoxelManip) or air nodes. If return true the
---node is not flooded, but on_flood callback will most likely be called
---over and over again every liquid update interval.
---
---Default: nil
---
---Warning: making a liquid node 'floodable' will cause problems.
---* `pos`: table  node position
---* `oldnode`: table  node table of node before it was deleted
---* `newnode`: TODO: какой тут тип?
---@type fun(pos:Position, old_node, new_node)?
Callbacks.on_flood = nil


---Called when `oldnode` is about be converted to an item, but before the
---node is deleted from the world or the drops are added. This is
---generally the result of either the node being dug or an attached node
---becoming detached.
---
---default: `nil`
---* `pos`: node position
---* `oldnode`: node table of node before it was deleted
---* `oldmeta`: metadata of node before it was deleted, as a metadata table
---* `drops`: a table of `ItemStack`s, so any metadata to be preserved can
---                       be added directly to one or more of the dropped items. See
---                       "ItemStackMetaRef".
---@type fun(pos:Position, old_node, new_node, old_meta, drops:ItemStack[])?
Callbacks.preserve_metadata = nil

---Called after constructing node when node was placed using
---core.item_place_node / core.place_node.
---If return true no item is taken from itemstack.
---
---default: nil
---* `pos`: node position
---* `placer`: may be any valid ObjectRef or nil
---* `itemstack`: TODO: сделать описание
---* `pointed_thing`: Vector of the direction of the gaze of the person who placed the block
---@type fun(pos:Position, placer:Player|ObjectRef|nil, itemstack:ItemStack, pointed_thing:pointed_thing)?
Callbacks.after_place_node = nil

---Called after destructing the node when node was dug using
---`core.node_dig` / `core.dig_node`.
---
---default: nil
---* `pos`: node position
---* `oldnode`: node table of node before it was dug
---* `oldmetadata`: metadata of node before it was dug, as a metadata table
---* `digger`: ObjectRef of digger
---@type fun(pos:Player, oldnode, oldmetadata, digger:Player|ObjectRef|nil)?
Callbacks.after_dig_node = nil

---Returns true if node can be dug, or false if not.
---
---default: nil
---* `pos`: node position
---* player: ObjectRef of digger
---@type fun(pos:Position, player:Player|ObjectRef|nil)?
Callbacks.can_dig = nil

---Called when puncher (an ObjectRef) punches the node at pos.
---By default calls core.register_on_punchnode callbacks.
---
---default: core.node_punch
---* `pos`: node position
---* `node`: node being hit
---* `puncher`: ObjectRef of punch
---* `pointed_thing`: Vector of the direction of the gaze of the person who placed the block
---@type fun(pos:Position, node:NodeTable, puncher:Player|ObjectRef|nil, pointed_thing:pointed_thing)?
Callbacks.on_punch = nil

---Called when clicker (an ObjectRef) used the 'place/build' key
---(not necessarily an actual rightclick)
---while pointing at the node at pos with 'node' being the node table.
---itemstack will hold clicker's wielded item.
---Shall return the leftover itemstack.
---
---Note: pointed_thing can be nil, if a mod calls this function.
---
---default: nil
---@type (fun(pos:Position, node:NodeTable, clicker:Player|ObjectRef, itemstack:ItemStack, pointed_thing:pointed_thing|nil):ItemStack|nil)?
Callbacks.on_rightclick = core.node_punch


---By default checks privileges, wears out item (if tool) and removes node.
---return true if the node was dug successfully, false otherwise.
---Deprecated: returning nil is the same as returning true.
---
---default: core.node_dig
---@type (fun(pos:Position, node:NodeTable, digger:Player): boolean)?
Callbacks.on_dig = minetest.node_dig

---called by NodeTimers, see core.get_node_timer and NodeTimerRef.
---* `elapsed`: total time passed since the timer was started.
---* `node`: node table (since 5.14)
---* `timeout`: timeout value of the just ended timer (since 5.14)
---return true to run the timer for another cycle with the same timeout value.
---
---default: nil
---@type (fun(pos:Position, elapsed:number): boolean)?
Callbacks.on_timer = nil

---fields = {name1 = value1, name2 = value2, ...}
---
---formname should be the empty string; you **must not** use formname.
---Called when an UI form (e.g. sign text input) returns data.
---See `core.register_on_player_receive_fields` for more info.
---
---default: nil
---@type fun(pos:Position, formname:string, fields:table, sender:Player)?
Callbacks.on_receive_fields = nil

---Called when a player wants to put something into the inventory.
---
---Return value: number of items allowed to put.
---
---Return value -1: Allow and don't modify item count in inventory.
---@type (fun(pos:Position, from_list:string, from_index:number, to_list:string, to_index:number, count:number, player:Player): number)?
Callbacks.allow_metadata_inventory_move = nil

---Called when a player wants to take something out of the inventory.
---
---Return value: number of items allowed to take.
---
---Return value -1: Allow and don't modify item count in inventory.
---@type (fun(pos:Position, listname:string, index:number, stack:ItemStack, player:Player): number)?
Callbacks.allow_metadata_inventory_take = nil

---Called after the actual action has happened, according to what was allowed.
---
---No return value.
---@type (fun(pos:Position, from_list:string, from_index:number, to_list:string, to_index:number, count:number, player:Player): void)?
Callbacks.on_metadata_inventory_move = nil

---Called after the actual action has happened, according to what was allowed.
---
---No return value.
---@type (fun(pos:Position, listname:string, index:number, stack:ItemStack, player:Player): void)?
Callbacks.on_metadata_inventory_put = nil

---Called after the actual action has happened, according to what was allowed.
---
---No return value.
---@type (fun(pos:Position, listname:string, index:number, stack:ItemStack, player:Player): void)?
Callbacks.on_metadata_inventory_take = nil

---If defined, called when an explosion touches the node, instead of
---removing the node.
---* `intensity`: 1.0 = mid range of regular TNT.
---@type (fun(pos:Position, intensity:number): void)?
Callbacks.on_blast = nil

return Callbacks