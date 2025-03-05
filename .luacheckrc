unused_args       = false
allow_defined_top = true
max_line_length = 150

std = "lua51"

globals = {
	"core",
}

read_globals = {
	table  = { fields = {
		-- MT Builtin:
		"copy", "indexof", "insert_all", "key_value_swap",
		-- our Core/helpers:
		-- table:
		"contains", "keyof", "has_value", "has_key", "merge", "join", "merge_values",
		"is_empty", "overwrite", "keys_of", "count", "keys", "values",
		"only", "except", "keys_has_one_of_values", "equals", "multiply_each_value",
		"map", "add_values", "sub_values", "mul_values", "div_values"
	} },

	string = { fields = {
		-- MT Builtin:
		"split", "trim",
		-- our Core/helpers:
		"is_one_of", "replace",
		-- TODO: "startsWith", "endsWith", ...
	} },

	math = { fields = {
		-- MT Builtin:
		"sign", "hypot", "factorial", "round",
		-- Core/helpers:
		"limit", "clamp"
	} },

	io = { fields = {
		-- our Core/helpers:
		"file_exists", "write_to_file", "read_from_file"
	} },

	os = { fields = {
		-- our Core/helpers:
		"DIRECTORY_SEPARATOR",
	} },

	-- Builtin
	"vector", "nodeupdate", "PseudoRandom",
	"VoxelManip", "VoxelArea",
	"ItemStack", "Settings",
	"dump", "DIR_DELIM",

	-- Mods APIs
	"intllib",
	"screwdriver",
	"armor", -- lottarmor
	"multiskin", -- lottarmor
	"mobs",
	"worldedit",
	"areas",

	-- Functions:
	"get_mail", -- mail_list из lord-server/lord_ext
	"within_limits", -- mobs api

	-- Legacy
	"spawn_falling_node",
}

exclude_files     = {
}
