-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

-- 汽车控制，强制汽车往指定方向开
local Action = pkgImport(..., "base"):extend("car_ctrl", {
	{name = "dir", required = true, type = "int", limit = {max = 1, min = -1}, desc="汽车行驶方向"},
	{name = "speedScale", default = 1, type = "int",limit = {max = 10, min = 0}, desc="汽车速度"},
})

function Action.execute(ctx, obj)
	local car = ctx.car
	if car then
		if obj.dir == 0 then
			car:setPower(false)
			car:setSpeedScale(1)
			car:stopImmediately()
			ctx.sndMgr:carMoveStop()
		else
			car:setPower(true)
			car:setDriveDir(obj.dir)
			car:setSpeedScale(obj.speedScale)
		end
	end

	function obj:onControlUpdate(scale)
		car:setSpeedScale(scale)
	end
end

return Action