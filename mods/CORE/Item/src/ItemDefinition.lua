---@class ItemDefinition
---@field settings  table
---@field callbacks  table
local ItemDefinition = {
	settings = {
		name = '',
		title = '', -- 1st line of item description
		description = '', -- the rest of item description
		visual = '', -- '3d' | 'flat'
		...
	},
	callbacks = {
	},
}

return ItemDefinition
