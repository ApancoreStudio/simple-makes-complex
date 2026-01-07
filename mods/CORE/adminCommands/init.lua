local modInfo = Mod.getInfo('smc__core__formspec')
local require = modInfo.require

---@type Formspec
local Formspec = require('Formspec')

local listForm = Formspec:new({
	size = {x=21, y=12},
})

listForm:list('current_player', 'main', 10.5, 6.5, 8, 4)

local listFormItems = Formspec:new()

local items = core.registered_nodes

local w, h = 0, 0

---@param name  string
---@param def  NodeDefinition
for name, def in pairs(items) do
	listFormItems:itemImageButton(w, h, 1, 1, name, name..'::item_button')

	w = w + 1

	if w > 9 then
		w = 0
		h = h + 1
	end
end

--listFormItems:list('current_player', 'main', 0, 0, 1, 32)

listForm:scrollContainer(listFormItems, 0.5, 0.5, 9, 11, 'admin_commands:list_items', 'vertical')
listForm:scrollbar(10, 0.5, 0.25, 10, 'vertical', 'admin_commands:list_items')

core.log(listForm:toString())

core.register_chatcommand('list', {
	privs = {server = true},

	func = function(name, param)
		local player = core.get_player_by_name(name)

		core.show_formspec(name, 'admin_commands:list_form', listForm:toString())

		return true, ''
	end
})

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= 'admin_commands:list_form' then
		return
	end

	for key, value in pairs(fields) do
		if string.ends_with(key, '::item_button') then
			---@type ItemStackString
			local stack = string.match(key, '(%S+)::item_button')

			core.log(tostring(stack))

			---@type InvRef
			local inv = player:get_inventory()

			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
			end
		end
	end
end)