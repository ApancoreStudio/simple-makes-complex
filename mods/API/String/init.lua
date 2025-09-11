local sub, upper, ensureArgType
	= string_utf8.sub, string_utf8.upper, Ensure.argType

--- Writes a string with a capital letter.
--- @param str  string  Input string.
--- @return     string?
function string.capitalize(str)
	ensureArgType(str, "string", 1, "string.capitalize")

	local first_char = sub(str,1, 1)

	if not first_char then
		return
	end

	first_char = upper(first_char)

	return first_char..sub(str,2, -1)
end

--- Capitalizes each word in a line.
--- @param str  string  Input string.
--- @return     string?
function string.to_title(str)
	ensureArgType(str, "string", 1, "string.to_title")

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
	ensureArgType(str, "string", 1, "string.remove_underscores")
	local output = str:gsub("_", " ")

	return output
end

--- Checks if a string starts with `prefix`.
--- @param str     string  String to check.
--- @param prefix  string  The string the `str` should start with.
--- @return        boolean
function string.starts_with(str, prefix)
	ensureArgType(str, "string", 1, "string.starts_with")
	ensureArgType(prefix, "string", 2, "string.starts_with")

	return str:sub(1, #prefix) == prefix
end


--- Checks if a string end with `prefix`.
--- @param str     string  String to check.
--- @param suffix  string  The string the `str` should end with.
--- @return        boolean
function string.ends_with(str, suffix)
	ensureArgType(str, "string", 1, "string.ends_with")
	ensureArgType(suffix, "string", 2, "string.ends_with")

	return str:sub(-#suffix, -1) == suffix
end

--- Checks if the string contains a specific substring.
--- @param str         string  String to check.
--- @param sub_string  string  The text segment to search for within the string.
--- @return            boolean
function string.contains(str, sub_string)
	ensureArgType(str, "string", 1, "string.contains")
	ensureArgType(sub_string, "string", 2, "string.contains")

	return str:find(sub_string, 1, true) ~= nil
end



-- EMMYLUA ANNOTATIONS OVERWRITES --

--- Returns a copy of `s` in which all (or the first `n`, if given)
--- occurrences of the `pattern` have been replaced by a replacement string
--- specified by `repl`, which can be a string, a table, or a function. `gsub`
--- also returns, as its second value, the total number of matches that
--- occurred.
---
--- If `repl` is a string, then its value is used for replacement. The character
--- `%` works as an escape character: any sequence in `repl` of the form `%n`,
--- with *n* between 1 and 9, stands for the value of the *n*-th captured
--- substring (see below). The sequence `%0` stands for the whole match. The
--- sequence `%%` stands for a single `%`.
---
--- If `repl` is a table, then the table is queried for every match, using
--- the first capture as the key; if the pattern specifies no captures, then
--- the whole match is used as the key.
---
--- If `repl` is a function, then this function is called every time a match
--- occurs, with all captured substrings passed as arguments, in order; if
--- the pattern specifies no captures, then the whole match is passed as a
--- sole argument.
---
--- If the value returned by the table query or by the function call is a
--- string or a number, then it is used as the replacement string; otherwise,
--- if it is false or nil, then there is no replacement (that is, the original
--- match is kept in the string).
---
--- Here are some examples:
--- `x = string.gsub("hello world", "(%w+)", "%1 %1")`
--- `-- > x="hello hello world world"`
--- `x = string.gsub("hello world", "%w+", "%0 %0", 1)`
--- `-- > x="hello hello world"`
--- `x = string.gsub("hello world from Lua", "(%w+)%s*(%w+)", "%2 %1")`
--- `-- > x="world hello Lua from"`
--- `x = string.gsub("home = $HOME, user = $USER", "%$(%w+)", os.getenv)`
--- `-- > x="home = /home/roberto, user = roberto"`
--- `x = string.gsub("4+5 = $return 4+5$", "%$(.-)%$", function (s)`
---  >> return loadstring(s)()
---  > end)
--- `-- > x="4+5 = 9"`
--- `local t = {name="lua", version="5.3"}`
--- `x = string.gsub("$name-$version.tar.gz", "%$(%w+)", t)`
--- > x="lua-5.3.tar.gz"
-- -@overload fun(s:string, pattern:string, repl:string|table|fun()):string, number
-- -@param s string
-- -@param pattern string
-- -@param repl string|table|fun(param:string)
-- -@param n? number
-- -@return string, number
-- function string.gsub(s, pattern, repl, n) end