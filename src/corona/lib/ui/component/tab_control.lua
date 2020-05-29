-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local class = import("system.middleclass")

local TapControl = class("TapControl")

function TapControl:initialize(target, options)
    self.target = target
    self.tabs = options.tabs or displayGroupToArray(target)
    self.triggerPhase = options.triggerPhase or "began"
    self.onTriggered = options.onTriggered
    self.otherTabsCall = options.otherTabsCall

    local currentTab = options.currentTab or self.tabs[1]
    self:touch({phase = self.triggerPhase, target = currentTab, fake = true})
    self.currentTab = currentTab
    self.previousTab = self.currentTab
end

function TapControl:touch(e)
    if self.currentTab == e.target then return true end
    if e.phase == self.triggerPhase then
        self.previousTab = self.currentTab
        self.currentTab = e.target
        local res = false
        if self.onTriggered then
            res = self.onTriggered(e.target, self.previousTab, e.fake)
        end
        for i=1, #self.tabs do
            local tab = self.tabs[i]
            if tab ~= self.currentTab then
                if self.otherTabsCall then
                    self.otherTabsCall(tab, self.previousTab)
                end
            end
        end

        return res
    end
end

function TapControl:selectTab(tab)
    self:touch({phase = self.triggerPhase, target = tab, fake = true})
end

function TapControl:getCurrentTab()
    return self.currentTab
end

function TapControl:getPreviousTab()
    return self.previousTab
end

function TapControl:enable()
    _.each(self.tabs, function(tab)
        tab:addEventListener("touch", self)
    end)
end

function TapControl:disable()
    _.each(self.tabs, function(tab)
        tab:removeEventListener("touch", self)
    end)
end

return TapControl
