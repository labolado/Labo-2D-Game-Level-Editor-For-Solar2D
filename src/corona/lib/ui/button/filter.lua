-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


-- local Bit = require("plugin.bit")
local Bit = require("lib.thirdparty.bit.numberlua")
local Filter = class("Filter")

function Filter:initialize(prototype)
    self.groupIndex = 0
    self.categoryBits = 0x0001
    self.maskBits = 0xFFFF
    _.extend(self, prototype)
end

function Filter:checkConflict(otherFilter)
    return Filter:check(self, otherFilter)
end

function Filter.static:check(filterA, filterB)
    if filterA.groupIndex == filterB.groupIndex and filterA.groupIndex ~= 0 then
        return filterA.groupIndex > 0
    end

    local conflict = Bit.band(filterA.maskBits, filterB.categoryBits) ~= 0 and Bit.band(filterA.categoryBits, filterB.maskBits) ~= 0
    return conflict
end

return Filter
