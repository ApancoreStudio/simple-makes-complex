local tableCopy, tableKeyOf, pairs, ipairs, next, type, assert, ensureArgType,  ensureArgNotNil
	= table.copy, table.keyof, pairs, ipairs, next, type, assert, Ensure.argType, Ensure.argNotNil

-- While extending Lua's table library, we maintain snake_case naming for standard library
-- functions and arguments to match standard library conventions. The code that is not exposed
-- to the outer scope continues to use our camelCase convention.

--- Returns the number of key-value pairs in the table `t`.
--- For array-like tables, prefer the # operator.
--- @param t  table<string, any>  Table to check
--- @return   number
function table.get_size(t)
	ensureArgType(t, 'table', 1, 'table.get_size')

	local size = 0
	for _ in pairs(t) do
		size = size + 1
	end

	return size
end

--- Returns all keys from the table `t` as an array.
--- @param t  table<string, any>  Table to check
--- @return   string[] | number[]
function table.get_keys(t)
	ensureArgType(t, 'table', 1, 'table.get_keys')

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
	ensureArgType(t, 'table', 1, 'table.get_keys_by_value')

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
	ensureArgType(t, 'table', 1, 'table.contains')
	return tableKeyOf(t, value) ~= nil
end

local tableContains = table.contains

--- Checks if the table `t` contains the specified key. Returns `true` if the key is found at least once, `false` otherwise.
--- Use when you need to check for key, avoiding metamethods intervention.  
--- @param t    table<any, any> | any[]  Table to check
--- @param key  any                      Value to compare against
--- @return     boolean
function table.has_key(t, key)
	ensureArgType(t, 'table', 1, 'table.has_key')
	ensureArgNotNil(key, 2, 'table.has_key')

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
	ensureArgType(t, 'table', 1, 'table.all_equal_to')
	ensureArgNotNil(value, 2, 'table.all_equal_to')

	for _, v in pairs(t) do
		if v ~= value then
			return false
		end
	end

	return true
end

--- Returns a table with only specified key-value pairs of the table `t`.
--- @param t     table<string, any> | any[]  Original table
--- @param keys  string[] | number[]         Array of keys
--- @return      table<string, any> | any[]
function table.pick(t, keys)
	ensureArgType(t,    'table', 1, 'table.pick')
	ensureArgType(keys, 'table', 2, 'table.pick')

	local result = {}
	for _, k in ipairs(keys) do
		result[k] = t[k]
	end

	return result
end

--- Returns a `t` table copy with specified key-value pairs omitted.
--- @param t     table<string, any> | any[]  Original table
--- @param keys  string[] | number[]         Array of keys
--- @return      table<string, any> | any[]
function table.omit(t, keys)
	ensureArgType(t,    'table', 1, 'table.omit')
	ensureArgType(keys, 'table', 2, 'table.omit')

	local result = tableCopy(t)
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
local function mergeInPlace(target, source, recursively)
	for key, value in pairs(source) do
		local targetValue = target[key]
		local valueType = type(value)
		
		if targetValue == nil then
			-- Add new key with deep copy if needed
			target[key] = (valueType == 'table') and tableCopy(value) or value
		elseif recursively then
			local targetValueType = type(targetValue)
			if targetValueType == 'table' and valueType == 'table' then
				-- Recursively merge into existing table
				mergeInPlace(targetValue, value, true)
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
	ensureArgType(t1, 'table', 1, 'table.merge')
	ensureArgType(t2, 'table', 2, 'table.merge')

	local result = tableCopy(t1)
	mergeInPlace(result, t2, recursively == true)

	return result
end

--- Returns an array containing only unique values of the table `t`.
--- @param t  any[]  Array to check
--- @return   any[]
function table.unique_values(t)
	ensureArgType(t, 'table', 1, 'table.unique_values')

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
	ensureArgType(t, 'table', 1, 'table.is_empty')

	return next(t) == nil
end

--- Checks if table contains any of specified keys. Returns `true` if any key exists, `false` otherwise.
--- @param t     table<string, any>  Table to check
--- @param keys  string[]            Array of keys to look for
--- @return      boolean
function table.has_any_key_from(t, keys)
	ensureArgType(t,    'table', 1, 'table.has_any_key_from')
	ensureArgType(keys, 'table', 2, 'table.has_any_key_from')

	for key in pairs(t) do
		if tableContains(keys, key) then
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
	ensureArgType(t1, 'table', 1, 'table.deep_equal')
	ensureArgType(t2, 'table', 2, 'table.deep_equal')

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

--- Transforms each value in `t` using a callback.
--- @param t         table<string, any> | any[]               Input table
--- @param callback  fun(key:string | number, value:any):any  Transformation callback
--- @return          table
function table.map(t, callback)
	ensureArgType(t,        'table',    1, 'table.map')
	ensureArgType(callback, 'function', 2, 'table.map')

	local result = tableCopy(t)
	for key, value in pairs(t) do
		result[key] = callback(key, value)
	end

	return result
end

local tableMap = table.map

--- Applies multipliers to corresponding values in the table `t`. Returns a table with resulting values.
--- @param t                table<string, number>  Input values
--- @param multiplier_table table<string, number>  Multipliers
--- @return                 table<string, number>
function table.multiply_values_with(t, multiplier_table)
	ensureArgType(t,                'table', 1, 'table.multiply_values_with')
	ensureArgType(multiplier_table, 'table', 2, 'table.multiply_values_with')

	return tableMap(t, function(key, value)
		return multiplier_table[key] and value * multiplier_table[key] or value
	end)
end

--- Iterates over each key-value pair in `t`. For every entry calls `callback` with key and value as arguments.
--- @param t         table<string, any> | any[]           Table to iterate through.
--- @param callback  fun(key:string | number, value:any)  Callback applied to each key-value pair.
function table.for_each(t, callback)
	ensureArgType(t,        'table',    1, 'table.for_each')
	ensureArgType(callback, 'function', 2, 'table.for_each')

	for key, value in pairs(t) do
		callback(key, value)
	end
end


--- Internal helper function for performing arithmetic operations between two tables. Returns resulting table with resulting values.
--- Works almost like `table.map`, but while modyfying a copy of `t1` (which is the same in `table.map`),
--- iterates through `t2` and therefore uses its key-value pairs.
--- @param t1          table<string, number> | number[]  Base table to modify
--- @param t2          table<string, number> | number[]  Table with values to operate with
--- @param emptyValue  number                            Default value for missing keys in `t1`
--- @param operation   fun(a:number, b:number):number    Operation function to apply
--- @return            table<string, number> | number[]
local function operateValues(t1, t2, emptyValue, operation)
	local result = tableCopy(t1)
	for key, value in pairs(t2) do
		local a = t1[key] or emptyValue
		result[key] = operation(a, value)
	end

	return result
end

--- Adds values with identical keys. Uses `t2` keys. If `t1` lacks a key, uses `empty_value`.
--- @param t1            table<string, number> | number[]  Base table to modify
--- @param t2            table<string, number> | number[]  Table with values to add
--- @param empty_value?  number                            Default value for missing keys in t1 (default: 0)
--- @return              table<string, number> | number[]
function table.add_values(t1, t2, empty_value)
	ensureArgType(t1, 'table', 1, 'table.add_values')
	ensureArgType(t2, 'table', 2, 'table.add_values')

	return operateValues(t1, t2, empty_value or 0, function(a, b) return a + b end)
end

--- Subtracts t2 values from t1 values with identical keys. Uses `t2` keys. If `t1` lacks a key, uses `empty_value`.
--- @param t1            table<string, number> | number[]  Base table to modify
--- @param t2            table<string, number> | number[]  Table with values to add
--- @param empty_value?  number                            Default value for missing keys in `t1` (default: 0)
--- @return              table<string, number> | number[]
function table.subtract_values(t1, t2, empty_value)
	ensureArgType(t1, 'table', 1, 'table.subtract_values')
	ensureArgType(t2, 'table', 2, 'table.subtract_values')

	return operateValues(t1, t2, empty_value or 0, function(a, b) return a - b end)
end

--- Multiplies values with identical keys. Uses `t2` keys. If `t1` lacks a key, uses `empty_value`.
--- @param t1            table<string, number> | number[]  Base table to modify
--- @param t2            table<string, number> | number[]  Table with values to add
--- @param empty_value?  number                            Default value for missing keys in `t1` (default: 1)
--- @return              table<string, number> | number[]
function table.multiply_values(t1, t2, empty_value)
	ensureArgType(t1, 'table', 1, 'table.multiply_values')
	ensureArgType(t2, 'table', 2, 'table.multiply_values')

	return operateValues(t1, t2, empty_value or 1, function(a, b) return a * b end)
end

--- Divides `t1` values by `t2` values with identical keys. Uses `t2` keys. If `t1` lacks a key, uses `empty_value`.
--- @param t1            table<string, number> | number[]  Base table to modify
--- @param t2            table<string, number> | number[]  Table with values to add
--- @param empty_value?  number                            Default value for missing keys in `t1` (default: 1)
--- @return              table<string, number> | number[]
function table.divide_values(t1, t2, empty_value)
	ensureArgType(t1, 'table', 1, 'table.add_values')
	ensureArgType(t2, 'table', 2, 'table.divide_values')

	local operation = function(a, b)
		assert(b ~= 0, 'Division by zero in table.div_values')
		return a / b
	end
	return operateValues(t1, t2, empty_value or 1, operation)
end
