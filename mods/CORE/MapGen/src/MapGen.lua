local mathAbs,  mathRound,  mathMin,  mathMax,  id
	= math.abs, math.round, math.min, math.max, core.get_content_id

local pastNoise2DCalc = {
	---@type MapGen.Triangle?
	triangle = nil,
	---@type number?
	x        = nil,
	---@type number?
	y        = nil,
	noiseValues = {
		---@type number?
		height   = nil,
		---@type number?
		humidity = nil,
		---@type number?
		temp     = nil,
	}
}

local modInfo = Mod.getInfo('smc__core__map_gen')
local require = modInfo.require

---@type MapGen.Layer
local Layer = require('MapGen.Layer')

---@type MapGen.StaticLayer
local StaticLayer = require('MapGen.StaticLayer')

---@type MapGen.Peak
local Peak = require('MapGen.Peak')

---@type MapGen.Biome
local Biome = require('MapGen.Biome')

---@type MapGen.Triangulation
local Triangulation = require('MapGen.Triangulation')

---@type MapGen.Cavern
local Cavern = require('MapGen.Cavern')

---@class MapGen
---@field layersByName                table<string, MapGen.Layer>
---@field layersList                  MapGen.Layer[]
---@field staticsByName               table<string, MapGen.StaticLayer>
---@field staticsList                 MapGen.StaticLayer[]
---@field peaksMultinoiseInitialized  boolean  Is the fractal noise of the peaks initialized? This is necessary for a one-time noise initialization.
---@field cavernsNoiseInitialized     boolean  Is the fractal noise of the caverns initialized? This is necessary for a one-time noise initialization.
---@field isRunning                   boolean  A static field that guarantees that only one instance of the `MapGen` class will work.
---@field nodeIDs                     table<string, number>
local MapGen = {
	layersByName          = {},
	layersList            = {},
	staticsByName         = {},
	staticsList           = {},
	peaksMultinoiseInitialized = false,
	cavernsNoiseInitialized    = false,
	isRunning                  = false,
}

---Definition table for the `MapGen`.
---
---**Only for EmmyLua.**
---@class MapGenDef
---@field nodes                   table<string, string>

---@param def  MapGenDef
---@return MapGen
function MapGen:new(def)
	local nodesIDs = {}
	-- Converting node names to IDs
	for k, v in pairs(def.nodes) do
		nodesIDs[k] = id(v)
	end

	---@type MapGen
	local instance = setmetatable({
		nodes                  = def.nodes,
		nodeIDs                = nodesIDs,
	}, {__index = self})

	return instance
end

---Determines which layer a node belongs to based on its height coordinate.
---@param yPos  number
---@return      MapGen.Layer?
function MapGen:getLayerByHeight(yPos)
	--- TODO: возможно здесь получится сделать более оптимизированный алгоритм
	--- учитывая тот факт, что эта функция вызывается для каждой ноды в on_generated
	--- и может быть даже не один раз
	--- Можно подумать над тем, чтобы использовать сортированный список

	---@param layer  MapGen.Layer
	for _, layer in  ipairs(self.layersList) do

		if yPos >= layer.minY and yPos <= layer.maxY then
			return layer
		end

	end
end

---Determines which statics layer a node belongs to based on its height coordinate.
---@param yPos  number
---@return      MapGen.StaticLayer?
function MapGen:getStaticByHeight(yPos)
	--- TODO: возможно здесь получится сделать более оптимизированный алгоритм
	--- учитывая тот факт, что эта функция вызывается для каждой ноды в on_generated
	--- и может быть даже не один раз
	--- Можно подумать над тем, чтобы использовать сортированный список

	---@param static  MapGen.StaticLayer
	for _, static in  ipairs(self.staticsList) do

		if yPos >= static.minY and yPos <= static.maxY then
			return static
		end

	end
end



-- --- REGISTRATION METHODS ---

---Mark the world area between two heights as a `MapGen.Layer`.
---
---Note: layers must not overlap.
---@param name  string           The name that will be assigned to the layer. The name must be unique for each layer.
---@param def   MapGen.LayerDef  Layer description table, see details `MapGen.LayerDef`
function MapGen:registerLayer(name, def)
	-- Layers with the same name cannot exist.
	assert(self.layersByName[name] == nil, ('A layer named `%s` is already registered.'):format(name))

	-- Layers cannot overlap.
	assert(self:getLayerByHeight(def.minY) == nil and self:getLayerByHeight(def.maxY) == nil, 'Registered layers must not overlap!')

	---@type MapGen.Layer
	local layer = Layer:new(name, def)

	self.layersByName[name] = layer
	table.insert(self.layersList, layer)

	-- Sort layers by maxY descending for processing priority.
	table.sort(self.layersList, function(a, b)
		return a.maxY > b.maxY
	end)
end

---Mark the world area between two heights as a `MapGen.StaticLayer`.
---
---Note: layers must not overlap.
---@param name  string                     The name that will be assigned to the static layer. The name must be unique for each layer.
---@param def   MapGen.StaticLayerDef  Static layer description table, see details `MapGen.StaticLayerDef`
function MapGen:registerStaticLayer(name, def)
	-- Static layer with the same name cannot exist.
	assert(self.staticsByName[name] == nil, ('A static layer named `%s` is already registered.'):format(name))

	-- Static layers cannot overlap.
	assert(self:getStaticByHeight(def.minY) == nil and self:getLayerByHeight(def.maxY) == nil, 'Registered static layers must not overlap!')

	---@type MapGen.StaticLayer
	local static = StaticLayer:new(name, def)

	self.staticsByName[name] = static
	table.insert(self.staticsList, static)

	-- Sort srtatics by maxY descending for processing priority.
	table.sort(self.staticsList, function(a, b)
		return a.maxY > b.maxY
	end)
end

---Mark a world point as `MapGen.Peak` and assign it a specific noise that will affect the generation.
---
---Note: The peaks shouldn't overlap. This won't cause any errors, but it might ruin the generation.
---@param layerName   string                        The name of the layer in which the new peak will be included.
---@param peakPos     vector                        The coordinate where the peak will be placed.
---@param multinoise  MapGen.Peak.MultinoiseParams  Noise that will be assigned to the peak and that will influence map generation
---@param groups      table<string, number>?        Peak groups that may affect processing.
function MapGen:registerPeak(layerName, peakPos, multinoise, groups)
	---@type MapGen.Layer
	local layer = self.layersByName[layerName]

	assert(layer ~= nil, ('There is no layer named `%s` registered.'):format(layerName))

	if not layer then
		error('Invalid layer: ' .. layerName)
	end

	--TODO: добавить проверку, что координата пиков не совпадают

	---@type MapGen.Peak
	local peak = Peak:new(peakPos, multinoise, groups)

	layer:addPeak(peak)
end

---Mark a world point as `MapGen.Peak` and assign it a specific noise that will affect the generation.
---The Y coordinate will be forced to zero, and the `is2d` group will be added to the groups field.
---
---Note: The peaks shouldn't overlap. This won't cause any errors, but it might ruin the generation.
---@param layerName   string                        The name of the layer in which the new peak will be included.
---@param peakPos     vector                        The coordinate where the peak will be placed.
---@param multinoise  MapGen.Peak.MultinoiseParams  Noise that will be assigned to the peak and that will influence map generation.
---@param groups      table<string, number>?        Peak groups that may affect processing.
function MapGen:register2DPeak(layerName, peakPos, multinoise, groups)
	local _peakPos = table.copy_with_metatables(peakPos)
	_peakPos.y = 0

	if groups == nil then
		groups = {is2d = 1}
	else
		groups.is2d = 1
	end

	self:registerPeak(layerName, _peakPos, multinoise, groups)
end

---Mark the world points as `MapGen.Peak` and assign them all a specific noise that will affect generation.
---The Y coordinate will be forced to zero, and the `is2d` group will be added to the groups field.
---
---Note: The peaks shouldn't overlap. This won't cause any errors, but it might ruin the generation.
---@param layerName   string                        The name of the layer in which the new peaks will be included.
---@param multinoise  MapGen.Peak.MultinoiseParams  The noise that will be assigned to each peak and will affect the map generation.
---@param peakPoses   vector[]                      Set the coordinates where the peaks will be placed.
---@param groups      table<string, number>?        Peak groups that may affect processing.
function MapGen:register2DPeaks(layerName, multinoise, peakPoses, groups)
	for _, peakPos in ipairs(peakPoses) do
		self:register2DPeak(layerName, peakPos, multinoise, groups)
	end
end

---Mark a point on the biomes diagram and constrain the world area by height to mark it as `MapGen.Biome`.
---@param layerName  string           The name of the layer in which the new biome will be included.
---@param biomeName  string           The name to be assigned to the biome. The name must be unique for each biome.
---@param def        MapGen.BiomeDef  Biome description table, see details `MapGen.BiomeDef`
function MapGen:registerBiome(layerName, biomeName, def)
	local layer = self.layersByName[layerName]
	assert(layer ~= nil, ('There is no layer named `%s` registered.'):format(layerName))
	assert(layer.biomesByName[biomeName] == nil, ('A biome named `%s` already exists in the `%s` layer.'):format(biomeName, layerName))

	local biome = Biome:new(biomeName, def)

	layer:addBiome(biomeName, biome)
end

---Mark the world area between two heights as a `MapGen.Cavern` and assign the noise that the cave will be generated from.
---@param layerName       string            The name of the layer in which the new cavern will be included.
---@param cavernName      string            The name to be assigned to the cavern. The name must be unique for each cavern.
---@param def             MapGen.CavernDef  Cavern description table, see details `MapGen.CavernDef`
function MapGen:registerCavern(layerName, cavernName, def)
	local layer = self.layersByName[layerName]
	assert(layer ~= nil, ('There is no layer named `%s` registered.'):format(layerName))
	assert(layer.cavernsByName[cavernName] == nil, ('A cavern named `%s` already exists in the `%s` layer.'):format(cavernName, layerName))

	local cavern = Cavern:new(cavernName, def)

	layer:addCavern(cavernName, cavern)
end



-- --- INITIALIZATION METHODS ---

---Divide all layers into triangles whose vertices are the `Mapgen.Peak` belonging to these layers.
function MapGen:initLayersTriangultaion()
	---@param layer  MapGen.Layer
	for _, layer in ipairs(self.layersList) do
		layer.trianglesList = Triangulation.triangulate(layer.peaksList)
		-- layer.tetrahedronsList  = Triangulation.tetrahedralize(layer.peaksList)
	end
end

---Initialization of the biome diagram using the Voronoi method.
function MapGen:initBiomesDiagram()
	---@param layer  MapGen.Layer
	for _, layer in ipairs(self.layersList) do
		layer:initBiomesDiagram()
	end
end


---Initialize peak's noises. This should be called after the map object is loaded.
function MapGen:initPeaksMultinoise()
	---@param layer  MapGen.Layer
	for _, layer in ipairs(self.layersList) do

		---@param peak MapGen.Peak
		for _, peak in ipairs(layer.peaksList) do
			peak:initMultinoise()
		end

	end

	self.peaksMultinoiseInitialized = true
end

---Initialize caverns's noises. This should be called after the map object is loaded.
function MapGen:initCavernsNoise()
	---@param layer  MapGen.Layer
	for _, layer in ipairs(self.layersList) do

		---@param peak MapGen.Peak
		for _, cavern in ipairs(layer.cavernsList) do
			cavern:initNoise()
		end

	end

	self.cavernsNoiseInitialized = true
end



-- --- GENERATION METHODS ---

---Returns `true` if there is a cavern at the specified coordinates.
---@param layer  MapGen.Layer
---@param x      number
---@param y      number
---@param z      number
---@return       boolean
local function isCavern(layer, x, y, z)
	for _, cavern in ipairs(layer.cavernsList) do
		if cavern:isCavern(x, y, z) then
			return true
		end
	end

	return false
end

---The core logic of world generation. Determines which node type (water, rock, soil, air)
---and which biome will be generated at the specified coordinates.
---@param mapGenerator  MapGen
---@param layer         MapGen.Layer
---@param height        number
---@param temp          number
---@param humidity      number
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local function generateNode(mapGenerator, layer, height, temp, humidity, data, index, x, y, z)
	local ids =  mapGenerator.nodeIDs
	local waterLevel = layer.waterLevel

	-- Creating a rougher biome boundary.
	local scatteringGorizontal = layer.biomesGorizontalScattering or 0
	local scatteringVertical   = layer.biomesVerticalScattering or 0
	local scattTemp     = temp
	local scattHumidity = humidity
	local scattHeight   = y

	if scatteringGorizontal ~= 0 then
		---@diagnostic disable-next-line: param-type-not-match
		scattTemp = scattTemp + math.random(scatteringGorizontal * -1, scatteringGorizontal)
		---@diagnostic disable-next-line: param-type-not-match
		scattHumidity = scattHumidity + math.random(scatteringGorizontal * -1, scatteringGorizontal)
	end

	if scatteringVertical ~= 0 then
		---@diagnostic disable-next-line: param-type-not-match
		scattHeight = scattHeight + math.random(scatteringVertical * -1, scatteringVertical)
	end

	scattTemp     = math.clamp(scattTemp, layer.minTemp, layer.maxTemp)
	scattHumidity = math.clamp(scattHumidity, layer.minHumidity, layer.maxHumidity)
	scattHeight   = math.clamp(scattHeight, layer.minY, layer.maxY)

	scattHeight, scattTemp, scattHumidity = mathRound(scattHeight), mathRound(scattTemp), mathRound(scattHumidity)
	height, temp, humidity = mathRound(height), mathRound(scattTemp), mathRound(scattHumidity)

	---@type MapGen.Biome
	local biome = layer.biomesDiagram[scattHeight][scattTemp][scattHumidity]

	-- If the block is above surface height and above water level...
	if y > height and y > waterLevel then
		-- ... then airspace is generated.
		biome:generateAir(mapGenerator, data, index, x, y, z)

	-- If the block is above the surface height BUT below the water level...
	elseif y > height and y <= waterLevel then
		-- ... then underwater space is generated.
		biome:generateWater(mapGenerator, data, index, x, y, z)

	-- If the block is below the surface height...
	elseif y <= height then
		-- ... and a cavern is generated in the block...
		if isCavern(layer, x, y, z) then
			-- ... then airspace is generated.
			biome:generateCavernAir(mapGenerator, data, index, x, y, z)

		-- ... or if the surface height is above the water level...
		elseif height > waterLevel then
			--- ... and the height of the block is equal to the height of the surface...
			if y == height then
				-- ... then turf is generated.
				biome:generateTurf(mapGenerator, data, index, x, y, z)
			-- ... or if the height of the block falls within the thickness of the soil layer...
			elseif y > height - biome.soilHeight then
				-- ... then soil is generated.
				biome:generateSoil(mapGenerator, data, index, x, y, z)
			else
				-- ... else e a stone is generated.
				biome:generateRock(mapGenerator, data, index, x, y, z)
			end

		-- ... or if the surface height is below the water level...
		elseif height <= waterLevel then
			-- ... and if the height of the block falls within the thickness of the soil layer...
			if y > height - biome.soilHeight then
				-- ... then the river/ocean bottom is generated.
				biome:generateBottom(mapGenerator, data, index, x, y, z)
			else
				-- ... else a stone is generated.
				biome:generateRock(mapGenerator, data, index, x, y, z)
			end
		end
	else
		data[index] = ids.air

		Logger.warningLog('If you see this error, it means that the map generator does'..
			'not handle all cases of generation on coordinates: %s, %s, %s.', x, y, z)
	end
end

---Calculates a weight for a coordinate using the projection onto
---the triangle's height and specifying the distance to the peak
---for which the weight is calculated.
---@param height  MapGen.Triangulation.Edge
---@param x       number
---@param y       number
---@param z       number
---@return        number
local function calcWeight(height, x, y, z)
	local pos1 = vector.new(x, y, z)
	local pos2 = height.p1:getPeakPos()
	local pos3 = height.p2:getPeakPos()

	local v = pos3 - pos2
	---@type vector
	local w = pos1 - pos2

	-- Formula: (w * v) / (v * v)
	-- When * the dot product.
	local t = w:dot(v) / v:dot(v)

	local posP = pos2 + v * t

	return 1 - vector.distance(pos2, posP) / height:length()
end

---Returns `true` if the point is within the triangle's region.
---The barycentric coordinate method is used.
---@param px        number
---@param pz        number
---@param triangle  MapGen.Triangle
local function pointInTriangle(px, pz, triangle)
	local posP = vector.new(px, 0, pz)
	local pos1 = triangle.p1.getPeakPos()
	local pos2 = triangle.p2.getPeakPos()
	local pos3 = triangle.p3.getPeakPos()

	local v0 = pos3 - pos1
	local v1 = pos2 - pos1
	local v2 = posP - pos1

	local dot00 = vector.dot(v0, v0)
	local dot01 = vector.dot(v0, v1)
	local dot02 = vector.dot(v0, v2)
	local dot11 = vector.dot(v1, v1)
	local dot12 = vector.dot(v1, v2)

	local invDenom = 1 / (dot00 * dot11 - dot01 * dot01)
	local u = (dot11 * dot02 - dot01 * dot12) * invDenom
	local v = (dot00 * dot12 - dot01 * dot02) * invDenom

	return (u >= 0) and (v >= 0) and (u + v <= 1)
end

---Returns the weighted values of 2d noises.
---@param triangle  MapGen.Triangle
---@param x         number
---@param y         number
---@param z         number
---@return          number, number, number
local function calcNoises2dValues(triangle, x, y, z)
	local peak1 = triangle.p1
	local peak2 = triangle.p2
	local peak3 = triangle.p3

	local noiseHeightValue   = 0.0
	local noiseTempValue     = 0.0
	local noiseHumidityValue = 0.0

	local totalWeight = 0.0

	-- We calculate the noise value using the smoothing formula:
	-- ( peak1 * weight1 + peak2 * weight2 + peak3 * weight3) / totalWeight, when
	-- totalWeight = weight1 + weight2 + weight3
	local weight = calcWeight(triangle.h1, x, y, z)
	noiseHeightValue   = noiseHeightValue   + peak1:getMultinoise().landscapeNoise:get_2d({x = x, y = z}) * weight
	noiseTempValue     = noiseTempValue     + peak1:getMultinoise().tempNoise:get_2d({x = x, y = z})      * weight
	noiseHumidityValue = noiseHumidityValue + peak1:getMultinoise().humidityNoise:get_2d({x = x, y = z})  * weight
	totalWeight = totalWeight + weight

	weight = calcWeight(triangle.h2, x, y, z)
	noiseHeightValue   = noiseHeightValue   + peak2:getMultinoise().landscapeNoise:get_2d({x = x, y = z}) * weight
	noiseTempValue     = noiseTempValue     + peak2:getMultinoise().tempNoise:get_2d({x = x, y = z})      * weight
	noiseHumidityValue = noiseHumidityValue + peak2:getMultinoise().humidityNoise:get_2d({x = x, y = z})  * weight
	totalWeight = totalWeight + weight

	weight = calcWeight(triangle.h3, x, y, z)
	noiseHeightValue   = noiseHeightValue   + peak3:getMultinoise().landscapeNoise:get_2d({x = x, y = z}) * weight
	noiseTempValue     = noiseTempValue     + peak3:getMultinoise().tempNoise:get_2d({x = x, y = z})      * weight
	noiseHumidityValue = noiseHumidityValue + peak3:getMultinoise().humidityNoise:get_2d({x = x, y = z})  * weight
	totalWeight = totalWeight + weight

	return noiseHeightValue / totalWeight, noiseTempValue / totalWeight, noiseHumidityValue / totalWeight
end

---Calculates a smoothed 2D noise value based on a preliminary space partitioning.
---
---Returns `nil` if the point is not included in any triangle.
---@param layer  MapGen.Layer
---@param x      number
---@param y      number
---@param z      number
---@return       number?, number?, number?
function MapGen:getNoises2dValues(layer, x, y, z)
	if (pastNoise2DCalc.x ~= nil and pastNoise2DCalc.z ~= nil) and (x == pastNoise2DCalc.x and z == pastNoise2DCalc.z) then
		return pastNoise2DCalc.noiseValues.height, pastNoise2DCalc.noiseValues.temp, pastNoise2DCalc.noiseValues.humidity
	end

	if pastNoise2DCalc.triangle ~= nil and pointInTriangle(x, z, pastNoise2DCalc.triangle) then
		local noiseHeightValue, noiseTempValue, noiseHumidityValue = calcNoises2dValues(pastNoise2DCalc.triangle, x, y, z)

		noiseTempValue, noiseHumidityValue = layer:calcTemp(noiseTempValue, y), layer:calcHumidity(noiseHumidityValue, y)

		pastNoise2DCalc.x = x
		pastNoise2DCalc.z = z
		pastNoise2DCalc.noiseValues = {
			height   = noiseHeightValue,
			temp     = noiseTempValue,
			humidity = noiseHumidityValue,
		}

		return noiseHeightValue, noiseTempValue, noiseHumidityValue
	end

	---@param triangle  MapGen.Triangle
	for _, triangle in ipairs(layer.trianglesList) do
		if pointInTriangle(x, z,triangle) then
			local noiseHeightValue, noiseTempValue, noiseHumidityValue = calcNoises2dValues(triangle, x, y, z)

			noiseTempValue, noiseHumidityValue = layer:calcTemp(noiseTempValue, y), layer:calcHumidity(noiseHumidityValue, y)

			pastNoise2DCalc.triangle = triangle
			pastNoise2DCalc.x = x
			pastNoise2DCalc.z = z
			pastNoise2DCalc.noiseValues = {
				height   = noiseHeightValue,
				temp     = noiseTempValue,
				humidity = noiseHumidityValue,
			}

			return noiseHeightValue, noiseTempValue, noiseHumidityValue
		end
	end

	-- If the point does not fall within the triangle, it is impossible to calculate the height.
	-- For debugging purposes only, may slow down generation:
	--core.log('warning', string.format('The point %s %s %s does not fall within any triangle, calculating the noise value is impossible.', tostring(x), tostring(y), tostring(z)))
end

--[[
3D noise smoothing is too slow, so it was decided to stop using it.

---@param P vector
---@param A vector
---@param B vector
---@param C vector
local function pointInTetrahedron(P, A, B, C, D)
	local function det3(a, b, c)
		return a.x * (b.y * c.z - b.z * c.y)
			 - a.y * (b.x * c.z - b.z * c.x)
			 + a.z * (b.x * c.y - b.y * c.x)
	end

	local v0 = B - A
	local v1 = C - A
	local v2 = D - A
	local v3 = P - A

	local d = det3(v0, v1, v2)

	local u = det3(v3, v1, v2) / d
	local v = det3(v0, v3, v2) / d
	local w = det3(v0, v1, v3) / d

	return (u >= 0 and v >= 0 and w >= 0 and (u + v + w) <= 1)
end

---Calculates a smoothed 3D noise value based on a preliminary space partitioning.
---
---Returns `nil` if the point is not included in any tetrahedron.
---
---@param layer     MapGen.Layer
---@param x         number
---@param y         number
---@param z         number
---@return          number?
function MapGen:getNoises3dValues(layer, x, y, z)
	---@param triangle  MapGen.Tetrahedron
	for _, tetrahedron in ipairs(layer.tetrahedronsList) do
		local peak1 = tetrahedron.p1
		local peak2 = tetrahedron.p2
		local peak3 = tetrahedron.p3
		local peak4 = tetrahedron.p4

		local pos1 = peak1:getPeakPos()
		local pos2 = peak2:getPeakPos()
		local pos3 = peak3:getPeakPos()
		local pos4 = peak4:getPeakPos()

		-- If the point is in the tetrahedron defined by the `MapGen.Peak`...
		if pointInTetrahedron(
			vector.new(x, y, z),
			pos1,
			pos2,
			pos3,
			pos4
		)
		then
			local noiseValue = 0.0

			local totalWeight = 0.0

			-- ... we calculate the height for this point using smoothing.
			local weight = calcWeight(tetrahedron.h1, x, y, z)
			noiseValue = noiseValue + peak1:getMultinoise().someNoise:get_3d({x = x, y = y, z = z}) * weight
			totalWeight = totalWeight + weight

			weight = calcWeight(tetrahedron.h2, x, y, z)
			noiseValue = noiseValue + peak1:getMultinoise().someNoise:get_3d({x = x, y = y, z = z}) * weight
			totalWeight = totalWeight + weight

			weight = calcWeight(tetrahedron.h3, x, y, z)
			noiseValue = noiseValue + peak2:getMultinoise().someNoise:get_3d({x = x, y = y, z = z}) * weight
			totalWeight = totalWeight + weight

			weight = calcWeight(tetrahedron.h4, x, y, z)
			noiseValue = noiseValue + peak3:getMultinoise().someNoise:get_2d({x = x, y = y, z = z}) * weight
			totalWeight = totalWeight + weight

			return mathRound(noiseValue / totalWeight)
		end
	end

	-- If the point does not fall within the tetrahedron, it is impossible to calculate the height.
	-- For debugging purposes only, may slow down generation:
	-- core.log('warning', string.format('The point %s %s %s does not fall within any tetrahedron, calculating the noise value is impossible.', tostring(x), tostring(y), tostring(z)))
end
--]]

---Generator handler for specific coordinates.
---@param mapGenerator  MapGen
---@param data          number[]
---@param index         number
---@param x             number
---@param y             number
---@param z             number
local function generatorHandler(mapGenerator, data, index, x, y, z)
	-- If the node belongs to a static layer, then a static node is generated.
	local static = mapGenerator:getStaticByHeight(y)
	if static ~= nil then
		static:generateStaticNode(mapGenerator, data, index, x, y, z)

		return
	end

	-- If generation occurs outside the layers, then a void is generated.
	local layer = mapGenerator:getLayerByHeight(y)
	if layer == nil then
		data[index] = mapGenerator.nodeIDs.air

		return
	end

	-- Calculating landscape height
	local noiseHeightValue, noiseTempValue, noiseHumidityValue = mapGenerator:getNoises2dValues(layer, x, y, z)

	-- If the height of the landscape is `nil`,
	-- then the point does not fall within any of the triangles.
	if noiseHeightValue == nil then
		noiseHeightValue   = 0.0
		noiseTempValue     = 0.0
		noiseHumidityValue = 0.0
	end

	---@diagnostic disable-next-line: param-type-not-match
	generateNode(mapGenerator, layer,  noiseHeightValue, noiseTempValue, noiseHumidityValue, data, index, x, y, z)
end

---Chunk generation handler.
---@param voxelManip  VoxelManip
---@param minPos      table
---@param maxPos      table
---@param blockseed   number
function MapGen:onMapGenerated(voxelManip, minPos, maxPos, blockseed)
	-- We obtain a generation area for further manipulations
	--local voxelManip, eMin, eMax = core.get_mapgen_object('voxelmanip')

	local eMin, eMax = voxelManip:get_emerged_area()

	if not self.peaksMultinoiseInitialized then
		self:initPeaksMultinoise()
	end

	if not self.cavernsNoiseInitialized then
		self:initCavernsNoise()
	end

	local data = voxelManip:get_data()
	-- local param2_data = voxelManip:get_param2_data()
	local area = VoxelArea:new({MinEdge = eMin, MaxEdge = eMax})

	local index
	-- Initial generation: landscape
	for z = minPos.z, maxPos.z do
		for x = minPos.x, maxPos.x do
			for y = minPos.y, maxPos.y do
				index = area:index(x, y, z)

				if data[index] == core.CONTENT_AIR then
					generatorHandler(self, data, index, x, y, z)
				end
			end
		end
	end

	-- We make changes back to LVM and recalculate light & liquids
	voxelManip:set_data(data)

	core.generate_ores(voxelManip, minPos, maxPos)
	core.generate_decorations(voxelManip, minPos, maxPos)

	--voxelManip:set_param2_data()
	voxelManip:set_lighting({ day = 14, night = 0})
	voxelManip:calc_lighting()
	voxelManip:update_liquids()

	--voxelManip:write_to_map() -- Async edit
end



-- --- OTHER ---

---Run world generation through this mapgen object
---
---Note: only one instance of a `MapGen` class can be running.
---
---**FOR MAPGEN ENVIRONMENT ONLY**
function MapGen:run()
	if MapGen.isRunning then
		error('Only one instance of a `MapGen` class can be running.')
	end

	core.register_on_generated(function(...)
		self:onMapGenerated(...)
	end)

	self:initBiomesDiagram()
	self:initLayersTriangultaion()

	MapGen.isRunning = true
end

return MapGen
