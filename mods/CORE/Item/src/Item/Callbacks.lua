---@class Item.Callbacks
local Callbacks = {}

-- TODO: Разобраться с дубликатами аннотаций полей. Приоритетно брать аннотации из util/ide-helper

---Called when the 'place' key was pressed with the item in hand
---and pointing at a node.
---Shall place item and return the leftover itemstack
---or nil to not modify the inventory.
---The placer may be any ObjectRef or nil.
---
---default: core.item_place
---@type nil | fun(itemstack : table, placer : table, pointed_thing : table):table?
Callbacks.on_place = function(itemstack, placer, pointed_thing)
	return core.item_place(itemstack, placer, pointed_thing)
end

---Same as on_place but called when not pointing at a node.
---Function must return either nil if inventory shall not be modified,
---or an itemstack to replace the original itemstack.
---The user may be any ObjectRef or nil.
---
---default: core.item_secondary_use
---@type nil | fun(itemstack : table, user : table, pointed_thing : table):table?
Callbacks.on_secondary_use = function(itemstack, user, pointed_thing)
	return core.item_secondary_use(itemstack, user, pointed_thing)
end

---Shall drop item and return the leftover itemstack.
---The dropper may be any ObjectRef or nil.
---
---default: core.item_drop
---@type nil | fun(itemstack : table, dropper : table, pos : table):table
Callbacks.on_drop = function(itemstack, dropper, pos)
	return core.item_drop(itemstack, dropper, pos)
end

---Called when a dropped item is punched by a player.
---Shall pick-up the item and return the leftover itemstack or nil to not
---modify the dropped item.
---
---default: core.item_pickup
---* `itemstack`: the `ItemStack` to be picked up
---* `picker`: any `ObjectRef` or `nil`
---* `pointed_thing`: the dropped item (a `"__builtin:item"` luaentity) as `type="object"` `pointed_thing`
---* `time_from_last_punch`: other parameters from `luaentity:on_punch`
---* `...`: other parameters from `luaentity:on_punch`
---@type nil | fun(itemstack : table, picker : table, pointed_thing : table?, time_from_last_punch : number?, ... : any?):table?
Callbacks.on_pickup = function(itemstack, picker, pointed_thing, time_from_last_punch, ...)
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
---
---default: nil
---@type nil | fun(itemstack : table, user : table, pointed_thing : table):table?
Callbacks.on_use = function(itemstack, user, pointed_thing)

end

---Called after a tool is used to dig a node and will replace the default
---tool wear-out handling.
---Shall return the leftover itemstack or nil to not
---modify the dropped item.
---The user may be any ObjectRef or nil.
---
---default: nil
---
---TODO: разобраться какие типы должны быть у node и diagrams
---@type nil | fun(itemstack : table, user : table?, node : any?, diagrams : any?):table?
Callbacks.after_use = function(itemstack, user, node, digparams)

end

return Callbacks