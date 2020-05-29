local class = GodotGlobal.class
local tostring = tostring

local GodotNode = class("GodotNode", function()
	local obj = display.newGroup()
	obj._uniqueTableId = tostring(obj)
	return obj
end)

function GodotNode.static.new(self, ...)
	local instance = self:allocate()
	instance:addEventListener("finalize")
	instance:initialize(...)
	return instance
end

function GodotNode:finalize(e)
	self:onRemove()
    for k,v in pairs(self) do
    	if k:find("^_") == nil then
	    	self[k] = nil
	    end
    end
end

function GodotNode:initialize(info)
	self.name = info.name
	self.lhUniqueName = info.name
	-- self.node_path = info.node_path
	self.lhUserCustomInfo = info.custom_info
end

function GodotNode:__tostring()
	return self._uniqueTableId
end

function GodotNode:onRemove()
end

return GodotNode
