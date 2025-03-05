--- Validates a function argument's type and throws a descriptive error on mismatch.
--- @param variable       any     The argument value to type-check
--- @param expected_type  string  Expected Lua type name (e.g., "number", "table", "string")
--- @param n              number  Argument position in function call (1-based index)
--- @param func           string  Name of the parent function for error reporting
function ensure_arg_type(variable, expected_type, n, func)
	local actual_type = type(variable)
	assert(actual_type == expected_type, 'bad argument #%s to \'%s\' (%s expected, got %s)', tostring(n), func, expected_type, actual_type)
end
