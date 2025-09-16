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
---@type nil | fun(pos : table)
Callbacks.on_construct = function(pos)

end

---Node destructor; called before removing node.
---Not called for bulk node placement.
---
---default: nil
---* `pos`: node position
---@type nil | fun(pos : table)
Callbacks.on_destruct = function(pos)

end

---Node destructor; called after removing node.
---Not called for bulk node placement.
---
---default: nil
---* `pos`: node position
---* `oldnode`: node table of node before it was deleted
---@type nil | fun(pos : table, oldnode : table)
Callbacks.after_destruct = function(pos, oldnode)

end

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
---@type nil | fun(pos : table, oldnode : table, newnode : any)
Callbacks.on_flood = function(pos, oldnode, newnode)

end


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
---@type nil | fun(pos : table, oldnode : table, oldmeta : table, drops : any?)
Callbacks.preserve_metadata = function(pos, oldnode, oldmeta, drops)

end

---Called after constructing node when node was placed using
---core.item_place_node / core.place_node.
---If return true no item is taken from itemstack.
---
---default: nil
---* `pos`: node position
---* `placer`: may be any valid ObjectRef or nil
---* `itemstack`: TODO: сделать описание
---* `pointed_thing`: Vector of the direction of the gaze of the person who placed the block
---@type nil | fun(pos : table, placer : table, itemstack : table, pointed_thing : table):boolean
Callbacks.after_place_node = function(pos, placer, itemstack, pointed_thing)

end

---Called after destructing the node when node was dug using
---`core.node_dig` / `core.dig_node`.
---
---default: nil
---* `pos`: node position
---* `oldnode`: node table of node before it was dug
---* `oldmetadata`: metadata of node before it was dug, as a metadata table
---* `digger`: ObjectRef of digger
---@type nil | fun(pos : table, oldnode : table, oldmetadata : table, digger : table)
Callbacks.after_dig_node = function(pos, oldnode, oldmetadata, digger)

end

---Returns true if node can be dug, or false if not.
---
---default: nil
---* `pos`: node position
---* player: ObjectRef of digger TODO: в API было написано [player], это типо необязательный параметр? Я не понял
---@type nil | fun(pos : table, player : table?):boolean
Callbacks.can_dig = function(pos, player)
	return true
end

---Called when puncher (an ObjectRef) punches the node at pos.
---By default calls core.register_on_punchnode callbacks.
---
---default: core.node_punch
---* `pos`: node position
---* `node`: node being hit
---* `puncher`: ObjectRef of punch
---* `pointed_thing`: Vector of the direction of the gaze of the person who placed the block
---@type nil | fun(pos : table, node : table, puncher : table, pointed_thing : table)
Callbacks.on_punch = function(pos, node, puncher, pointed_thing)
	core.node_punch(pos, node, puncher, pointed_thing)
end

---Called when clicker (an ObjectRef) used the 'place/build' key
---(not necessarily an actual rightclick)
---while pointing at the node at pos with 'node' being the node table.
---itemstack will hold clicker's wielded item.
---Shall return the leftover itemstack.
---
---Note: pointed_thing can be nil, if a mod calls this function.
---
---default: nil
---@type nil | fun(pos : table, node : table, clicker : table, itemstack : table, pointing_thing : table?):table?
Callbacks.on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)

end


---By default checks privileges, wears out item (if tool) and removes node.
---return true if the node was dug successfully, false otherwise.
---Deprecated: returning nil is the same as returning true.
---
---default: core.node_dig
---@type nil | fun(pos : table, node : table, digger : table):boolean
Callbacks.on_dig = function(pos, node, digger)
	core.node_dig(pos, node, digger)
end

---called by NodeTimers, see core.get_node_timer and NodeTimerRef.
---* `elapsed`: total time passed since the timer was started.
---* `node`: node table (since 5.14)
---* `timeout`: timeout value of the just ended timer (since 5.14)
---return true to run the timer for another cycle with the same timeout value.
---
---default: nil
---@type nil | fun(pos : table, elapsed : number, node : table, timeout : any):boolean?
Callbacks.on_timer = function(pos, elapsed, node, timeout)

end

---fields = {name1 = value1, name2 = value2, ...}
---
---formname should be the empty string; you **must not** use formname.
---Called when an UI form (e.g. sign text input) returns data.
---See `core.register_on_player_receive_fields` for more info.
---
---default: nil
---@type nil | fun(pos :table, formname : string, fields : table, sender : any)
Callbacks.on_receive_fields = function(pos, formname, fields, sender)

end

---Called when a player wants to put something into the inventory.
---
---Return value: number of items allowed to put.
---
---Return value -1: Allow and don't modify item count in inventory.
---@type nil | fun(pos :table, from_list : string, from_index : number, to_list : string, to_index : number, count : number, player : table):number
Callbacks.allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	return -1
end

---Called when a player wants to take something out of the inventory.
---
---Return value: number of items allowed to take.
---
---Return value -1: Allow and don't modify item count in inventory.
---@type nil | fun(pos : table, listname : string, index : number, stack : table, player : table):number
Callbacks.allow_metadata_inventory_take = function(pos, listname, index, stack, player)
	return -1
end

---Called after the actual action has happened, according to what was allowed.
---
---No return value.
---@type nil | fun(pos : table, from_list : string, from_index : number, to_list : string, to_index : number, count : number, player : table)
Callbacks.on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)

end

---Called after the actual action has happened, according to what was allowed.
---
---No return value.
---@type nil | fun(pos : table, listname : string, index : number, stack : table, player : table)
Callbacks.on_metadata_inventory_put = function(pos, listname, index, stack, player)

end

---Called after the actual action has happened, according to what was allowed.
---
---No return value.
---@type nil | fun(pos : table, listname : string, index : number, stack : table, player : table)
Callbacks.on_metadata_inventory_take = function(pos, listname, index, stack, player)

end

---If defined, called when an explosion touches the node, instead of
---removing the node.
---* `intensity`: 1.0 = mid range of regular TNT.
---@type nil | fun(pos : table, intensity : number)
Callbacks.on_blast = function(pos, intensity)

end

return Callbacks