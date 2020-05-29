-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local GodotLoader = require("godot.godot_loader")
local CustomCLassParser = import("game.levelhelper.custom_class_parser")
local BaseContext = import("game.levelhelper.mini_games.base_context")
local ControllerBase = class("ControllerBase", Node)

local function _loadGodotLevel(level, options)
	local levelName = "assets/levels/export/" .. level .. ".json"
	local loader = GodotLoader:new(levelName)
	loader.layer = loader.view

	local offset = options.offset or { x = 0, y = 0 }
	if options.isPhysics then
		loader:addPhysics(offset.x, offset.y)
	end
	if options.startAllPaths then loader:startAllPaths() end

	function loader:destroy()
	end
	return loader
end

ControllerBase.static.godotlevelsDir = "assets/levels/export/"
function ControllerBase:initialize(game, controlledTargets, levelHelperUi, ...)
	self.game = game
	self.controlledTargets = controlledTargets
	self.levelHelperUiName = levelHelperUi
	-- self.context = {}
	-- self.context.transMgr = game.transMgr
	-- self.context.timerMgr = game.timerMgr
	-- self.context.levelLoader = {
	-- 	allSprites = {},
	-- 	spriteWithUniqueName = game.ctx.levelLoader.spriteWithUniqueName
	-- }
	self.context = BaseContext:new(game.ctx)
	self.components = {}
	self:init(...)
end

function ControllerBase:init()
	local ctx = self.context
	-- local levelLoader = ctx.levelLoader
	local parser = CustomCLassParser:new(ctx)
	ctx.parser = parser
	local options = { offset = { x = 0, y = 0}, isPhysics = true, startAllPaths = false  }
	-- Level:setLevelPath(ControllerBase.levelsDir, {spritesPath = ControllerBase.spritesDir})
	-- _D("ControllerBase ", self.levelHelperUiName)
	-- local loader = Level:loadLevel("ui/" .. self.levelHelperUiName, options)
	local loader = _loadGodotLevel("ui/" .. self.levelHelperUiName, options)
	local allCoronaSprites = loader.allCoronaSprites
    -- _.push(levelLoader.allSprites, unpack(allCoronaSprites))
    -- _.push(levelLoader.loaders, loader)
    parser:parseAndRegister(allCoronaSprites)

	local layer = loader.layer
	local ox, oy = display.getWorldPosition(layer)
	layer:translate(-ox, -oy)
	self:insert(layer)
	self.loader = loader

	local objects = self.controlledTargets
	for i=1, #allCoronaSprites do
		local bttn = allCoronaSprites[i]
		if bttn.ext_id then
			local slaves = {}
			-- _D("Controller ui init 1",  bttn.lhUniqueName)
			for j=1, #objects do
				local target = objects[j]
				if target.ext_id == bttn.ext_id then
					slaves[#slaves + 1] = target
					-- _D("Controller ui init 2", target.lhUniqueName, bttn.lhUniqueName)
     				self:initControl(bttn, target)
				end
			end
			bttn.slaves = slaves
		end
	end

	self:initPosition()
	self.isVisible = false
end

function ControllerBase:initControl(bttn, target)
	local ctx = self.context
	local bttnID = tostring(bttn)
	local targetID = tostring(target)
    ctx.customSignal.register("on_" .. bttnID .. "_button_press", function()
    	self.game:playerTrigger("on_" .. targetID .. "_button_press", target)
    	self.game:playerTrigger("on_" .. targetID .. "_player_trigger", target)
    end)
    ctx.customSignal.register("on_" .. bttnID .. "_button_release", function()
    	self.game:playerTrigger("on_" .. targetID .. "_button_release", target)
    end)
end

function ControllerBase:initPosition()
	self:translate(_R - self.contentWidth * 0.65, _B - self.contentHeight * 0.65)
	self.initPos = {self.x, self.y}
end

function ControllerBase:setPosition(x, y)
	self.x = x
	self.y = y
	self.initPos[1] = x
	self.initPos[2] = y
end

function ControllerBase:show()
	self.isVisible = true
	objectTransIn(self, {
		transMgr = self.game.transMgr,
		x = self.initPos[1],
		y = self.initPos[2]
	})
end


function ControllerBase:hide()
	objectTransOut(self, {
		transMgr = self.game.transMgr,
		-- x = _R + self.contentWidth * 0.6,
		y = _B + self.contentHeight * 0.85,
		-- delta = true
	})
end

function ControllerBase:onStart()
end

function ControllerBase:onStop()
	self:disableAll()
end

function ControllerBase:disableAll()
	for i=1, #self.components do
		self.components[i]:disable()
	end
end

function ControllerBase:enableAll()
	for i=1, #self.components do
		self.components[i]:enable()
	end
end

function ControllerBase:clearSelf()
	if self.loader then
	    self.context.parser:removeSelf()
	    self.context.parser = nil
		self.loader:removeAllJoints()
		self.loader:removeSelf()
		self.loader = nil
	end
	-- for i=1, #self.components do
	-- 	self.components[i]:disable()
	-- end
end

return ControllerBase
