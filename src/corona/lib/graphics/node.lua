-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local Node = class("Node", function() return display.newGroup() end)

-- function Node:removeSelf()
-- 	_D(tostring(self.class) .. " removeSelf")
--     self:onRemove()
--     self:_super("removeSelf")
--     for k,v in pairs(self) do
--     	if k:find("^_") == nil then
-- 	    	self[k] = nil
-- 	    end
--     end
-- end

function Node.static.new(self, ...)
	local instance = self:allocate()
	instance:addEventListener("finalize")
	instance:initialize(...)
	return instance
end

function Node:finalize(e)
	-- _D(tostring(self.class) .. " removeSelf")
	self:onRemove()
    for k,v in pairs(self) do
    	if k:find("^_") == nil then
	    	self[k] = nil
	    end
    end
end

function Node:onRemove()
end

return Node
