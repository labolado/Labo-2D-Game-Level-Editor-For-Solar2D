-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local Controller = class("Controller", Node)

local function newPushButton(defaultInfo, overInfo, onPress, onRelease, ensure, onCancel)
	local group = display.newGroup()
	local default = display.newImageRect(defaultInfo.name, defaultInfo.width, defaultInfo.height)
	local over = display.newImageRect(overInfo.name, overInfo.width, overInfo.height)
	over.isVisible = false
	group:insert(default)
	group:insert(over)
	Component.add("button", group, {
		overScale = 1,
		onPress = function(e)
			default.isVisible = false
			over.isVisible = true
			if onPress then onPress(e) end
		end,
		onRelease = function(e)
			default.isVisible = true
			over.isVisible = false
			if onRelease then onRelease(e) end
		end,
		ensure = function(e)
			default.isVisible = true
			over.isVisible = false
			if ensure then ensure(e) end
		end,
		onCancel = function(e)
			default.isVisible = true
			over.isVisible = false
			if onCancel then onCancel(e) end
		end
	})
	return group
end

function Controller:initialize(game, ctx, onControl)
	self.ctx = ctx
	local controlRight = newPushButton(
	    {name = "assets/ui/right.png", width = 235, height = 260},
	    {name = "assets/ui/right-press.png", width = 235, height = 240},
	    onControl,
	    onControl,
	    onControl,
	    onControl
	)

	local controlLeft = newPushButton(
	    {name = "assets/ui/left.png", width = 235, height = 260},
	    {name = "assets/ui/left-press.png", width = 239, height = 245},
	    onControl,
	    onControl,
	    onControl,
	    onControl
	)
	controlLeft:translate(_L + controlLeft.contentWidth * 1.5, _CY + controlLeft.contentHeight * 2)
	controlRight:translate(_R - controlRight.contentWidth * 1.5, controlLeft.y)

	self:insert(controlRight)
	self:insert(controlLeft)
	controlRight.initPos = {x = controlRight.x, y = controlRight.y}
	controlLeft.initPos = {x = controlLeft.x, y = controlLeft.y}

	self.controlRight = controlRight
	self.controlLeft = controlLeft
	self.isHidden = false
end

function Controller:setLevelRatio(levelRatio)
	-- self.sldierStick:setLevelRatio(levelRatio)
end

function Controller:cancelAll()
	Component.get("button", self.controlRight):cancel()
	Component.get("button", self.controlLeft):cancel()
end

function Controller:hide()
	if not self.isHidden then
		self.isHidden = true
		objectTransOut(self.controlRight, {
			transMgr = self.ctx.transMgr,
			time = 300,
			y = _B + self.controlRight.contentHeight
		})
		objectTransOut(self.controlLeft, {
			transMgr = self.ctx.transMgr,
			time = 300,
			y = _B + self.controlLeft.contentHeight
		})
	end
end

function Controller:show()
	if self.isHidden then
		self.isHidden = false
		objectTransIn(self.controlRight, {
			transMgr = self.ctx.transMgr,
			time = 300,
			y = self.controlRight.initPos.y
		})
		objectTransIn(self.controlLeft, {
			transMgr = self.ctx.transMgr,
			time = 300,
			y = self.controlLeft.initPos.y
		})
	end
end
return Controller
