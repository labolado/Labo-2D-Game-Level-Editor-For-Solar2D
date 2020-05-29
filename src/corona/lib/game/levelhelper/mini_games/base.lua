-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local Helper = pkgImport(..., "helper", 2)
local TimerManager = import("system.timer_manager")
local TranManager = import("system.transition_manager")
local SignalsManager = import("game.signals_manager")

local Base = class("MiniGameBase")
Base:include(SignalsManager)

function Base:initialize(id, ctx, ...)
    self:initModule()
	self.id = id -- loaderID
	self.ctx = ctx
	self.timerMgr = TimerManager:new()
	self.transMgr = TranManager:new()
	self.view = display.newSubGroup(ctx.ui.miniGameGroup)
	self.isStopped = false
	self:init(...)
end

function Base:init(objects, gameEndObject)
end

function Base:show()
end

function Base:hide()
end

function Base:start()
end

function Base:stop()
	self.isStopped = true
end

function Base:clear(keys)
	self.timerMgr:cancelAll()
	if type(keys) == "table" then
		for i=1, #keys do
			Helper.setVariable(self.ctx, keys[i], nil)
		end
	end
end

function Base:playerTrigger(sigName, target)
	self.ctx.customSignal.emit(sigName, target)
end

function Base:onClearBefore()
end

function Base:setCarControllable(bool)
    self.ctx.root.game:setCarControllable(bool)
end

function Base:removeSelf()
	self:onRemove()
	self:sigClearAll()
	self.timerMgr:cancelAll()
	self.transMgr:cancelAll()
	self.view:removeSelf()
	for k,v in pairs(self) do
		self[k] = nil
	end
end

function Base:onRemove()
end

return Base
