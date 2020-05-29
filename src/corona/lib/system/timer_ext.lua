-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local original_pause = timer.pause
local original_resume = timer.resume

local pause = function(timerData)
	if not timerData.isPaused then
		timerData.isPaused = true
		return original_pause(timerData)
	end
	return 0
end

local resume = function(timerData)
	if timerData.isPaused then
		timerData.isPaused = false
		return original_resume(timerData)
	end
	return 0
end

timer.pause = pause
timer.resume = resume
