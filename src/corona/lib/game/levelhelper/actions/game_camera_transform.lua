-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

-- camera镜头转换，同时用禁用或者启动对车的控制,当resume为默认或者false时，进行镜头切换，同时车停止，车控制停止
-- 当resume为true的时候，镜头切换回车，同时车启动，车控制启动
local Helper = pkgImport(..., "helper", 2)
local Action = pkgImport(..., "base"):extend("game_camera_transform", {
	{name = "resume", default = false, type = "bool", desc="是否切回到跟踪汽车"},
	{name = "speed", default = 0.005, type = "float", limit = {max=1,min=0}},
	{name = "scale_speed", default = 0.03, type = "float", limit = {max=1,min=0}},
	{name = "scale", default = 0, type = "float", limit = {max=1,min=-1}},
	{name = "onComplete", default = "", type = "string", limit = {max=100000, min=0}}
})

local Helper = pkgImport(..., "helper", 2)

function Action.execute(ctx, obj)
	local camera = ctx.camera
	local game = ctx.game
	local car = ctx.car
	if camera and car and game then
		-- camera:faceTo(obj.target, )

		if obj.resume then
			-- local minigame = Helper.findMiniGame(ctx, obj)
			local minigame = ctx.game
			_D("minigame stop name:", minigame.name, obj.GAME.name)
			if minigame then
				_D("!-> game end!")
				-- ctx.sndMgr:play("minigame_end")

				minigame:stop()
			end

			ctx.timerMgr:setTimeout(1 * 1000, function(e1)
				_D("camera resume")
				local a, b = false, false
			    camera:setFocus(ctx.car:getFocusObject(), obj.speed, function()
			    	a = true
			    	_D("Focused")
					camera:scaleBy(0, obj.scale_speed, function()
	        			camera:setAutoScale(true)
		                b = true
		                _D("zoomed")
						if a and b then
			               -- ctx.customSignal.emit("on_" .. tostring(obj.target) .. "_camera", obj.target)
			                _D("Camera restore completely!")

	 						car:setSpeedScale(1)
	 						car:changeHeadPhysicType("dynamic")
			                game:setCarControllable(true)

	 						-- ctx.timerMgr:clearTimer(e.source)
							Helper.parseAndRun(ctx, obj.onComplete, obj.target)
						end
					end)
			    end)

				-- ctx.timerMgr:setInterval(20, function(e)
				-- end)
			end)

		else
			_D("camera transform")
			game:setCarControllable(false)
			car:stopImmediately()
			-- car:changeHeadPhysicType("static")

			local a, b = false, false
			local focusedObj = car:getFocusObject()
			if obj.hasTargetProp then
				focusedObj = obj.target
			end
			local complete = function(e)
				if a and b then
	                ctx.customSignal.emit("on_" .. tostring(obj.target) .. "_camera", obj.target)
	                _D("Camera transformed completely!")
	                -- ctx.timerMgr:clearTimer(e.source)

					-- local minigame = Helper.findMiniGame(ctx, obj)
					local minigame = ctx.game
					_D("minigame start name:", minigame.name, obj.GAME.name)
					if minigame then
						minigame:start()
					end

					Helper.parseAndRun(ctx, obj.onComplete, obj.target)
				end
			end
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
			-- ctx.timerMgr:setInterval(20, complete)
		end
	end
end

return Action
