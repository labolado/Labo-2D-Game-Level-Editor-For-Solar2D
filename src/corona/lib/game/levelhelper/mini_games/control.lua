-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local Helper = pkgImport(..., "helper", 2)
-- local BrickPicker = pkgImport(..., "tools.brick_picker")
local MiniGameBase = pkgImport(..., "base")
local Control = class("Control", MiniGameBase)
local _PACKAGE = currentPackage(...) .. ".tools."

function Control:init(objects, gameEndObject, params)
	if params.stickRadius then self.stickRadius = tonumber(params.stickRadius) end
	local controllerType = params.ui_type or "controller_base"
	self.controller = require(_PACKAGE .. controllerType):new(self, objects, params.ui)
	self.view:insert(self.controller)
	self.gameEndObject = gameEndObject
	self.isStopped = false
	self:hide()
end

function Control:show()
	self.controller:show()
end

function Control:hide()
	self.controller:hide()
end

function Control:start()
	self:show()
	_D(tostring(self.class):gsub("class ", "") .. " start!")
	self.controller:onStart()
end

function Control:stop()
	self:hide()
	self.controller:onStop()
end

-- function Control:playerTrigger(sigName, target)
-- 	self.ctx.customSignal.emit(sigName, target)
-- end

function Control:onControlUpdate(sigType, target, ...)
	local acts = target.actions[sigType]
	for i=1, #acts do
		local act = acts[i]
		if type(act.onControlUpdate) == "function" then
			act:onControlUpdate(...)
		end
	end
end

function Control:onRemove()
	self.controller:clearSelf()
end

return Control
