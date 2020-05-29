-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


-- APP.import("lib.level_helper.MyLevelHelperLoader")
local GodotTerrian = require("app.model.loader.godot.godot_bezier_track")
local GodotSprite = require("app.model.loader.godot.godot_sprite")
local ControllerBase = pkgImport(..., "controller_base")
local Selector = class("Selector", ControllerBase)

-- function Selector:initPosition()
-- 	self:translate(_R - self.contentWidth * 0.65, _T + self.contentHeight * 0.65)
-- 	self.initPos = {self.x, self.y}
-- end

-- function ControllerBase:hide()
-- 	objectTransOut(self, {
-- 		transMgr = self.game.transMgr,
-- 		y = _T - self.contentHeight * 0.85,
-- 	})
-- end

function Selector:initControl(bttn, target)
	local ctx = self.context
	-- local bttnID = tostring(bttn)
	local targetID = tostring(target)
	-- ctx.customSignal.register("on_" .. bttnID .. "_button_press", function()
	-- 	self.game:playerTrigger("on_" .. targetID .. "_button_press", target)
	-- 	self.game:playerTrigger("on_" .. targetID .. "_player_trigger", target)
	-- end)
	-- ctx.customSignal.register("on_" .. bttnID .. "_button_release", function()
	-- 	self.game:playerTrigger("on_" .. targetID .. "_button_release", target)
	-- end)
	local obj
	-- if target.lhNodeType == "LHSprite" then
	-- 	obj = LevelHelperLoader:createSpriteFromSHDocument(target.shSpriteName, target.shSheetName, target.shSceneName)
	-- elseif target.lhNodeType == "LHBezierTrack" then
	-- 	obj = LevelHelperLoader:cloneBezeirTrack(target, {groundHeightOffset = 256, nophysic = 1})
	-- end
	if target.class == GodotSprite then
		obj = GodotSprite:new(target.godotData)
	elseif target.class == GodotTerrian then
		obj = GodotTerrian:new(target.godotData, {groundHeightOffset = 256, nophysic = 1})
	end
	if obj then
		_D("!-> Selector bttn wh", obj.contentWidth, obj.contentHeight, target.contentWidth, target.contentHeight)
		zoomObject(obj, {bttn.contentWidth - 16, bttn.contentHeight - 16})
		local x, y = bttn:localToContent(0, 0)
		obj:translate(x - obj.x, y - obj.y)
		obj.isVisible = true
		-- -- bttn.parent:insert(obj)
		display.changeParent(obj, bttn.parent)
		Component.add("button", obj, {
			-- overScale = 1,
			-- onPress = function()
			-- end,
			onRelease = function()
				self.game:playerTrigger("on_" .. targetID .. "_player_trigger", target)
			end
		})
	end
end

return Selector
