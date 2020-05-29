-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

-- 关卡结束
local Action = pkgImport(..., "base"):extend("game_end", {})

function Action.execute(ctx, obj)
	local game = ctx.root.game
	if game then
		game.gameFinished = true
		game:setCarControllable(false)
		Runtime:removeEventListener("touch", game)
		ctx.sndMgr:carMoveStop()
		ctx.sndMgr:cheer()

		ctx.car:stop(function()
		    display.currentStage:setFocus( nil )
		    ctx.camera:pause()
		    -- game.scene:finish()
		    logOnScreen("Game Complete!")
		end)
	end
end

return Action
