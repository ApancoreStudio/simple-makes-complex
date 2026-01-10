---@type {timeDelay:number, callbackFunc:fun(deltaTime:number), timer:number, lastCall:number}[]
local callsWithDelay = {}

---@param timeDelay     number
---@param callbackFunc  fun(deltaTime:number)
function Api.registerGlobalStepWithDelay(timeDelay, callbackFunc)
	table.insert(callsWithDelay, {
		timeDelay    = timeDelay,
		callbackFunc = callbackFunc,
		timer        = 0.0,
		lastCall    = 0.0
	})
end

core.register_globalstep(function(deltaTime)
	---@type number
	local timer
	local lastCall

	for _, callback in ipairs(callsWithDelay) do
		timer    = callback.timer
		lastCall = callback.lastCall

		timer    = timer + deltaTime
		lastCall = lastCall + deltaTime

		if timer >= callback.timeDelay then
			callback.callbackFunc(lastCall)
			callback.timer    = timer - callback.timeDelay
			callback.lastCall = 0.0
		else
			callback.timer    = timer
			callback.lastCall = lastCall
		end
	end
end)

---@type {timeDelay:number, callbackFunc:fun(deltaTime:number, player), timer:number, lastCall:number}[]
local callsForEachPlayer = {}

---@param timeDelay     number
---@param callbackFunc  fun(deltaTime:number, player:Player)
function Api.registerGlobalStepForEachPlayer(timeDelay, callbackFunc)
	table.insert(callsWithDelay, {
		timeDelay    = timeDelay,
		callbackFunc = callbackFunc,
		timer        = 0.0,
		lastCall     = 0.0,
	})
end

core.register_globalstep(function(deltaTime)
	---@type number
	local timer
	local lastCall

	for _, player in ipairs(core.get_connected_players()) do
		for _, callback in ipairs(callsForEachPlayer) do
			timer    = callback.timer
			lastCall = callback.lastCall

			timer    = timer + deltaTime
			lastCall = lastCall + deltaTime

			if timer >= callback.timeDelay then
				callback.callbackFunc(lastCall, player)
				callback.timer    = timer - callback.timeDelay
				callback.lastCall = 0.0
			else
				callback.timer    = timer
				callback.lastCall = lastCall
			end
		end
	end
end)
