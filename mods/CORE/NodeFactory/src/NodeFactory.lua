---@class NodeFactory
local NodeFactory = {}

---@param defaultNodeDef  Node.NodeDefinition    Parameters that all nodes registered with this factory must have.
---@param nodeDefs        Node.NodeDefinition[]  List of nodes with parameters unique to them.
---@return NodeFactory
function NodeFactory:new(defaultNodeDef, nodeDefs)
	---@type NodeFactory
	local instance = setmetatable({}, {__index = self})

	for _, nodeDef in ipairs(nodeDefs) do

		Core.Node:getModClassInstance(table.merge(nodeDef, defaultNodeDef))

	end

	return instance
end

return NodeFactory