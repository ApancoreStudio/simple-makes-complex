local pairs, string_gsub
	= pairs, string.gsub

dofile(core.get_modpath(core.get_current_modname()).."/utf8.lua")

string.replace = string.gsub

--- Writes a string with a capital letter.
--- @param str  string  Input string.
--- @return     string
function string.capitalize(str)
	-- assert
	local first_char = string_utf8.sub(str,1, 1)
	first_char = string_utf8.upper(first_char)

	return first_char..string_utf8.sub(str,2, -1)
end

--- Capitalizes each word in a line.
--- @param str  string  Input string.
--- @return     string
function string.to_title(str)
	-- assert

	local result = ""
	for _, word in ipairs(str:split(" ")) do
		result = string.format("%s%s ", result, word:capitalize())
	end

	return result:trim()
end

--- Replaces underscores with spaces in a string.
--- @param str  string  Input string.
--- @return     string
function string.remove_underscores(str)
	-- assert

	return str:gsub("_", " ")
end

--- Checks if a string starts with `prefix`.
--- @param str     string  String to check.
--- @param prefix  string  The string the `str` should start with.
--- @return        boolean
function string.starts_with(str, prefix)
	-- assert

	return str:sub(1, #prefix) == prefix
end


--- Checks if a string end with `prefix`.
--- @param str     string  String to check.
--- @param suffix  string  The string the `str` should end with.
--- @return        boolean
function string.ends_with(str, suffix)
	-- assert

	return str:sub(-#suffix, -1) == suffix
end

--- Checks if the string contains a specific substring.
--- @param str         string  String to check.
--- @param sub_string  string  The text segment to search for within the string.
--- @return            boolean
function string.contains(str, sub_string)
	-- assert

	return str:find(sub_string, 1, true) ~= nil
end
