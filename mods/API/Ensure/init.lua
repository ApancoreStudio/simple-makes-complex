local tostring = tostring

Ensure = {}

--- Validates a function argument's type and throws a descriptive error on mismatch.
--- @param arg           any     The argument value to type-check
--- @param expectedType  string  Expected Lua type name (e.g., "number", "table", "string")
--- @param n             number  Argument position in function call (1-based index)
--- @param functionName  string  Name of the parent function for error reporting
function Ensure.argType(arg, expectedType, n, functionName)
	local actualType = type(arg)
	assert(actualType == expectedType, string.format(
		'bad argument #%s to \'%s\' (%s expected, got %s)',
		tostring(n),
		functionName,
		expectedType,
		actualType))
end

local ensureArgType = Ensure.argType

--- @param arg             any     The argument value to type-check
--- @param allowedOptions  table   Lookup table where keys represent valid options (with true values)
--- @param n               number  Argument position in function call (1-based index)
--- @param functionName    string  Name of the parent function for error reporting
function Ensure.argIsAllowed(arg, allowedOptions , n, functionName)
	assert(allowedOptions[arg] == true, string.format(
		'bad argument #%s to \'%s\' (the value is not allowed)',
		tostring(n),
		functionName))
end

--- @param arg           string  The string to check
--- @param n             number  Argument position in function call (1-based index)
--- @param functionName  string  Name of the parent function for error reporting
function Ensure.stringArgNotEmpty(arg, n, functionName)
	ensureArgType(arg, 'string', 1, 'Ensure.stringArgNotEmpty')
	assert(#arg ~= 0, string.format('bad argument #%s to \'%s\' (string cannot be empty)', n,  functionName))
end

--- @param arg           any     The argument value to check
--- @param n             number  Argument position in function call (1-based index)
--- @param functionName  string  Name of the parent function for error reporting
function Ensure.argNotNil(arg, n, functionName)
	assert(arg ~= nil, string.format('bad argument #%s to \'%s\' (key cannot be nil)', n,  functionName))
end

--- @param divider       number  The number to check
--- @param functionName  string  Name of the parent function for error reporting
function Ensure.zeroDivision(divider, functionName)
	assert(divider ~= 0, string.format('Division by zero in \'%s\'', functionName))
end

