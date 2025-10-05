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
---@type (fun(itemstack:ItemStack, placer:Player|ObjectRef|nil, pointed_thing:pointed_thing):ItemStack|nil, Position|vector|nil)?
Callbacks.on_place = core.item_place

---Same as on_place but called when not pointing at a node.
---Function must return either nil if inventory shall not be modified,
---or an itemstack to replace the original itemstack.
---The user may be any ObjectRef or nil.
---
---default: core.item_secondary_use
---@type fun(itemstack:ItemStack, user:Player|ObjectRef|nil, pointed_thing:pointed_thing)?
Callbacks.on_secondary_use = nil

---Shall drop item and return the leftover itemstack.
---The dropper may be any ObjectRef or nil.
---
---default: core.item_drop
---@type (fun(itemstack:ItemStack|ItemStackString, dropper:Player|ObjectRef|nil, pos:Position):ItemStack)?
Callbacks.on_drop = core.item_drop

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
---@type fun(itemstack:ItemStack, picker:Player|ObjectRef|nil, pointed_thing:pointed_thing, time_from_last_punch, ...)?
Callbacks.on_pickup = core.item_pickup

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
---@type (fun(itemstack:ItemStack, user:Player|ObjectRef|nil, pointed_thing:pointed_thing):ItemStack|nil)?
Callbacks.on_use = nil

---Called after a tool is used to dig a node and will replace the default
---tool wear-out handling.
---Shall return the leftover itemstack or nil to not
---modify the dropped item.
---The user may be any ObjectRef or nil.
---
---default: nil
---
---@type fun(itemstack:ItemStack, user:Player|ObjectRef|nil, node, digparams)?
Callbacks.after_use = nil

return Callbacks