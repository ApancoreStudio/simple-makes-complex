Events = {}

---@alias Events.callback  fun(eventName, ...)

---@type table<string, Events.callback[]>
local registeredEvents = {}

---@param eventName string
function Events.registerEvent(eventName)
	assert(registeredEvents[eventName] == nil, ('Event %s is already registered.'):format(eventName))

	registeredEvents[eventName] = {}
end

---@param eventName  string
---@param callback   Events.callback
function Events.subscribe(eventName, callback)
	local callbacks = registeredEvents[eventName]
	assert(callbacks ~= nil, ('Event %s does not exist'):format(eventName))

	table.insert(callbacks, callback)
end

---@param eventName  string
---@param ...        any
function Events.call(eventName, ...)
	local callbacks = registeredEvents[eventName]
	assert(callbacks ~= nil, ('Event %s does not exist'):format(eventName))

	for _, func in ipairs(callbacks) do
		func(eventName, ...)
	end
end