local pairs, string_gsub
	= pairs, string.gsub

string.replace = string.gsub

--- Writes a string with a capital letter.
--- @param str  string  Input string.
--- @return     string
function string.capitalize(str)
	Ensure.argType(str, "string", 1, "string.capitalize")
	Ensure.argNotNil(str, 1,"string.capitalize")

	local first_char = string_utf8.sub(str,1, 1)
	first_char = string_utf8.upper(first_char)

	return first_char..string_utf8.sub(str,2, -1)
end

--- Capitalizes each word in a line.
--- @param str  string  Input string.
--- @return     string
function string.to_title(str)
	Ensure.argType(str, "string", 1, "string.to_title")
	Ensure.argNotNil(str, 1,"string.to_title")

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
	Ensure.argType(str, "string", 1, "string.remove_underscores")
	Ensure.argNotNil(str, 1,"string.remove_underscores")

	return str:gsub("_", " ")
end

--- Checks if a string starts with `prefix`.
--- @param str     string  String to check.
--- @param prefix  string  The string the `str` should start with.
--- @return        boolean
function string.starts_with(str, prefix)
	Ensure.argType(str, "string", 1, "string.starts_with")
	Ensure.argType(prefix, "string", 2, "string.starts_with")

	Ensure.argNotNil(str, 1,"string.starts_with")
	Ensure.argNotNil(prefix, 2,"string.starts_with")

	return str:sub(1, #prefix) == prefix
end


--- Checks if a string end with `prefix`.
--- @param str     string  String to check.
--- @param suffix  string  The string the `str` should end with.
--- @return        boolean
function string.ends_with(str, suffix)
	Ensure.argType(str, "string", 1, "string.ends_with")
	Ensure.argType(suffix, "string", 2, "string.ends_with")

	Ensure.argNotNil(str, 1,"string.ends_with")
	Ensure.argNotNil(suffix, 2,"string.ends_with")

	return str:sub(-#suffix, -1) == suffix
end

--- Checks if the string contains a specific substring.
--- @param str         string  String to check.
--- @param sub_string  string  The text segment to search for within the string.
--- @return            boolean
function string.contains(str, sub_string)
	Ensure.argType(str, "string", 1, "string.contains")
	Ensure.argType(sub_string, "string", 2, "string.contains")

	Ensure.argNotNil(str, 1,"string.contains")
	Ensure.argNotNil(sub_string, 2,"string.contains")

	return str:find(sub_string, 1, true) ~= nil
end
