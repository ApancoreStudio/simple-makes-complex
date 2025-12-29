---@class Callbacks.Control
local Control = {}

-- control.on_press
Callbacks.registerCallback('control.on_press')

---@param callbackFunc  fun(player:Player, controlName:string)
function Control.subcribeOnPress(callbackFunc)
	Callbacks.subscribe('control.on_press', callbackFunc)
end


-- control.on_release
Callbacks.registerCallback('control.on_release')

---@param callbackFunc  fun(player:Player, controlName:string, holdTime:number)
function Control.subcribeOnRelease(callbackFunc)
	Callbacks.subscribe('control.on_release', callbackFunc)
end


-- control.on_hold
Callbacks.registerCallback('control.on_hold')

---@param callbackFunc  fun(player:Player, controlName:string, holdTime:number, dtime:number)
function Control.subcribeOnHold(callbackFunc)
	Callbacks.subscribe('control.on_hold', callbackFunc)
end


-- control.on_wield_change
Callbacks.registerCallback('control.on_wield_change')

---@param callbackFunc  fun(player:Player, player_wield_index:number, player_last_wield_index:number)
function Control.subcribeOnWieldChange(callbackFunc)
	Callbacks.subscribe('control.on_wield_change', callbackFunc)
end

local ControlKeys = {
	'up', 'down', 'left', 'right', 'jump', 'aux1', 'sneak', 'dig', 'place', 'zoom'
}

local playersLastControl = {}
local playersControlTimer = {}

--TODO: on_join & on_leave

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

	local control
	for _, key in ipairs(ControlKeys) do
		local lastPressed = lastControl[key]
		local nowPressed  = nowControl[key]

		-- on_press
		if not lastPressed and nowPressed then
			Callbacks.call('control.on_press', key)

			controlTimer[key] = 0

		-- on_release
		elseif lastPressed and not nowPressed then
			Callbacks.call('control.on_release', key, controlTimer[key])

			controlTimer[key] = 0

		-- on_hold
		elseif lastPressed and nowPressed then
			Callbacks.call('control.on_hold', key, controlTimer[key], deltaTime)

			controlTimer[key] = controlTimer[key] + deltaTime
		end
	end

	playersLastControl[playerName] = nowControl
end)

return Control