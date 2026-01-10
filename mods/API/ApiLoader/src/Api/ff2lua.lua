-- A method for converting an image with colored dots (pixels) into a Lua table grouped by color.
-- Author: @ssdaniel24 (github)

---Table with color as key and value is table with coordinates of dots. Note: coords begin from 1,1 (not 0,0).
---Example of table:
---```lua
---{
---    'size': { h=256, w=256 },
---    '#fff': { {x=1,y=1}, {x=2,y=2}, ... },
---    '#ff0': { {x=3,y=3}, {x=4,y=4}, ... },
---    ...
---}
---```
---@alias ColoredDotsTable table<string,table>

---@param  uintb string  unsigned int bytes
---@return       number
local function uintb2num(uintb)
	local num = 0
	local len = string.len(uintb)

	for i = 1,len do
		num = num*256 + string.byte(uintb, i)
	end

	return num
end

---Converts (scaling) 16-bit unsigned integer to 8-bit unsigned integer.
---Why? Because hex codes of colors are 8-bit: #ffffff -> ff = 256 (8 bit). Not 65536 (16 bit).
---@param  num number  16-bit number
---@return     number  8-bit number
local function uint16ToUint8(num)
	return math.floor(num / 256)
end

---Converts given farbfeld image to ColoredDotsTable.
---Farbfeld format:
---```
---╔════════╤═════════════════════════════════════════════════════════╗
---║ Bytes  │ Description                                             ║
---╠════════╪═════════════════════════════════════════════════════════╣
---║ 8      │ 'farbfeld'     magic value                              ║
---╟────────┼─────────────────────────────────────────────────────────╢
---║ 4      │ 32-Bit BE unsigned integer (width)                      ║
---╟────────┼─────────────────────────────────────────────────────────╢
---║ 4      │ 32-Bit BE unsigned integer (height)                     ║
---╟────────┼─────────────────────────────────────────────────────────╢
---║ [2222] │ 4x16-Bit BE unsigned integers [RGBA] / pixel, row-major ║
---╚════════╧═════════════════════════════════════════════════════════╝
---```
---[tools/farbfeld | suckless.org software that sucks less](https://tools.suckless.org/farbfeld/)
---@param  filepath         string   image in farbfeld format
---@param  backgroundColor  string?  ColorString, will be ignored while processing image. Default: `#000000FF`
---@return                  ColoredDotsTable
function Api.ff2luat(filepath, backgroundColor)
	local file = io.open(filepath, 'rb')
	if not file then error('Can\'t open farbfeld image: ' .. dump(filepath)) end
	if not file:read(8) == 'farbfeld' then error('Not farbfeld image: ' .. dump(filepath)) end

	if not backgroundColor then backgroundColor = '#000000FF' end
	--HACK: normalizing colorstring for future string comparison ('#000' -> '#000000FF')
	backgroundColor = core.colorspec_to_colorstring(core.colorspec_to_table(backgroundColor))

	---@type ColoredDotsTable
	local dots = { size = { w = uintb2num(file:read(4)), h = uintb2num(file:read(4)) } }

	for i = 1,dots.size.h do
		for j = 1,dots.size.w do
			local color_t = {
				r = uint16ToUint8(uintb2num(file:read(2))),
				g = uint16ToUint8(uintb2num(file:read(2))),
				b = uint16ToUint8(uintb2num(file:read(2))),
				a = uint16ToUint8(uintb2num(file:read(2)))
			}

			---@type string @ColorString
			local color = core.colorspec_to_colorstring(color_t)

			if color ~= backgroundColor then
				if not dots[color] then
					dots[color] = {}
				end

				table.insert(dots[color], { x=j, y=i })
			end
		end
	end

	file:close()

	return dots
end
