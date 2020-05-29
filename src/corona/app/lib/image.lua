-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local Image = {}
Image.list = require("assets.image_info")

function Image:getImageInfo( path )
	local wh = self.list[path]
	return wh
end

local _clone = function(self)
	local cloned = display.newImageRect(self.path, self.info[1], self.info[2])
	cloned.path = self.path
	cloned.info = self.info
	cloned.clone = self._clone
	return cloned
end

function Image:newImageRect( path )
	local info = self.list[path]
	assert(info ~= nil, "cannot find [" .. tostring(path) .. "] in image info data")

	local displayObj = display.newImageRect( path, info[1], info[2] )
	displayObj.path = path
	displayObj.info = info
	displayObj.clone = _clone
	return displayObj
end

return Image
