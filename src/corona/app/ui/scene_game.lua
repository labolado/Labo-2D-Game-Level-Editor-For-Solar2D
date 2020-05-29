-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local SceneHelper   = require("app.lib.scene_helper")
local SceneInfo     = require("app.ui.scene_info")
local LoaderManager = require("app.lib.loader_manager")
local ActionUtil    = require("lib.game.levelhelper.helper")
local physics       = require("physics")
local Car           = require("app.game.car")
local CameraManager = require("app.game.camera_manager")
local ControllerUI = require("app.game.controller")
local GodotLoader = require("godot.godot_loader")
local SoundManager = pkgImport(..., "sound_manager")

local myScene = SceneHelper.createMyScene()
function myScene:onCreate(event)
	local sceneGroup = self.view
	display.addFullScreenColorBackground(sceneGroup, _HC("#cdeff8ff"))

	local ctx = {}
	ctx.timerMgr = self.timerMgr
	ctx.transMgr = self.transMgr
	ctx.sndMgr = SoundManager:new()

	ctx.ui = {}
	ctx.ui.view = sceneGroup
	ctx.ui.bkgGroup   = display.newSubGroup(sceneGroup)
	ctx.ui.playGroup  = display.newSubGroup(sceneGroup)
	ctx.ui.miniGameGroup = display.newSubGroup(sceneGroup)
	ctx.game = self
	self.ctx = ctx
	self.carControllable = true
	self.isStarted = false

	self:initLevel()

	local back = display.newImageRect(sceneGroup, "assets/ui/back.png", 161, 161)
	back:translate(_L + back.contentWidth * 0.7, _T + back.contentHeight * 0.7)
	Component.add("button", back, {
		onRelease = function(e)
			SceneHelper.gotoScene(SceneInfo.home(1))
		end
	})
end

function myScene:initPhysics()
	physics.start()
	local physicsScale = 60
	local rate = physicsScale / 128
	physics.setGravity(0, 33)
	physics.setScale(physicsScale)
	-- physics.setDrawMode("hybrid")
	physics.setMKS("linearSleepTolerance", 0.1)
	physics.setMKS("angularSleepTolerance", 0.07)
	self.ctx.PHYSICS_RATE = rate
	self.ctx.PHYSICS_RATE_SQUARE = rate * rate
	self.ctx.physics = physics
end

function myScene:initLevel()
	self:initPhysics()
	local ctx = self.ctx

	local levelLoader = LoaderManager:new(ctx.ui.playGroup)
	ctx.levelLoader = levelLoader

	local car = Car:new(ctx, 1)
	levelLoader.player:insert(car)
	car:start()
	ctx.car = car

	local camera = CameraManager:new(ctx.ui.playGroup, ctx, 1)
	camera.zoom = EMPTY
	ctx.camera = camera

	self:initBackground(camera)

	local levelName = "level" .. self.info.levelNo
	local contextID = {
	    name = "firstLevel"
	}
	local scriptName = "default"
	local actionString = string.format("load,name=%s,script=%s,loading=false,clear=false", levelName, scriptName)
	ActionUtil.runAction(ctx, actionString, contextID)

	local nextCtx = ctx.next
	nextCtx.parser:addCarCollisionTrigger(nextCtx, ctx.car)
	self:initControlUI()

	if levelLoader.carPosMark then
		car:setPosition(levelLoader.carPosMark.x, levelLoader.carPosMark.y - car.contentHeight * 0.5)
	end

	camera:start()
	camera:update()

	camera:track()
	camera:faceTo(camera:getFocusObject(), 0.002)
	self.timerMgr:setTimeout(1000, function()
		self.isStarted = true
		-- self.ctrlUI.isVisible = true
		-- self.ctrlUI:show()
		Runtime:removeEventListener("enterFrame", self)
		Runtime:addEventListener("enterFrame", self)
	end)
end

function myScene:initBackground(camera)
	local ctx = self.ctx
	local bkgGroup = ctx.ui.bkgGroup
    local loader = GodotLoader:new("assets/levels/export/background.json")
    local group = loader.view
    local group0 = group[1]
    local group1 = group[2]

    bkgGroup:insert(group)
    Component.add("endless_moving", group0, {
        speed = 0,
        direction = -1
    })
    Component.add("endless_moving", group1, {
        speed = 0,
        direction = -1
    })
    camera:addLayer("background0", group0, 0.1, 1, 0.1, false, true, true)
    camera:addLayer("background1", group1, 0.15, 1, 0.1, false, true, true)
end


function myScene:initControlUI()
	local ctx = self.ctx
	local buttonCall = function(e)
		if not self.carControllable then return false end
		if self.isStarted then
			if (e.phase == "began") then
				ctx.car:setPower(true)
				if e.x < _CX then
					ctx.car:setDriveDir(-1)
				else
					ctx.car:setDriveDir(1)
				end
			elseif (e.phase == "ended") then
				ctx.car:setPower(false)
				-- ctx.car:stopImmediately()
				-- ctx.sndMgr:carMoveStop()
			end
		end
	end

    local ctrlUI = ControllerUI:new(self, ctx, buttonCall)
    -- ctrlUI.controlLeft.isVisible = false
    -- ctrlUI:hide()
    -- ctrlUI.isVisible = false
	self.view:insert(ctrlUI)
	self.ctrlUI = ctrlUI
end

function myScene:setCarControllable(bool)
	self.carControllable = bool
	if bool then
	    self.ctrlUI:show()
	else
	    self.ctrlUI:hide()
	    self.ctrlUI:cancelAll()
	end
end

function myScene:enterFrame(e)
	local ctx = self.ctx
	ctx.car:drive()
end

function myScene:onHide(event)
    if event.phase == "will" then
    end
end

function myScene:onDestroy(event)
	Runtime:removeEventListener("enterFrame", self)
	local ctx = self.ctx

	local last = ctx
	while last ~= nil do
	    if last.parser then
	        -- _D("!-> parser remove", last.parser)
	        last.parser:removeSelf()
	        last.parser = nil
	    end
	    local nextCtx = last.next
	    last.next = nil
	    last = nextCtx
	end

	if ctx.car.parent then
	    ctx.car:clearPhysics()
	    ctx.car:removeSelf(); ctx.car = nil
	end
	ctx.levelLoader:removeSelf() ; ctx.levelLoader = nil
	ctx.camera:removeSelf(); ctx.camera = nil
	display.removeAllChildren(self.view)
	physics.stop()
end

return myScene
