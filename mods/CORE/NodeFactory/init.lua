local NodeFactory = Mod:new()

NodeFactory.Class = NodeFactory.require('Node')

Api.addModToGlobalSpace(NodeFactory, 'Core.NodeFactory')
