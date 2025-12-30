-- --- MapGen definiton ---
local id = core.get_content_id

local mathRound = math.round

local mapGenRequire = Mod.getInfo('smc__core__map_gen').require

---@type MapGen
local MapGen = mapGenRequire('MapGen')

---@type MapGen
	local mapGenerator = MapGen:new({
	nodes = {
		-- Special nodes
		air = 'air',

		-- Rocks
		sylite    = 'rocks:sylite',
		tauitite  = 'rocks:tauitite',
		iyellite  = 'rocks:iyellite',
		falmyte   = 'rocks:falmyte',
		hapcoryte = 'rocks:hapcoryte',
		burcite   = 'rocks:burcite',
		felhor    = 'rocks:felhor',
		malachite = 'rocks:malachite',

		-- Liquids
		water = 'liquids:water_source',
	},
})

local function calcTemp(layer, value, height)
	return value
end

local function calcHumidity(layer, value, height)
	return value
end

mapGenerator:registerLayer('midgard', {
	minY         = -256,
	maxY         = 256,
	minTemp      = -100,
	maxTemp      = 100,
	minHumidity  = 0,
	maxHumidity  = 100,
	calcTemp     = calcTemp,
	calcHumidity = calcHumidity,
	biomesVerticalScattering   = 5,
	biomesGorizontalScattering = 5
})

local land1 = {
	offset = -20,
	scale = 5,
	spread = {x = 10, y = 10, z = 10},
	seed = 47,
	octaves = 3,
	persistence = 0.4,
	lacunarity = 2,
}

local land2 = {
	offset = 20,
	scale = 5,
	spread = {x = 10, y = 10, z = 10},
	seed = 47,
	octaves = 3,
	persistence = 0.4,
	lacunarity = 2,
}

local climat1 = {
	offset = 80,
	scale = 10,
	spread = {x = 10, y = 10, z = 10},
	seed = 47,
	octaves = 8,
	persistence = 0.6,
	lacunarity = 2,
}

local climat2 = {
	offset = 30,
	scale = 10,
	spread = {x = 10, y = 10, z = 10},
	seed = 47,
	octaves = 8,
	persistence = 0.6,
	lacunarity = 2,
}

local climat0 = {
	offset = 50,
	scale = 0,
	spread = {x = 10, y = 10, z = 10},
	seed = 47,
	octaves = 8,
	persistence = 0.4,
	lacunarity = 2,
}

local v = vector.new

mapGenerator:register2DPeaks('midgard',
{
	landscapeNoise = land1,
	tempNoise      = climat2,
	humidityNoise  = climat2,
},{
	v(500, 0, 500),
	v(-500, 0, -500),
	v(-500, 0, 500),
	v(500, 0, -500),
})

mapGenerator:register2DPeaks('midgard',
{
	landscapeNoise = land2,
	tempNoise      = climat1,
	humidityNoise  = climat1,
},{
	v(-300, 0, 300),
	v(200, 0, -400),
})

mapGenerator:register2DPeaks('midgard',
{
	landscapeNoise = land2,
	tempNoise      = climat2,
	humidityNoise  = climat2,
},{
	v(200, 0, 100),
	v(-300, 0, -200),
})

mapGenerator:registerCavern('midgard', 'cavern1', {
	minY = -48,
	maxY = 0,
	smoothDistance = 20,
	threshold = 0.3,
	noiseParams ={
		offset = 0,
		scale = 1,
		spread = {x = 25, y = 25, z = 25},
		seed = 5934,
		octaves = 3,
		persistence = 0.5,
		lacunarity = 2.0
	},
})

-- --- Biomes ---

---@type ValueNoise
local rocksNoise

---@type NoiseParams
local rocksNoiseParams ={
	offset = 4,
	scale = 2,
	spread = {x = 30, y = 30, z = 30},
	seed = 47,
	octaves = 3,
	persistence = 0.5,
	lacunarity = 4,
}

local function generateRock(biome, mapGenerator, data, index, x, y, z)
	local ids =  mapGenerator.nodeIDs

	if rocksNoise == nil then
		rocksNoise = core.get_value_noise(rocksNoiseParams)
	end

	local noiseRocksValue = mathRound(rocksNoise:get_3d({x = x, y = y, z = z}))
	if     noiseRocksValue == 1 then
		data[index] = ids.malachite
	elseif noiseRocksValue == 2 then
		data[index] = ids.hapcoryte
	elseif noiseRocksValue == 3 then
		data[index] = ids.iyellite
	elseif noiseRocksValue == 4 then
		data[index] = ids.sylite
	elseif noiseRocksValue == 5 then
		data[index] = ids.tauitite
	elseif noiseRocksValue == 6 then
		data[index] = ids.falmyte
	elseif noiseRocksValue == 7 then
		data[index] = ids.burcite
	elseif noiseRocksValue == 8 then
		data[index] = ids.felhor
	end
end

---@param biome MapGen.Biome
local function generateSoil(biome, mapGenerator, data, index, x, y, z)
	data[index] = biome.groundNodesIDs.turf
end

mapGenerator:registerBiome('midgard', 'swamp', {
	tempPoint = 0,
	humidityPoint = 80,
	minY = 100,
	maxY = 0,
	groundNodes = {
		soil   = 'soils:rocky_soil_baren',
		turf   = 'soils:turf_swamp',
		rock   = 'rocks:sylite',
		bottom = 'soils:rocky_soil_baren',
	},
	soilHeight = 3,
	generateRock = generateRock,
	--generateSoil = generateSoil,
})

return mapGenerator