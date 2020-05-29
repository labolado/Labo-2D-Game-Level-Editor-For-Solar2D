-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

-- camera镜头转换
local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("camera_transform", {
	{name = "resume", default = false, type = "bool", desc="是否切回到跟踪汽车"},
	{name = "auto_scale", default = true, type = "bool", desc="自动缩放开关"},
	{name = "speed", default = 0.01, type = "float", limit = {max=1,min=0}},
	{name = "scale", default = 0, type = "float", limit = {max=1,min=-1}},
	{name = "scale_speed", default = 0.03, type = "float", limit = {max=1,min=0}},
	{name = "onComplete", default = "", type = "string", limit = {max=100000, min=0}}
})

function Action.execute(ctx, obj)
	local camera = ctx.camera
	-- local car = ctx.car
	local car = obj.ROLE
	if camera and car then
		-- camera:faceTo(obj.target, )
		-- car:stopImmediately()
		if obj.resume then
			local focusedObj = car:getChassis()
			if obj.hasTargetProp then
				focusedObj = obj.target
			end
		    camera:setFocus(focusedObj, obj.speed, function()
				camera:scaleBy(0, obj.scale_speed, function()
					camera:setAutoScale(true)
					-- if obj.hasTargetProp then
		                _D("Camera resumed completely!")
						ctx.customSignal.emit("on_" .. tostring(obj.target) .. "_camera", obj.target)
						Helper.parseAndRun(ctx, obj.onComplete, obj.target)
					-- end
				end)
		    end)
		else
			local a, b = false, false
			local focusedObj = car:getChassis()
			if obj.hasTargetProp then
				focusedObj = obj.target
			end
			local complete = function()
				if a and b then
	                ctx.customSignal.emit("on_" .. tostring(obj.target) .. "_camera", obj.target)
	                _D("Camera transformed completely!")
	                -- ctx.timerMgr:clearTimer(e.source)
					Helper.parseAndRun(ctx, obj.onComplete, obj.target)
				end
			end
			if obj.auto_scale then
				camera:setFocus(focusedObj, obj.speed, function()
					a = true
					_D("Focuse completed.")
					if obj.scale == 0 then
						b = true
						complete()
					else
						camera:scaleBy(obj.scale, obj.scale_speed, function()
			                b = true
			                complete()
			                _D("Zoom completed.")
						end)
					end
				end)
			else
				if obj.scale == 0 then
					b = true
					complete()
				else
					camera:setAutoScale(false)
					camera:scaleBy(obj.scale, obj.scale_speed, function()
		                b = true
		                complete()
		                _D("Zoom completed.")
					end)
				end
			end
			-- ctx.timerMgr:setInterval(20, function(e)
			-- 	if a and b then
	  --               ctx.customSignal.emit("on_" .. tostring(obj.target) .. "_camera", obj.target)
	  --               _D("Camera transformed completely!")
	  --               ctx.timerMgr:clearTimer(e.source)
			-- 	end
			-- end)
		end
	end
end

return Action
