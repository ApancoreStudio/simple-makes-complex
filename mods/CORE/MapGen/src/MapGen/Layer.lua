---@class MapGen.Layer
---@field name                        string
---@field minY                        number
---@field maxY                        number
---@field minTemp                     number
---@field maxTemp                     number
---@field minHumidity                 number
---@field maxHumidity                 number
---@field waterLevel                  number
---@field calcTemp                    fun(self:MapGen.Layer, value:number, height:number):number
---@field calcHumidity                fun(self:MapGen.Layer, value:number, height:number):number
---@field peaksList                   {['landscape']:MapGen.Peak[],['temp']:MapGen.Peak[],['humidity']:MapGen.Peak[]}
---@field colorsList                  {['landscape']:table<ColorString, NoiseParams>,['temp']:table<ColorString, NoiseParams>,['humidity']:table<ColorString, NoiseParams>}
---@field biomesByName                table<string, MapGen.Biome>
---@field biomesList                  MapGen.Biome[]
---@field biomesDiagram               table
---@field biomesGorizontalScattering  number
---@field biomesVerticalScattering    number
---@field cavernsByName               table<string, MapGen.Cavern>
---@field cavernsList                 MapGen.Cavern[]
---@field trianglesList               MapGen.Triangle[]
---@field tetrahedronsList            MapGen.Tetrahedron[]
local Layer = {
	peaksList        = {
		landscape = {},
		temp      = {},
		humidity  = {},
	},
	colorsList = {
		landscape = {},
		temp      = {},
		humidity  = {},
	},
	biomesByName     = {},
	biomesList       = {},
	biomesDiagram    = {},
	cavernsByName    = {},
	cavernsList      = {},
	trianglesList    = {},
	tetrahedronsList = {},
}

---Definition table for the `MapGen.Layer`.
---
---**Only for EmmyLua.**
---@class MapGen.LayerDef
---@field minY                        number
---@field maxY                        number
---@field minTemp                     number
---@field maxTemp                     number
---@field minHumidity                 number
---@field maxHumidity                 number
---@field waterLevel?                 number
---@field calcTemp                    (fun(self:MapGen.Layer, value:number, height:number):number)?
---@field calcHumidity                (fun(self:MapGen.Layer, value:number, height:number):number)?
---@field biomesGorizontalScattering  number?
---@field biomesVerticalScattering    number?

---@param self    MapGen.Layer
---@param value   number
---@param height  number
---@return        number
local function defaultCalcFunc(self, value, height)
	return value
end

---@param name  string
---@param def   MapGen.LayerDef
---@return      MapGen.Layer
function Layer:new(name, def)
	if def.calcTemp == nil then
		Logger.infoLog('MapGen.Layer: The `%s` layer does not have a specified `calcTemp()` function. The default function is used.', name)
		def.calcTemp = defaultCalcFunc
	end

	if def.calcHumidity == nil then
		Logger.infoLog('MapGen.Layer: The `%s` layer does not have a specified `calcHumidity()` function. The default function is used.', name)
		def.calcHumidity = defaultCalcFunc
	end

	---@type MapGen.Layer
	local instance = setmetatable({
		name                       = name,
		minY                       = def.minY,
		maxY                       = def.maxY,
		minTemp                    = def.minTemp,
		maxTemp                    = def.maxTemp,
		minHumidity                = def.minHumidity,
		maxHumidity                = def.maxHumidity,
		waterLevel                 = def.waterLevel or 0,
		calcTemp                   = def.calcTemp,
		calcHumidity               = def.calcHumidity,
		biomesGorizontalScattering = def.biomesGorizontalScattering or 0,
		biomesVerticalScattering   = def.biomesVerticalScattering or 0,
	}, {__index = self})

	return instance
end

---Adds a peak to the `Layer.peaksList`
---@param category  'landscape'|'temp'|'humidity'
---@param peak      MapGen.Peak
function Layer:addPeak(category, peak)
	if category == 'landscape' then
		table.insert(self.peaksList.landscape, peak)
	elseif category == 'temp' then
		table.insert(self.peaksList.temp, peak)
	elseif category == 'humidity' then
		table.insert(self.peaksList.humidity, peak)
	else
		error(('There is no peak category named %s.'):format(category))
	end
end

---Adds a color to the `Layer.colorsList`
---@param category  'landscape'|'temp'|'humidity'
---@param color     ColorString
function Layer:addColor(category, color)
	color = core.colorspec_to_colorstring(core.colorspec_to_table(color))

	if category == 'landscape' then
		table.insert(self.colorsList.landscape, color)
	elseif category == 'temp' then
		table.insert(self.colorsList.temp, color)
	elseif category == 'humidity' then
		table.insert(self.colorsList.humidity, color)
	else
		error(('There is no color category named %s.'):format(category))
	end
end

---Adds a biome to the `Layer.biomesByName` & `Layer.biomesList`
---@param biomeName  string
---@param biome      MapGen.Biome
function Layer:addBiome(biomeName, biome)
	self.biomesByName[biomeName] = biome
	table.insert(self.biomesList, biome)
end

---Adds a cavern to the `Layer.cavernsByName` & `Layer.cavernsList`
---@param cavernName  string
---@param cavern      MapGen.Cavern
function Layer:addCavern(cavernName, cavern)
	self.cavernsByName[cavernName] = cavern
	table.insert(self.cavernsList, cavern)
end

---@param height      number
---@param biomesList  MapGen.Biome[]
---@return            string[], MapGen.Biome[]
local function getBiomesNamesByHeight(height, biomesList)
	local biomesNames = {}
	local biomes = {}

	for _, biome in ipairs(biomesList) do
		if height >= biome.minY and height <= biome.maxY then
			table.insert(biomesNames, biome.name)
			table.insert(biomes, biome)
		end
	end

	table.sort(biomesNames)

	return biomesNames, biomes
end

---Initialization of the biome diagram using the Voronoi method.
function Layer:initBiomesDiagram()
	local diagram = self.biomesDiagram
	local pastBiomesNames
	local pastDiagramSlice

	-- A counter for logging unique slices in the biome diagram.
	local uniqueDiagramSlices = 0

	for height = self.minY, self.maxY do
		diagram[height] = {}

		local newBiomesNames, biomes = getBiomesNamesByHeight(height, self.biomesList)

		if pastBiomesNames ~= nil and dump(pastBiomesNames) == dump(newBiomesNames) then
			diagram[height] = pastDiagramSlice

			goto continue
		end

		pastBiomesNames = newBiomesNames
		for temp = self.minTemp, self.maxTemp do
			diagram[height][temp] = {}

			for humidity = self.minHumidity, self.maxHumidity do
				local minDistance = math.huge
				local closestBiome = nil

				---@param biome MapGen.Biome
				for _, biome in ipairs(biomes) do
					local distance = (temp - biome.tempPoint)^2 + (humidity - biome.humidityPoint)^2

					if distance < minDistance then
						minDistance = distance
						closestBiome = biome
					end
				end

				-- If there is no nearby biome for this height...
				if closestBiome == nil then
					-- ... then the first registered biome in the layer will be the default one.
					diagram[height][temp][humidity] = self.biomesList[1]
				else
					diagram[height][temp][humidity] = closestBiome
				end
			end
		end

		pastDiagramSlice = diagram[height]
		uniqueDiagramSlices = uniqueDiagramSlices + 1

		::continue::
	end

	Logger.infoLog('MapGen.Layer.initBiomesDiagram(): Initialized to %s unique slices for the layer `%s` biome diagram.', uniqueDiagramSlices, self.name)
end

return Layer
