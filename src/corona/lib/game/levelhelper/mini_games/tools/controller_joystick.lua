-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local Helper = import("game.levelhelper.helper")
local ControllerBase = pkgImport(..., "controller_base")
local ControllerJoystick = class("ControllerJoystick", ControllerBase)


function ControllerJoystick:init()
	self.levelHelperUiName = self.levelHelperUiName or "joystick"
	self.flags = {}
	--self.audioActionMgr = import("game.action.action_manager"):new()
	ControllerBase.init(self)
end

function ControllerJoystick:initControl(bttn, target)
	if bttn.joystickComponent == nil then
		local base = Helper.findLevelObject(self.context, bttn.joystick_base, bttn.loaderID)
		local body = Helper.findLevelObject(self.context, bttn.joystick_body, bttn.loaderID)
		local stick = display.newSubGroup(base.parent)
		local x0, y0 = bttn:localToContent(0, 0)
		stick:insert(body)
		stick:insert(bttn)
		stick:translate(base.x, base.y)
		local x1, y1 = bttn:localToContent(0, 0)
		bttn:translate(x0 - x1, y0 - y1)
		body:translate(x0 - x1, y0 - y1)

		-- local dot = display.newCircle(stick, 0, 0, 10)
		-- dot:setFillColor(1, 0, 0)

		local initAngle = tonumber(bttn.joystick_angle)
		local radius = self.game.stickRadius or tonumber(bttn.joystick_radius)
		local limit = radius * 10

		-- _D("initAngle", type(initAngle), "radius", type(radius))
		-- local bttnID = tostring(bttn)
		-- local targetID = tostring(target)
		self.flags[bttn] = false
		local joystick = Component.add("joystick", stick, {
			touchRegion = bttn,
			base = base,
			initAngle = initAngle,
			radius = radius,
			onControl = function(e)
				-- _D(tostring(act == nil))
				if not self.flags[bttn] then
					for i=1, #bttn.slaves do
						local target = bttn.slaves[i]
						local targetID = tostring(target)
						self.game:playerTrigger("on_" .. targetID .. "_player_trigger", target)
					end
					self.flags[bttn] = true
				end
				-- e.rotateSpeed = e.deltaAngle * 1000 / e.deltaTime
				-- e.moveSpeed = e.deltaArcLength * 1000 / e.deltaTime
				e.rotateSpeed = clamp(e.deltaAngle * display.fps, -limit, limit)
				e.moveSpeed = clamp(e.deltaArcLength * display.fps, -limit, limit)
				local this = self
				-- local audioMgr = self.game.ctx.sndMgr
				 -- this.audioActionMgr:setNextAction("sys.async", {mainFunc = function(action)
					-- 	audioMgr:play("handauge1", function()
					-- 		action:over()
					-- 	end)
				 -- 	end})

				-- if e.deltaTime == 0 then
				-- 	_D(e.deltaTime)
				-- end
				if self.game.direction then
					local dir = self.game.direction
					e.moveSpeed = sign(e.moveSpeed) == dir and e.moveSpeed or 0
					e.rotateSpeed = sign(e.rotateSpeed) == dir and e.rotateSpeed or 0
					-- _D(e.moveSpeed, e.rotateSpeed)
				end
				for i=1, #bttn.slaves do
					local target = bttn.slaves[i]
					self.game:onControlUpdate("onPlayerTrigger", target, e)
					self.game.timerMgr:setTimeout(50, function()
						self.game:onControlUpdate("onPlayerTrigger", target, {rotateSpeed = 0, moveSpeed = 0})
					end)
				end
			end
		})
		_.push(self.components, joystick)
		bttn.joystickComponent = joystick
	end
end

function ControllerJoystick:initPosition()
	self:translate(_R - self.contentWidth, _B - self.contentHeight * 0.65)
	self.initPos = {self.x, self.y}
end

function ControllerJoystick:reset()
	-- self.start = false
	for k,v in pairs(self.flags) do
		self.flags[k] = false
	end
	self:enableAll()
end

return ControllerJoystick
