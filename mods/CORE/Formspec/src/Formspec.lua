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
---@return     Formspec
function Formspec:new(def)
	if def == nil then
		local instance = setmetatable({}, {__index = self})

		return instance
	end

	local version = ('formspec_version[%s]'):format( def.version or 10) -- formspec version 10 (5.13.0)

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

---TODO: описание
---@return  string
function Formspec:getParams()
	return self.params
end

---TODO: описание
---@return  string
function Formspec:getElements()
	return self.params
end

---TODO: описание
---@return  string
function Formspec:toString()
	return self:getParams()..self:getElements()
end

---TODO: описание
---@param element  string
function Formspec:addElement(element)
	self.elements = self.elements..element
end

---TODO: описание
---@param x          number
---@param y          number
---@param container  Formspec
function Formspec:container(x, y, container)
	local element = ('container[%s,%s]'):format(x, y)..container:getElements()..'container_end[]'

	self:addElement(element)
end

---TODO
function Formspec:scrollContainer(x, y, container)
	--local element = ('container[%s,%s]'):format(x, y)..container:getElements()..'container_end[]'

	--self:addElement(element)
end

---@alias Formspec.ListDef {inventoryLocation:string, listName:string, x:number, y:number, w:number, h:number,startingItemIndex:number}

---@param inventoryLocation  string
---@param listName           string
---@param x                  number
---@param y                  number
---@param w                  number  Are in inventory slots, not in coordinates.
---@param h                  number  Are in inventory slots, not in coordinates.
---@param startingItemIndex  number?
function Formspec:list(inventoryLocation, listName, x, y, w, h,startingItemIndex)
	if startingItemIndex == nil then
		startingItemIndex = 0
	end

	local element = ('list[%s;%s;%s,%s;%s,%s;%s]'):format(
		inventoryLocation, listName, x, y, w, h,startingItemIndex)

	self:addElement(element)
end

---TODO: немного отличается от листринга луанти, так что надо дописать подробности
---@param lists  [string, string][]?  List of looping lists in the format `[inventory location, list name]`
function Formspec:listring(lists)
	if lists == nil then
		self:addElement('listring[]')
	end

	local element = ''

	for list in lists do
		element = element..('listring[%s;%s]'):format(list[1], list[2])
	end

	self:addElement(element)
end

---The following descriptions are allowed:
--- * `listcolors[<slot_bg_normal>;<slot_bg_hover>]`
--- * `listcolors[<slot_bg_normal>;<slot_bg_hover>;<slot_border>]`
--- * `listcolors[<slot_bg_normal>;<slot_bg_hover>;<slot_border>;<tooltip_bgcolor>;<tooltip_fontcolor>]`
---@param slotBackgroundNormal  ColorString
---@param slotBackgroundHover   ColorString
---@param slotBorder            ColorString?
---@param tooltipBgcolor        ColorString?
---@param tooltipFontcolor      ColorString?
function Formspec:listColors(slotBackgroundNormal, slotBackgroundHover, slotBorder, tooltipBgcolor, tooltipFontcolor)
	local element

	if tooltipBgcolor ~= nil and tooltipFontcolor ~= nil then
		element = ('listcolors[%s;%s;%s;%s;%s]'):format(
			slotBackgroundNormal, slotBackgroundHover, slotBorder, tooltipBgcolor, tooltipFontcolor)
	elseif slotBorder ~= nil then
		element = ('listcolors[%s;%s;%s]'):format(
			slotBackgroundNormal, slotBackgroundHover, slotBorder)
	else
		element = ('listcolors[%s;%s]'):format(
			slotBackgroundNormal, slotBackgroundHover)
	end

	self:addElement(element)
end

---Adds tooltip for an element.
---@param elementName  string
---@param tooltipText  string
---@param bgcolor      ColorString?
---@param fontcolor    ColorString?
function Formspec:tooltipForElement(elementName, tooltipText, bgcolor, fontcolor)
	local element = ('tooltip[%s;%s;%s;%s]'):format(
		elementName, tooltipText, bgcolor or '', fontcolor or '')

	self:addElement(element)
end

---Adds tooltip for an area. Other tooltips will take priority when present.
---@param x            number
---@param y            number
---@param w            number
---@param h            number
---@param tooltipText  string
---@param bgcolor      ColorString?
---@param fontcolor    ColorString?
function Formspec:tooltipForArea(x, y, w, h, tooltipText, bgcolor, fontcolor)
	local element = ('tooltip[%s,%s;%s,%s;%s;%s;%s]'):format(
		x, y, w, h, tooltipText, bgcolor or '', fontcolor or '')

	self:addElement(element)
end

---Show an image.
---@param x            number
---@param y            number
---@param w            number
---@param h            number
---@param textureName  string
---@param middle       boolean?  Makes the image render in 9-sliced mode and defines the middle rect.
function Formspec:image(x, y, w, h, textureName, middle)
	local element = ('image[%s,%s;%s,%s;%s;%s]'):format(
		x, y, w, h, textureName, middle or '')

	self:addElement(element)
end

---Show an animated image. The image is drawn like a "vertical_frames" tile animation
---(See Tile animation definition), but uses a frame count/duration for simplicity.
---@param x            number
---@param y            number
---@param w            number
---@param h            number
---@param textureName  string
---@param frameCount   number
---@param frameDuration  number
---@param frameStart   number
---@param middle       boolean?  Makes the image render in 9-sliced mode and defines the middle rect.
function Formspec:animatedImage(x, y, w, h, textureName, frameCount, frameDuration, frameStart, middle)
	if middle == nil then
		middle = false
	end

	local element = ('animated_image[%s,%s;%s,%s;%s;%s;%s;%s;%s;%s]'):format(
		x, y, w, h, textureName, frameCount, frameDuration, frameStart, middle)

	self:addElement(element)
end

---Show a mesh model.
---@param x               number
---@param y               number
---@param w               number
---@param h               number
---@param name            string    Element name that can be used for styling
---@param mesh            string    The mesh model to use.
---@param textures        string    The mesh textures to use according to the mesh materials. Texture names must be separated by commas.
---@param rotation        number?   Initial rotation of the camera, format x,y. The axes are euler angles in degrees.
---@param continuous      boolean?  Whether the rotation is continuous. Default `false`.
---@param mouseControl    boolean?  Whether the model can be controlled with the mouse. Default `true`.
---@param frameLoopRange  string?   Range of the animation frames. Defaults to the full range of all available frames. Syntax: `<begin>,<end>`.
---@param animationSpeed  number?   Sets the animation speed. Default 0 FPS.
function Formspec:model(x, y, w, h, name, mesh, textures, rotation, continuous, mouseControl, frameLoopRange, animationSpeed)
	local element = ('model[%s,%s;%s,%s;%s;%s;%s;%s;%s;%s;%s;%s]'):format(
		x, y, w, h, name, mesh, textures, rotation or '', continuous or '', mouseControl or '', frameLoopRange or '', animationSpeed or '')

	self:addElement(element)
end

---Show an inventory image of registered item/node.
---@param x         number
---@param y         number
---@param w         number
---@param h         number
---@param itemName  string
function Formspec:itemImage(x, y, w, h, itemName)
	local element = ('item_image[%s,%s;%s,%s;%s]'):format(
		x, y, w, h, itemName)

	self:addElement(element)
end

---Sets background color of formspec.
---
---`fullscreen`:
--- * `false`: Only the non-fullscreen background color is drawn. (default)
--- * `true`: Only the fullscreen background color is drawn.
--- * `both`: The non-fullscreen and the fullscreen background color are drawn.
--- * `neither`: No background color is drawn.
---@param bgcolor     ColorString   Define the color of the non-fullscreen and the fullscreen background.
---@param fullscreen  'false'|'true'|'both'|'neither'
---@param fbgcolor     ColorString?  Define the color of the non-fullscreen and the fullscreen background.
function Formspec:bgcolor(bgcolor, fullscreen, fbgcolor)
	local element = ('bgcolor[%s;%s;%s]'):format(
		bgcolor, fullscreen or '', fbgcolor or '')

	self:addElement(element)
end

---Example for formspec 8x4 in 16x resolution: image shall be sized 8 times 16px times 4 times 16px.
---@param x            number
---@param y            number
---@param w            number
---@param h            number
---@param textureName  string
---@param autoClip     boolean?  If is `true`, the background is clipped
---to the formspec size (x and y are used as offset values, w and h are ignored)
function Formspec:background(x, y, w, h, textureName, autoClip)
	local element

	if autoClip ~= nil then
		element = ('background[%s,%s;%s,%s;%s;%s]'):format(
		x, y, w, h, textureName, autoClip)
	else
		element = ('background[%s,%s;%s,%s;%s]'):format(
			x, y, w, h, textureName)
	end

	self:addElement(element)
end

---TODO
function Formspec:background9()

end

---TODO
function Formspec:pwdfield()

end

---TODO
function Formspec:field()

end

---TODO
function Formspec:fieldCloseOnEnter()

end

---TODO
function Formspec:textArea()

end

---TODO
function Formspec:label()

end

---TODO
function Formspec:hypertext()

end

---TODO
function Formspec:vertlabel()

end

---TODO
function Formspec:button()

end

---TODO
function Formspec:buttonUrl()

end

---TODO
function Formspec:imageButton()

end

---TODO
function Formspec:itemImageButton()

end

---TODO
function Formspec:buttonExit()

end

---TODO
function Formspec:buttonUrlExit()

end

---TODO
function Formspec:imageButtonExit()

end

---TODO
function Formspec:textlist()

end

---TODO
function Formspec:tabheader()

end

---TODO
function Formspec:box()

end

---TODO
function Formspec:dropdown()

end

---TODO
function Formspec:checkbox()

end

---TODO
function Formspec:scrollbar()

end

---TODO
function Formspec:scrollbarOptions()

end

---TODO
function Formspec:table()

end

---TODO
function Formspec:tableOptions()

end

---TODO
function Formspec:tablecolumns()

end

---TODO
function Formspec:style()

end

---TODO
function Formspec:style_type()

end

---TODO
function Formspec:set_focus()

end


return Formspec

