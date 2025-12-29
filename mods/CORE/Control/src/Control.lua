---@class Events.Control
local Control = {}

-- control.on_press
Events.registerEvent('control.on_press')

---@param callbackFunc  fun(player:Player, controlName:string)
function Control.subcribeOnPress(callbackFunc)
	Events.subscribe('control.on_press', callbackFunc)
end


-- control.on_release
Events.registerEvent('control.on_release')

---@param callbackFunc  fun(player:Player, controlName:string, holdTime:number)
function Control.subcribeOnRelease(callbackFunc)
	Events.subscribe('control.on_release', callbackFunc)
end


-- control.on_hold
Events.registerEvent('control.on_hold')

---@param callbackFunc  fun(player:Player, controlName:string, holdTime:number, dtime:number)
function Control.subcribeOnHold(callbackFunc)
	Events.subscribe('control.on_hold', callbackFunc)
end


-- control.on_wield_change
Events.registerEvent('control.on_wield_change')

---@param callbackFunc  fun(player:Player, player_wield_index:number, player_last_wield_index:number)
function Control.subcribeOnWieldChange(callbackFunc)
	Events.subscribe('control.on_wield_change', callbackFunc)
end


-- --- Call events ---

local ControlPressKeys = {
	'up', 'down', 'left', 'right', 'jump', 'aux1', 'sneak', 'dig', 'place', 'zoom'
}

local ControlMovementKeys = {
	'movement_x', 'movement_y'
}

local playersLastControl = {}
local playersControlTimer = {}

core.register_on_joinplayer(function(player, last_login)
	local playerName = player:get_player_name()
	if playerName == nil then
		return
	end

	local nowControl = player:get_player_control()
	if nowControl == nil then
		return
	end

	local controlTimer = {}
	for _, key in ipairs(ControlPressKeys) do
		controlTimer[key] = 0.0
	end

	playersLastControl[playerName]  = nowControl
	playersControlTimer[playerName] = controlTimer
end)

core.register_on_leaveplayer(function(player, timed_out)
	local playerName = player:get_player_name()
	if playerName == nil then
		return
	end

	playersLastControl[playerName]  = nil
	playersControlTimer[playerName] = nil
end)

Api.registerGlobalStepForEachPlayer(0, function(player, deltaTime)
	if player == nil then
		return
	end

	local playerName = player:get_player_name()
	if playerName == nil then
		return
	end

	local lastControl = playersLastControl[playerName]
	if lastControl == nil then
		return
	end

	local controlTimer = playersControlTimer[playerName]
	if controlTimer == nil then
		return
	end

	local nowControl = player:get_player_control()
	if nowControl == nil then
		return
	end

	for _, key in ipairs(ControlPressKeys) do
		local lastPressed = lastControl[key]
		local nowPressed  = nowControl[key]

		-- on_press
		if not lastPressed and nowPressed then
			Events.call('control.on_press', key)

			controlTimer[key] = 0

		-- on_release
		elseif lastPressed and not nowPressed then
			Events.call('control.on_release', key, controlTimer[key])

			controlTimer[key] = 0

		-- on_hold
		elseif lastPressed and nowPressed then
			Events.call('control.on_hold', key, controlTimer[key], deltaTime)

			controlTimer[key] = controlTimer[key] + deltaTime
		end
	end

	--TODO: add player movement callbacks

	--TODO: add mouse movement callbacks on dir

	playersLastControl[playerName]  = nowControl
	playersControlTimer[playerName] = controlTimer
end)

return Control
