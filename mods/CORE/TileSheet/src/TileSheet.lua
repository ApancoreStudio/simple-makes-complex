---@class TileSheet
---@field image   string  Name of texture
---@field width   number  Number of tiles in the table horizontally
---@field height  number  Number of tiles in the table vertically
local TileSheet = {}

---@param image   string  Name of texture
---@param width   number  Number of tiles in the table horizontally
---@param height  number  Number of tiles in the table vertically
---@return        TileSheet
function TileSheet:new(image, width, height)
	---@type TileSheet
	local instance = setmetatable({
		image = image,
		width = width,
		height = height,
	}, {__index = self})

	-- TODO возможно будет лучше сделать автоматическое определение высоты и ширины по разрешению текстуры

	return instance
end

---Returns the texture from the tilesheet located at coordinates x, y
---@param x  number
---@param y  number
---@return   string
function TileSheet:getTextureName(x, y)
	local textureName = self.image .. "^[sheet:".. self.width .. "x" .. self.height .. ":" .. x .. "," .. y

	return textureName
end

---Alias for `TileSheet:getTextureName`.
---@param x  number
---@param y  number
---@return   string
function TileSheet:t(x, y)
	return self:getTextureName(x, y)
end

return TileSheet