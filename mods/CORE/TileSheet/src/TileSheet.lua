local mathRound = math.round

---@class TileSheet
---@field image   string  Name of texture
---@field width   number  Number of tiles in the table horizontally
---@field height  number  Number of tiles in the table vertically
local TileSheet = {}

---@param imagePath  string
---@return           number, number
local function getSizePng(imagePath)
	local file = io.open(imagePath, 'rb')
	if not file then
		error('Cannot open file: ' .. imagePath)
	end

	-- PNG signature check (8 bytes)
	local signature = file:read(8)
	if not signature or signature ~= '\137PNG\r\n\26\n' then
		file:close()
		error('Not a valid PNG file: ' .. imagePath)
	end

	-- Reading the first chunk (must be IHDR)
	local length_data = file:read(4)
	local chunk_type = file:read(4)
	if not length_data or not chunk_type or chunk_type ~= 'IHDR' then
		file:close()
		error('Invalid PNG structure in file: ' .. imagePath)
	end

	-- Reading IHDR data (width and height)
	local width_data = file:read(4)
	local height_data = file:read(4)
	if not width_data or not height_data then
		file:close()
		error('Incomplete PNG header in file:' .. imagePath)
	end

	file:close()

	-- Converting big-endian bytes to numbers
	local width = (string.byte(width_data, 1) * 16777216)
				+ (string.byte(width_data, 2) * 65536)
				+ (string.byte(width_data, 3) * 256)
				+ string.byte(width_data, 4)

	local height = (string.byte(height_data, 1) * 16777216)
				 + (string.byte(height_data, 2) * 65536)
				 + (string.byte(height_data, 3) * 256)
				 + string.byte(height_data, 4)

	return width, height
end

---Returns an instance of the TileSheet class by canvas name and single tile resolution.
---
---Warning: only `.png` images
---@param image       string  Name of texture.
---@param tileWidth   number  Width of one tile
---@param tileHeight  number  Height of one tile
---@return            TileSheet
function TileSheet:new(image, tileWidth, tileHeight)
	local modPath = core.get_modpath(core.get_current_modname())
	-- The canvas image must be in `<mod_name>/textures`, otherwise it will not be retrieved.
	local width, height = getSizePng(modPath .. '/textures/' .. image)

	if width % tileWidth ~= 0 or height % tileHeight ~= 0 then
		error('Tilesheet does not have an integer number of tiles with resolution ' .. tostring(tileWidth) ..' * '.. tostring(tileHeight))
	end

	---@type TileSheet
	local instance = setmetatable({
		image  = image,
		width  = mathRound(width  / tileWidth),
		height = mathRound(height / tileHeight),
	}, {__index = self})

	return instance
end

---Returns the texture from the tilesheet located at coordinates x, y
---@param x  number
---@param y  number
---@return   string
function TileSheet:getTextureName(x, y)
	local textureName = self.image .. '^[sheet:'.. self.width .. 'x' .. self.height .. ':' .. x .. ',' .. y

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