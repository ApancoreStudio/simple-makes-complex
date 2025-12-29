---@type {timeDelay:number, callbackFunc:fun(deltaTime:number), timer:number}[]
local callsWithDelay = {}

---@param timeDelay     number
---@param callbackFunc  fun(deltaTime:number)
function Api.registerGlobalStepWithDelay(timeDelay, callbackFunc)
	table.insert(callsWithDelay, {
		timeDelay    = timeDelay,
		callbackFunc = callbackFunc,
		timer        = 0.0
	})
end

core.register_globalstep(function(deltaTime)
	---@type number
	local timer

	for _, callback in ipairs(callsWithDelay) do
		timer = callback.timer
		timer = timer + deltaTime

		if timer >= callback.timeDelay then
			callback.callbackFunc(deltaTime)
			callback.timer = 0.0
		else
			callback.timer = timer
		end
	end
end)

---@type {timeDelay:number, callbackFunc:fun(deltaTime:number, player), timer:number}[]
local callsForEachPlayer = {}

---@param timeDelay     number
---@param callbackFunc  fun(player:Player, deltaTime:number)
function Api.registerGlobalStepForEachPlayer(timeDelay, callbackFunc)
	table.insert(callsWithDelay, {
		timeDelay    = timeDelay,
		callbackFunc = callbackFunc,
		timer        = 0.0
	})
end

core.register_globalstep(function(deltaTime)
	---@type number
	local timer
	for _, player in ipairs(core.get_connected_players()) do
		for _, callback in ipairs(callsForEachPlayer) do
			timer = callback.timer
			timer = timer + deltaTime

			if timer >= callback.timeDelay then
				callback.callbackFunc(deltaTime, player)
				callback.timer = 0.0
			else
				callback.timer = timer
			end
		end
	end
end)