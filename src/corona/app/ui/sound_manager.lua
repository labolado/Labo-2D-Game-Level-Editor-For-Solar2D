-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local S = {}

function S:new(ctx)
	local sm = {}

	function sm:init()
	end

	function sm:removeSelf()
	end

	function sm:tap()
	end

	function sm:flip()
	end

	function sm:startCommonBg()
	end

	function sm:fadeCommonBg()
	end

	function sm:restoreCommonBg()
	end

	function sm:stopCommonBg()
	end

	function sm:stopAll()
	end

	function sm:startBg()
	end

	function sm:play(audio, onComplete)
	end

	function sm:loop(audio, onComplete)
	end

	function sm:selectBlock()
	end

	function sm:cancelBlock()
	end

	function sm:placeBlock()
	end

	function sm:fitAll()
	end

	function sm:carMove()
	end

	function sm:rain()
	end

	function sm:cheer()
	end

	function sm:truckMove(audioFile, channel)
	end

	function sm:truckStop(audioFile)
	end

	function sm:setTruckMoveSpeed(audioFile, num)
	end

	function sm:setCarEngineVolume(num)
	end

	function sm:carMoveStop()
	end

	function sm:carTouch()
	end

	function sm:light(alarms, flag)
	end

	function sm:fadeOutAlarm()
	end

	function sm:rainStop()
	end

	function sm:horn(onComplete)
	end

	function sm:balloon()
	end
	return sm
end


return S
