-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

--scene帮助类，用于快速引入ui相关的类库

local SceneHelper = {}

SceneHelper.composer = require( "composer" )


SceneHelper.composer.recycleOnSceneChange = true

-- local logger = import("system.logger"):new({ debugMode = false, name = "SceneHelper" })
local function attachEvents(scene)
    scene:addEventListener( "create", scene )
    scene:addEventListener( "show", scene )
    scene:addEventListener( "hide", scene )
    scene:addEventListener( "destroy", scene )
end

function SceneHelper.gotoScene(sceneInfo, effect )
    effect = effect or {}
    effect.params = {__sceneInfo = sceneInfo.params}
    SceneHelper.composer.gotoScene( sceneInfo.name, effect )
end

--创建MyScene实例，MyScene是Scene的简化类
-- MyScene的方法包括： onCreate, onHide, onShow, onDestroy，这些方法对应Scene的相应方法，并且只在用户定义才调用
function SceneHelper.createMyScene()
    local s = SceneHelper.composer.newScene()
    s.timerMgr = import("system.timer_manager"):new()
    s.transMgr = import("system.transition_manager"):new()
    -- s.signals  = import("game.signal"):new()
    s.paused   = false

    function s:create( event )
        if event.params ~= nil then
            self.info = event.params.__sceneInfo
        end
        if s.onCreate ~= nil then
            s:onCreate(event)
        end
    end

    function s:show( event )
        -- logger:debug("scene show " .. event.phase)
        if self.onShow ~= nil then
            self:onShow(event)
        end
    end

    function s:hide( event )
        -- logger:debug("scene hide " .. event.phase)
        if self.onHide ~= nil then
            self:onHide(event)
        end
        if event.phase == "will" then
            display.removeAllEvent(self.view)
            -- TouchManager.cleanUp()
            self.timerMgr:cancelAll()
            self.transMgr:cancelAll()
        end
    end

    function s:pause()
        self.timerMgr:pauseAll()
        self.transMgr:pauseAll()
    end

    function s:resume()
        self.timerMgr:resumeAll()
        self.transMgr:resumeAll()
    end

    function s:destroy( event )
        self.timerMgr:cancelAll()
        self.transMgr:cancelAll()

        if self.onDestroy ~= nil then
            self:onDestroy(self, event)
        end
    end

    function s:getScene()
        return s
    end

    attachEvents(s)

    return s

end

function SceneHelper.setGameBackScene(phase)
    local sceneName = ""
    local prev = SceneHelper.composer.getSceneName( phase )
    if prev:find("gallery") then
        sceneName = "gallery"
    elseif prev:find("select") then
        sceneName = "select"
    else
        sceneName = "home"
    end
    SceneHelper.composer.setVariable("gameBackScene", sceneName)
end

function SceneHelper.getGameBackScene()
    return SceneHelper.composer.getVariable("gameBackScene")
end

function SceneHelper.setVariable(variableName, value)
    SceneHelper.composer.setVariable(variableName, value)
end

function SceneHelper.getVariable(variableName)
    return SceneHelper.composer.getVariable(variableName)
end

return SceneHelper
