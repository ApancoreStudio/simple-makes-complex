local tostring = tostring

Ensure = {}

--- Validates a function argument's type and throws a descriptive error on mismatch.
--- @param arg            any     The argument value to type-check
--- @param expectedType   string  Expected Lua type name (e.g., "number", "table", "string")
--- @param n              number  Argument position in function call (1-based index)
--- @param function_name  string  Name of the parent function for error reporting
function Ensure.argType(arg, expectedType, n, function_name)
	local actualType = type(arg)
	assert(actualType == expectedType, 'bad argument #%s to \'%s\' (%s expected, got %s)', tostring(n), function_name, expectedType, actualType)
end

--- @param arg           any     The argument value to type-check
--- @param n             number  Argument position in function call (1-based index)
--- @param function_name  string  Name of the parent function for error reporting
function Ensure.argNotNil(arg, n, function_name)
	assert(arg ~= nil, 'bad argument #%s to \'%s\' (key cannot be nil)', n,  function_name)
end


function Ensure.zeroDivision(divider, function_name)
	assert(divider ~= 0, 'Division by zero in \'%s\'', function_name)
end

