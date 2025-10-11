local OBJLoader = {}

function OBJLoader:load(filename)
	local file = io.open(filename, "r")
	if not file then error("Cannot open OBJ file: " .. filename) end
	
	local vertices = {}
	local faces = {}

	for line in file:lines() do
		line = tostring(line) -- to make EmmyLua shut up

		if line:sub(1, 2) == "v " then
			local x, y, z = line:match("v (%S+) (%S+) (%S+)")
			---@diagnostic disable-next-line: param-type-not-match -- TODO: tell alek to fix his ide-helper's vector.new annotation
			table.insert(vertices, vector.new(tonumber(x), tonumber(y), tonumber(z)))
		elseif line:sub(1, 2) == "f " then
			local faceVertices = {}
			for vertex in line:gmatch("%S+") do
				if vertex ~= "f" then
					local index = tonumber(vertex:match("(%d+)"))
					table.insert(faceVertices, index)
				end
			end
			table.insert(faces, faceVertices)
		end
	end
	
	file:close()

	---@diagnostic disable-next-line: need-check-nil -- TODO: idk wtf to do but something has to be done
	local polyhedron = Core.Polyhedron.Class:new(vertices, faces)

	return polyhedron
end

return OBJLoader
