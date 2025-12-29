---Global API for implementing callbacks.
Callbacks = {}

---@alias callbackFunc  fun(callbackName, ...)

---@type table<string, callbackFunc[]>
local registeredCallbacks = {}

---@param callbackName string
function Callbacks.registerCallback(callbackName)
	assert(registeredCallbacks[callbackName] == nil, ('Callback %s is already registered.'):format(callbackName))

	registeredCallbacks[callbackName] = {}
end

---@param callbackName  string
---@param callbackFunc  callbackFunc
function Callbacks.subscribe(callbackName, callbackFunc)
	local callbacks = registeredCallbacks[callbackName]
	assert(callbacks ~= nil, ('Callback %s does not exist'):format(callbackName))

	table.insert(callbacks, callbackFunc)
end

function Callbacks.call(callbackName, ...)
	local callbacks = registeredCallbacks[callbackName]
	assert(callbacks ~= nil, ('Callback %s does not exist'):format(callbackName))

	for _, func in ipairs(callbacks) do
		func(callbackName, ...)
	end
end