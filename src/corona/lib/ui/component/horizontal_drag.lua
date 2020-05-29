-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local TMR = TouchManager

-- local SignalsManager = require("app.lib.modules.signals_manager")
local lengthOf2 = lengthOf2
local angleOf2 = angleOf2
local clamp3 = clamp3
local _ratio = 1

local HorizontalDrag = class("HorizontalDrag")
-- HorizontalDrag:include(SignalsManager)

function HorizontalDrag:initialize(target, options)
	options = options or {}
	-- self:initModule()
	self.target = target
	-- self.SIG_ON_DRAG_UP = "on_drag_up"

	-- if options.onDragUp then
	-- 	self:sigRegister(self.SIG_ON_DRAG_UP, options.onDragUp)
	-- end
	self.onDragUp = options.onDragUp

    display.aliasRemoveSelf(target, function(obj)
        Component.remove("horizontal_drag", obj)
    end)
end

function HorizontalDrag:touch(e)
	if e.phase == "began" then
		TMR.setFocus(self.target, e.id)
		return true
	elseif e.isFocused then
		if e.phase == "moved" then
			local len = lengthOf2(e.xStart, e.yStart, e.x, e.y)
			if len > 80 * _ratio then
				local angle = angleOf2(e.xStart, e.yStart, e.x, e.y)
				local check = clamp3(angle, -150, -30)
				if check then
		        	-- self:sigEmit(self.SIG_ON_DRAG_UP, e)
		        	if self.onDragUp then
		        		if self.onDragUp(e) then
				        	TMR.unsetFocus(self.target, e.id)
		        		end
		        	end
		        else
		        	TMR.unsetFocus(self.target, e.id)
				end
			end
			return true
        elseif e.phase == "ended" or e.phase == "cancelled" then
        	TMR.unsetFocus(self.target, e.id)
        	return true
		end
	end
end

function HorizontalDrag:enable()
    TMR.register(self.target, self)
end

function HorizontalDrag:disable()
    TMR.unregister(self.target, self)
end
return HorizontalDrag
