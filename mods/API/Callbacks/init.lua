Callbacks = {}

---@alias Callbacks.callbackFunc  fun(callbackName, ...)

---@type table<string, Callbacks.callbackFunc[]>
local registeredCallbacks = {}

---@param callbackName string
function Callbacks.registerCallback(callbackName)
	assert(registeredCallbacks[callbackName] == nil, ('Callback %s is already registered.'):format(callbackName))

	registeredCallbacks[callbackName] = {}
end

---@param callbackName  string
---@param callbackFunc  Callbacks.callbackFunc
function Callbacks.subscribe(callbackName, callbackFunc)
	local callbacks = registeredCallbacks[callbackName]
	assert(callbacks ~= nil, ('Callback %s does not exist'):format(callbackName))

	table.insert(callbacks, callbackFunc)
end

---@param callbackName  string
---@param ...           any
function Callbacks.call(callbackName, ...)
	local callbacks = registeredCallbacks[callbackName]
	assert(callbacks ~= nil, ('Callback %s does not exist'):format(callbackName))

	for _, func in ipairs(callbacks) do
		func(callbackName, ...)
	end
end