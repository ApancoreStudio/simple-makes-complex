local pairs, string_gsub
	= pairs, string.gsub

-- Cyrillic symbols replacement dictionary.
local cyrillic_alphabet = {
	["А"] = "а",
	["Б"] = "б",
	["В"] = "в",
	["Г"] = "г",
	["Д"] = "д",
	["Е"] = "е",
	["Ё"] = "ё",
	["Ж"] = "ж",
	["З"] = "з",
	["И"] = "и",
	["Й"] = "й",
	["К"] = "к",
	["Л"] = "л",
	["М"] = "м",
	["Н"] = "н",
	["О"] = "о",
	["П"] = "п",
	["Р"] = "р",
	["С"] = "с",
	["Т"] = "т",
	["У"] = "у",
	["Ф"] = "ф",
	["Х"] = "х",
	["Ц"] = "ц",
	["Ч"] = "ч",
	["Ш"] = "ш",
	["Щ"] = "щ",
	["Ъ"] = "ъ",
	["Ь"] = "ь",
	["Э"] = "э",
	["Ю"] = "ю",
	["Я"] = "я",
}

--- Same as `string.lower` but with cyrillic support.
--- @param str string Input string.
--- @return    string
function string.lower_cyrillic(str)
	-- assert

	local new_str = string.lower(str)
	for S, s in pairs(cyrillic_alphabet) do
		new_str = string_gsub(new_str, S, s)
	end

	return new_str
end

--- Same as `string.upper` but with cyrillic support.
--- @param str string Input string.
--- @return    string
function string.upper_cyrillic(str)
	-- assert

	local new_str = string.upper(str)
	for S, s in pairs(cyrillic_alphabet) do
		new_str = string_gsub(new_str, s, S)
	end

	return new_str
end

--- Writes a string with a capital letter. Doesn't work with cyrillic.
--- @param str string Input string.
--- @return string
function string.capitalize(str)
	-- assert

	return str:sub(1, 1):upper() .. str:sub(2, -1)
end

--- Capitalizes each word in a line. Doesn't work with cyrillic.
--- @param str string Input string.
--- @return string
function string.to_title(str)
	-- assert

	local result = ""
	for _, word in ipairs(str:split(" ")) do
		result = string.format("%s%s ", result, word:capitalize())
	end

	return result:trim()
end

--- Replaces underscores with spaces in a string.
--- @param str string Input string.
--- @return string
function string.remove_underscores(str)
	-- assert

	return str:gsub("_", " ")
end

--- Checks if a string starts with `prefix`.
--- @param str    string String to check.
--- @param prefix string The string the `str` should start with.
--- @return       boolean
function string.starts_with(str, prefix)
	-- assert

	return str:sub(1, #prefix) == prefix
end


--- Checks if a string end with `prefix`.
--- @param str    string String to check.
--- @param suffix string The string the `str` should end with.
--- @return       boolean
function string.ends_with(str, suffix)
	-- assert

	return str:sub(-#suffix, -1) == suffix
end

--- Checks if the string contains a specific substring.
--- @param str        string String to check.
--- @param sub_string string The text segment to search for within the string.
--- @return           boolean
function string.contains(str, sub_string)
	-- assert

	return str:find(sub_string, 1, true) ~= nil
end

string.replace = string.gsub
