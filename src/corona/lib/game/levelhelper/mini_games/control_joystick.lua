-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local Helper = pkgImport(..., "helper", 2)
local ControlGame = pkgImport(..., "control")
local ControlJoystick = class("ControlJoystick", ControlGame)

function ControlJoystick:init(objects, gameEndObject, params)
	self.stickRadius = 30
	if params["rotateSpeed"] then
		self.stickRadius = tonumber(params["rotateSpeed"] )
	end
	params.ext_typename = params.ext_typename or "controller_joystick"
	local direction = tonumber(params.ext_direction)
	self.direction = direction
	-- _D(tostring(self.direction), "direction", "direction")
	ControlGame.init(self, objects, gameEndObject, params)

	self.timerMgr:setInterval(20, function(e)

		if Helper.getVariable(self.ctx, "$start_move") == "true" then
			self.direction = nil
		else
			self.direction = direction
		end
	end)
end

function ControlJoystick:stop()
	self.timerMgr:setTimeout(300, function()
		self:clear({"$start_move"})
	end)
	ControlGame.stop(self)
end

return ControlJoystick
