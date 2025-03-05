local table_copy, table_key_value_swap, table_keyof, pairs, ipairs, next, type, assert
	= table.copy, table.key_value_swap, table.keyof, pairs, ipairs, next, type, assert

--- Returns the number of key-value pairs in the table `t`.
--- For array-like tables, prefer the # operator.
--- @param t  table<string, any>  Table to check
--- @return   number
function table.size(t)
	assert(type(t) == 'table', 'bad argument #1 to \'table.size\' (table expected, got ' .. type(t))

	local size = 0
	for _ in pairs(t) do
		size = size + 1
	end

	return size
end

--- Returns all keys from the table `t` as an array.
--- @param t  table<string, any>  Table to check
--- @return   any[]
function table.get_keys(t)
	assert(type(t) == 'table', 'bad argument #1 to \'table.get_keys\' (table expected, got ' .. type(t))

	local keys = {}
	for key in pairs(t) do
		keys[#keys+1] = key
	end

	return keys
end

--- Returns an array of all `t` keys corresponding to the specified value.
--- @param t      table<string, any> | any[]   Table to check
--- @param value  string             | number  Value to compare against
--- @return       any[]?
function table.get_keys_by_value(t, value)
	assert(type(t) == 'table', 'bad argument #1 to \'table.get_keys_by_value\' (table expected, got ' .. type(t))

	local found = {}
	for k, v in pairs(t) do
		if v == value then
			found[#found+1] = k
		end
	end

	return #found > 0 and found or nil
end

--- Checks if the table `t` contains the specified value. Returns `true` if the key is found at least once, `false` otherwise.
--- @param t      table<string, any> | any[]  Table to check
--- @param value  any                         Value to compare against
--- @return       boolean
function table.contains(t, value)
	assert(type(t) == 'table', 'bad argument #1 to \'table.contains\' (table expected, got ' .. type(t))
	return table_keyof(t, value) ~= nil
end

local table_contains = table.contains

--- Checks if the table `t` contains the specified key. Returns `true` if the key is found at least once, `false` otherwise.
--- Use when you need to check for key, avoiding metamethods intervention.  
--- @param t    table<any, any> | any[]  Table to check
--- @param key  any                      Value to compare against
--- @return     boolean
function table.has_key(t, key)
	assert(type(t) == 'table','bad argument #1 to \'table.has_key\' (table expected, got ' .. type(t))
	assert(key ~= nil,'bad argument #2 to \'table.has_key\' (key cannot be nil)')

	for k in pairs(t) do
		if k == key then
			return true
		end
	end

	return false
end

--- Checks whether all `t` elements are equal to the specified value. Returns `true` if all elements match, `false` otherwise.
--- @param t      table<string, any>  Table to check
--- @param value  any                 Value to compare against
--- @return       boolean
function table.all_equal_to(t, value)
	assert(type(t) == 'table', 'bad argument #1 to \'table.all_equal_to\' (table expected, got ' .. type(t))
	assert(value ~= nil,'bad argument #2 to \'table.all_equal_to\' (value cannot be nil)')

	for _, v in pairs(t) do
		if v ~= value then
			return false
		end
	end

	return true
end

--- Returns a table with only specified key-value pairs of the table `t`.
--- @param t     table<string, any> | any[]
--- @param keys  string[] | number[]
--- @return      table<string, any> | any[]
function table.pick(t, keys)
	assert(type(t)    == 'table', 'bad argument #1 to \'table.pick\' (table expected, got ' .. type(t))
	assert(type(keys) == 'table', 'bad argument #2 to \'table.pick\' (table expected, got ' .. type(keys))

	local result = {}
	for _, k in ipairs(keys) do
		result[k] = t[k]
	end

	return result
end

--- Returns a `t` table copy with specified key-value pairs omitted.
--- @param t     table<string, any> | any[]
--- @param keys  string[]
--- @return      table<string, any> | any[]
function table.omit(t, keys)
	assert(type(t)    == 'table', 'bad argument #1 to \'table.exclude\' (table expected, got ' .. type(t))
	assert(type(keys) == 'table', 'bad argument #2 to \'table.exclude\' (table expected, got ' .. type(keys))

	local result = table_copy(t)
	for _, k in ipairs(keys) do
		result[k] = nil
	end

	return result
end

--- Helper function that merges 'source' into 'target' in-place
--- Don't expose it because YOU SHOULD NEVER WRITE CODE WHICH MODIFIES TABLES IN-PLACE.
--- In this case it's okay, because it's used only once and on the copy of a table.
--- @param target        table<string, any> | any[]  Target table to merge into
--- @param source        table<string, any> | any[]  Source table to merge from
--- @param recursively?  boolean                     Enable recursive merging (default: false)
local function merge_in_place(target, source, recursively)
	for key, value in pairs(source) do
		local target_val = target[key]
		local value_type = type(value)
		
		if target_val == nil then
			-- Add new key with deep copy if needed
			target[key] = (value_type == 'table') and table_copy(value) or value
		elseif recursively then
			local target_val_type = type(target_val)
			if target_val_type == 'table' and value_type == 'table' then
				-- Recursively merge into existing table
				merge_in_place(target_val, value, true)
			end
		end
	end
end

--- Merges entries from `t2` into a deep copy of `t1`, skipping existing keys.
--- @param t1            table<string, any> | any[]  Target table to merge into
--- @param t2            table<string, any> | any[]  Source table to merge from
--- @param recursively?  boolean                     Enable recursive merging (default: false)
--- @return              table<string, any> | any[]
function table.merge(t1, t2, recursively)
	assert(type(t1) == 'table', 'bad argument #1 to \'table.join\' (table expected, got ' .. type(t1))
	assert(type(t2) == 'table', 'bad argument #2 to \'table.join\' (table expected, got ' .. type(t2))

	local result = table_copy(t1)
	merge_in_place(result, t2, recursively == true)

	return result
end

--- Returns an array containing only unique values of the table `t`.
--- @param t  any[]  Array to check
--- @return   any[]
function table.unique_values(t)
	assert(type(t) == 'table', 'bad argument #1 to \'table.unique_values\' (table expected, got ' .. type(t))

	local seen = {}
	local result = {}
	for i = 1, #t do
		local value = t[i]
		if not seen[value] then
			seen[value] = true
			result[#result + 1] = value
		end
	end

	return result
end



--- Checks if table contains no elements. Returns `true` if table is empty, `false` otherwise.
--- @param t  table<string, any>  Table to check
--- @return   boolean
function table.is_empty(t)
	assert(type(t) == 'table', 'bad argument #1 to \'table.is_empty\' (table expected, got ' .. type(t))

	return next(t) == nil
end

--- Checks if table contains any of specified keys. Returns `true` if any key exists, `false` otherwise.
--- @param t     table<string, any>  Table to check
--- @param keys  string[]            Array of keys to look for
--- @return      boolean
function table.has_any_key_from(t, keys)
	assert(type(t) == 'table', 'bad argument #1 to \'table.has_any_key_from\' (table expected, got ' .. type(t))
	assert(type(keys) == 'table', 'bad argument #2 to \'table.has_any_key_from\' (table expected, got ' .. type(keys))

	for key in pairs(t) do
		if table_contains(keys, key) then
			return true
		end
	end

	return false
end


--- Deep comparison of two tables. Returns `true` if tables are deeply equal, `false` otherwise.
--- @param t1  table<string, any> | any[]  First table
--- @param t2  table<string, any> | any[]  Second table
--- @return    boolean
function table.deep_equal(t1, t2)
	assert(type(t1) == 'table', 'bad argument #1 to \'table.deep_equal\' (table expected, got ' .. type(t1))
	assert(type(t2) == 'table', 'bad argument #2 to \'table.deep_equal\' (table expected, got ' .. type(t2))

	-- Check t1's entries
	for k, v1 in pairs(t1) do
		local v2 = t2[k]
		if type(v1) == 'table' and type(v2) == 'table' then
			if not table.deep_equal(v1, v2) then
				return false
			end
		else
			if v2 ~= v1 then
				return false
			end
		end
	end

	-- Check for extra keys in t2
	for k in pairs(t2) do
		if t1[k] == nil then
			return false
		end
	end

	return true
end

--- Applies multipliers to corresponding values in the table `t`. Returns a table with resulting values.
--- @param t                table<string, number>  Input values
--- @param multiplier_table table<string, number>  Multipliers
--- @return                 table<string, number>
function table.multiply_values_with(t, multiplier_table)
	assert(type(t) == 'table', 'bad argument #1 to \'table.multiply_values_with\' (table expected, got ' .. type(t))
	assert(type(multiplier_table) == 'table', 'bad argument #2 to \'table.multiply_values_with\' (table expected, got ' .. type(multiplier_table))

	return table.map(t, function(key, value)
		return multiplier_table[key] and value * multiplier_table[key] or value
	end)
end

--- Transforms each value in `t` using a callback.
--- @param t         table<string, any> | any[]               Input table
--- @param callback  fun(key:string | number, value:any):any  Transformation callback
--- @return          table
function table.map(t, callback)
	assert(type(t) == 'table', 'bad argument #1 to \'table.map\' (table expected, got ' .. type(t))
	assert(type(callback) == 'function', 'bad argument #2 to \'table.map\' (function expected, got ' .. type(callback))

	local result = table_copy(t)
	for key, value in pairs(t) do
		result[key] = callback(key, value)
	end

	return result
end

--- Iterates over each key-value pair in `t`. For every entry calls `callback` with key and value as arguments.
--- @param t         table<string, any> | any[]           Table to iterate through.
--- @param callback  fun(key:string | number, value:any)  Callback applied to each key-value pair.
function table.for_each(t, callback)
	assert(type(t) == 'table', 'bad argument #1 to \'table.walk\' (table expected, got ' .. type(t))
	assert(type(callback) == 'function', 'bad argument #2 to \'table.walk\' (function expected, got ' .. type(callback))

	for key, value in pairs(t) do
		callback(key, value)
	end
end



--- Internal helper function for performing arithmetic operations between two tables. Returns resulting table with resulting values.
--- Works almost like `table.map`, but while modyfying a copy of `t1` (which is the same in `table.map`),
--- iterates through `t2` and therefore uses its key-value pairs.
--- @param t1           table<string, number> | number[]  Base table to modify
--- @param t2           table<string, number> | number[]  Table with values to operate with
--- @param empty_value  number                            Default value for missing keys in `t1`
--- @param op           fun(a:number, b:number):number    Operation function to apply
--- @return             table<string, number> | number[]
local function operate_values(t1, t2, empty_value, op)
	local result = table_copy(t1)
	for key, value in pairs(t2) do
		local a = t1[key] or empty_value
		result[key] = op(a, value)
	end

	return result
end

--- Adds values with identical keys. Uses `t2` keys. If `t1` lacks a key, uses `empty_value`.
--- @param t1            table<string, number> | number[]  Base table to modify
--- @param t2            table<string, number> | number[]  Table with values to add
--- @param empty_value?  number                            Default value for missing keys in t1 (default: 0)
--- @return              table<string, number> | number[]
function table.add_values(t1, t2, empty_value)
	return operate_values(t1, t2, empty_value or 0, function(a, b) return a + b end)
end

--- Subtracts t2 values from t1 values with identical keys. Uses `t2` keys. If `t1` lacks a key, uses `empty_value`.
--- @param t1            table<string, number> | number[]  Base table to modify
--- @param t2            table<string, number> | number[]  Table with values to add
--- @param empty_value?  number                            Default value for missing keys in `t1` (default: 0)
--- @return              table<string, number> | number[]
function table.subtract_values(t1, t2, empty_value)
	return operate_values(t1, t2, empty_value or 0, function(a, b) return a - b end)
end

--- Multiplies values with identical keys. Uses `t2` keys. If `t1` lacks a key, uses `empty_value`.
--- @param t1            table<string, number> | number[]  Base table to modify
--- @param t2            table<string, number> | number[]  Table with values to add
--- @param empty_value?  number                            Default value for missing keys in `t1` (default: 1)
--- @return              table<string, number> | number[]
function table.multiply_values(t1, t2, empty_value)
	return operate_values(t1, t2, empty_value or 0, function(a, b) return a * b end)
end

--- Divides `t1` values by `t2` values with identical keys. Uses `t2` keys. If `t1` lacks a key, uses `empty_value`.
--- @param t1            table<string, number> | number[]  Base table to modify
--- @param t2            table<string, number> | number[]  Table with values to add
--- @param empty_value?  number                            Default value for missing keys in `t1` (default: 1)
--- @return              table<string, number> | number[]
function table.divide_values(t1, t2, empty_value)
	local op = function(a, b)
		assert(b ~= 0, 'Division by zero in table.div_values')
		return a / b
	end
	return operate_values(t1, t2, empty_value or 0, op)
end
