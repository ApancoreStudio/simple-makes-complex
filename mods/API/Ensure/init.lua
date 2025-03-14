local tostring = tostring

Ensure = {}

--- Validates a function argument's type and throws a descriptive error on mismatch.
--- @param arg            any     The argument value to type-check
--- @param expectedType   string  Expected Lua type name (e.g., "number", "table", "string")
--- @param n              number  Argument position in function call (1-based index)
--- @param function_name  string  Name of the parent function for error reporting
function Ensure.argType(arg, expectedType, n, function_name)
	local actualType = type(arg)
	assert(actualType == expectedType, string.format(
		'bad argument #%s to \'%s\' (%s expected, got %s)',
		tostring(n),
		function_name,
		expectedType,
		actualType))
end

local ensureArgType = Ensure.argType

--- @param arg            string  The string to check
--- @param n              number  Argument position in function call (1-based index)
--- @param function_name  string  Name of the parent function for error reporting
function Ensure.stringArgNotEmpty(arg, n, function_name)
	ensureArgType(arg, 'string', 1, 'Ensure.stringArgNotEmpty')
	assert(#arg ~= 0, string.format('bad argument #%s to \'%s\' (string cannot be empty)', n,  function_name))
end

--- @param arg            any     The argument value to check
--- @param n              number  Argument position in function call (1-based index)
--- @param function_name  string  Name of the parent function for error reporting
function Ensure.argNotNil(arg, n, function_name)
	assert(arg ~= nil, string.format('bad argument #%s to \'%s\' (key cannot be nil)', n,  function_name))
end

--- @param divider        number  The number to check
--- @param function_name  string  Name of the parent function for error reporting
function Ensure.zeroDivision(divider, function_name)
	assert(divider ~= 0, string.format('Division by zero in \'%s\'', function_name))
end

