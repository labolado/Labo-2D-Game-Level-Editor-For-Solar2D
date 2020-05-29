-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local MiniGameBase = pkgImport(..., "base", 2)
local DefaultGame = class("DefaultGame", MiniGameBase)
local Helper = require("lib.game.levelhelper.helper")
local physics = require("physics")

local sndBg

-- 场景初始化
function DefaultGame:init(action)
    local ctx = self.ctx
    ctx.game = self

    -- _D("tell DefaultGame")
    -- _D(ctx.root.onPause)
    -- _D(ctx.onPause)
    -- _D("end tell")
    self.scene = ctx.root.game.scene
    self.gameFinished = false
    self.carControllable = true
    self.startTime = 0
    self.pauseTime = 0
    self.SIG_CAR_CONTROL = "game_car_control_began"
    self.touchRecord = {}

    self.animals = {}
    self.touchable = false
    -- self.deadCount = 0
    self.canIkBonePositionUpdate = true

    self.lastTime = system.getTimer()
    -- self.spawnConfig = {
    --     time = 200,
    --     current = 200
    -- }
    -- self.gameTrigger = false

    -- self:sigRegister("trigger", function(event)
    --     self:onTrigger(event)
    -- end)

    self:sigRegister("start", function(event)
        self:onLevelStart(event)
    end)

    if action.clear then
        ctx.parser:register(self.id.allCoronaSprites)
    else
        ctx.parser:parseAndRegister(self.id.allCoronaSprites)
    end

    -- ctx.root.game:resetCamera()
    -- if action.loading then
    --     self.timerMgr:setTimeout(500, function()
    --         Loading:destroy()
    --     end)
    -- end
end

function DefaultGame:onLevelStart(event)
    local ctx = self.ctx
    local loaderMgr = ctx.levelLoader
    local role = ctx.car
    local target = event.target
    local x = (target.contentBounds.xMin + target.contentBounds.xMax) * 0.5
    local y = target.contentBounds.yMax
    -- car:createContainerPhysics(loaderMgr.grounds, filter)
    loaderMgr.player:insert(role)
    role:setPosition(x, y)
end

function DefaultGame:touch(e)
end

function DefaultGame:buttonTouch(e)
end

function DefaultGame:setCarControllable(bool)
    self.ctx.root.game:setCarControllable(bool)
    -- if self.carControllable ~= bool then
    --     self.carControllable = bool
    --     self.touchRecord = {}
    --     self.ctx.car:setPower(false)
    --     self.ctx.car:setCanJump(bool)
    -- end
    -- self.scene.controlLeft.isVisible = bool
    -- self.scene.controlRight.isVisible = bool
    -- if not self.carControllable then
    --     self.ctx.sndMgr:carMoveStop()
    -- end
end

-- Runtime 事件
function DefaultGame:enterFrame(e)
    -- local dt = e.time - self.lastTime
    -- e.deltaTime = dt
    -- self.lastTime = e.time

    -- local ctx = self.ctx
    -- local car = ctx.car
end

function DefaultGame:getin(rootCtx, rootRole)
    -- rootCtx.game:sigRegister("button_touch", function(e)
    --     self:buttonTouch(e)
    -- end)
    -- rootCtx.camera:setFocus(self.ladderTruck:getChassis(), 0.01, function()
    --     self:setCarControllable(true)
    -- end)
    -- self.ladderTruck:take(rootRole)
end

function DefaultGame:getout(rootCtx, rootRole)
    -- self:setCarControllable(false)
    -- local sx, sy = rootRole:getAnchor():localToContent(0, 0)
    -- rootCtx.levelLoader.player:insert(rootRole)
    -- rootRole:setPosition(sx, sy)
    -- self.ladderTruck:takeoff(rootRole)
end

-- function DefaultGame:onClearBefore()
-- end

return DefaultGame
