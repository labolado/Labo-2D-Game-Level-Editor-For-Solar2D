-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local Signals = import("game.signal")
local M = {}

function M:initModule()
	self.signals = Signals:new()
end

function M:sigEmit(sigName, ...)
	self.signals.emit(sigName, ...)
end

function M:sigRegister(eventType, func)
    local f = self.signals.register(eventType, func)
end

function M:sigRegisterOnce(eventType, func)
	local f = self.signals.registerOnce(eventType, func)
end

function M:sigRemove(eventType, func)
	self.signals.remove(eventType, func)
end

function M:sigClear(eventType)
	self.signals.clear_name(eventType)
end

function M:sigClearAll()
	self.signals.clear_all()
end

return M
