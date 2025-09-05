---@class Item.Callbacks
local Callbacks = {}

-- TODO: Вписать вместо `table` более определенные классы: ItemStack, ObjectRef и т.п.

---Called when the 'place' key was pressed with the item in hand
---and pointing at a node.
---Shall place item and return the leftover itemstack
---or nil to not modify the inventory.
---The placer may be any ObjectRef or nil.
---default: core.item_place
---@param itemstack      table
---@param placer         table
---@param pointed_thing  table
---@return               table?
function Callbacks.on_place(itemstack, placer, pointed_thing)
	return core.item_place(itemstack, placer, pointed_thing)
end

---Same as on_place but called when not pointing at a node.
---Function must return either nil if inventory shall not be modified,
---or an itemstack to replace the original itemstack.
---The user may be any ObjectRef or nil.
---default: core.item_secondary_use
---@param itemstack     table
---@param user          table
---@param pointed_thing table
---@return              table?
function Callbacks.on_secondary_use(itemstack, user, pointed_thing)
	return core.item_secondary_use(itemstack, user, pointed_thing)
end

---Shall drop item and return the leftover itemstack.
---The dropper may be any ObjectRef or nil.
---default: core.item_drop
---@param itemstack  table
---@param dropper    table
---@param pos        table
---@return           table
function Callbacks.on_drop(itemstack, dropper, pos)
	return core.item_drop(itemstack, dropper, pos)
end

---Called when a dropped item is punched by a player.
---Shall pick-up the item and return the leftover itemstack or nil to not
---modify the dropped item.
---default: core.item_pickup
---@param itemstack             table    The `ItemStack` to be picked up.
---@param picker                table    Any `ObjectRef` or `nil`.
---@param pointed_thing         table?   The dropped item (a `"__builtin:item"` luaentity) as `type="object"` `pointed_thing`.
---@param time_from_last_punch  number?  Other parameters from `luaentity:on_punch`.
---@param ...                   any?     Other parameters from `luaentity:on_punch`.
---@return                      table
function Callbacks.on_pickup(itemstack, picker, pointed_thing, time_from_last_punch, ...)
	return core.item_pickup(itemstack, picker, pointed_thing, time_from_last_punch, ...)
end

---Called when user presses the 'punch/dig' key with the item in hand.
---Function must return either nil if inventory shall not be modified,
---or an itemstack to replace the original itemstack.
---e.g. itemstack:take_item(); return itemstack
---The user may be any ObjectRef or nil.
---Note that defining this callback will prevent normal punching/digging
---behavior on the client, as the interaction is instead "forwarded" to the
---server.
---default: nil
---@param itemstack      table
---@param user           table
---@param pointed_thing  table
---@return               table?
function Callbacks.on_use(itemstack, user, pointed_thing)

end

---Called after a tool is used to dig a node and will replace the default
---tool wear-out handling.
---Shall return the leftover itemstack or nil to not
---modify the dropped item.
---The user may be any ObjectRef or nil.
---default: nil
---@param itemstack  table
---@param user       table?
---@param node       any?  TODO: какой тут тип???
---@param digparams  any?  TODO: какой тут тип???
---@return           table?
function Callbacks.after_use(itemstack, user, node, digparams)

end

return Callbacks