---@class Formspec
---@field params  string
---@field elements  string
local Formspec = {}

---@class FormspecDef
---Set the formspec version to a certain number. If not specified, version `10` is assumed.
---@field version?  number
---Define the size of the menu in inventory slots. `fixed_size` is optional, default `true`
---@field size   {x:number, y:number, fixed_size:boolean?}
---Defines the position on the game window of the formspec's anchor point.
---@field position?  {x:number, y:number}
---Defines the location of the anchor point within the formspec.
---@field anchor?  {x:number, y:number}
---Defines how much space is padded around the formspec if the formspec tries to increase
---past the size of the screen and coordinates have to be shrunk.
---@field padding?  {x:number, y:number}
---Disables player:set_formspec_prepend() from applying to this formspec.
---@field noPrepend?  boolean
---When set to true, all following formspec elements will use the new coordinate system.
---@field realCoordinates?  boolean
---When set to false, the formspec will not close when the user tries to close
---it with the Escape key or similar. Default true.
---@field allowClose?  boolean

---@param def  FormspecDef?
function Formspec:new(def)
	if def == nil then
		local instance = setmetatable({}, {__index = self})

		return instance
	end

	local version = ('formspec_version[%s]'):format(def.version or 10)

	local size = ('size[%s,%s,%s]'):format(def.size.x, def.size.y, def.size.fixed_size or true)

	local position
	if def.position ~= nil then
		position = ('position[%s,%s]'):format(def.position.x or 0.5, def.position.y or 0.5)
	else
		position = ''
	end

	local anchor
	if def.anchor ~= nil then
		anchor = ('anchor[%s,%s]'):format(def.anchor.x, def.anchor.y)
	else
		anchor = ''
	end

	local padding
	if def.padding ~= nil then
		padding = ('padding[%s,%s]'):format(def.padding.x, def.padding.y)
	else
		padding = ''
	end

	local noPrepend
	if def.noPrepend == true then
		noPrepend = 'no_prepend[]'
	else
		noPrepend = ''
	end

	local realCoordinates
	if def.realCoordinates ~= nil then
		noPrepend = ('real_coordinates[%s]'):format(def.realCoordinates)

	else
		realCoordinates = ''
	end

	local allowClose = ('allow_close[%s]'):format(def.allowClose or true)

	---@type Formspec
	local instance = setmetatable({
		formspecParams = version..size..position..anchor..padding..noPrepend..realCoordinates..allowClose,
	}, {__index = self})

	return instance
end

---@return  string
function Formspec:getParams()
	return self.params
end

---@return  string
function Formspec:getElements()
	return self.params
end

---@return  string
function Formspec:toString()
	return self:getParams()..self:getElements()
end

---@param element  string
function Formspec:addElement(element)
	self.elements = self.elements..element
end

---@param x          number
---@param y          number
---@param container  Formspec
function Formspec:container(x, y, container)
	local element = ('container[%s,%s]'):format(x, y)..container:getElements()..'container_end[]'

	self:addElement(element)
end

return Formspec