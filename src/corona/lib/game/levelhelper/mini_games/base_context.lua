-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local TimerManager = import("system.timer_manager")
local TransitionManager = import("system.transition_manager")
local Signal = import("game.signal")
local t = {}

local function _extend(a, b)
	for k, v in pairs(b) do
		if (type(v) ~= "function") and (k ~= "next") and (k ~= "parent") then
			a[k] = v
		end
	end
	return a
end

local function _addMembers(ctx)
	ctx.physicsJoints = {}
	ctx.spineObjects = {}
	-- ctx.spines = {}
	ctx.allWater = {}
	ctx.weather = {}
	ctx.particles = {}
	ctx.physicsParticles = {}
	ctx.miniGames = {}
	ctx.insertedGames = {}
	ctx.counters = {}
	ctx.variables = {}
	ctx.enterFrames = {}
	ctx.npcs = {}
	-- ctx.drawLayers = {}
	-- ctx.dialogs = {}
	ctx.customSignal = ctx.customSignal or Signal:new()
	ctx.actionSignal = Signal:new()
end

local function _remove(ctx, name)
    local t = ctx[name]
    if t then
        for i=1, #t do
            t[i]:removeSelf()
        end
    end
end

local function _clear(ctx)
	local loader = ctx.currentLoader
	table.removeElement(ctx.levelLoader.loaders, loader)
	if ctx.parser then
		ctx.parser:removeSelf()
	end
	if ctx.parent then
		ctx.parent.next = ctx.next
	end
	if ctx.next then
		ctx.next.parent = ctx.parent
	end

	-- clear loader
	local allCoronaGroups = loader.allCoronaGroups
	for i=1, #allCoronaGroups do
		display.cleanGroup(allCoronaGroups[i])
	end
	loader:removeSelf()
	for k, v in pairs(loader) do
	    loader[k] = nil
	end

	ctx.root = nil
	ctx.parent = nil
	ctx.next = nil
	ctx.parser = nil
	ctx.game = nil
	ctx.car = nil
	-- for k, v in pairs(ctx) do
	-- 	ctx[k] = nil
	-- end
end

local function _onClearBefore(ctx)
	-- clear trigger listener
	if ctx.car then
		ctx.car:clearCollisionCallBack()
	end

	-- clear physics
	local loader = ctx.currentLoader
	local allCoronaSprites = loader.allCoronaSprites
	_remove(ctx, physicsJoints)
	ctx.physicsJoints = nil
	loader:removeAllJoints()
	for i=1, #allCoronaSprites do
		local child = allCoronaSprites[i]
		if child.bodyType then
			physics.removeBody(child)
		end
	end

	ctx.game:onClearBefore()
end

function t:new(ctx, id)
	-- local c = _.extend({}, ctx)
	local c = _extend({}, ctx)
	_addMembers(c)
	c.id = id
	c.root = (ctx.root == nil) and ctx or ctx.root

	local last = ctx
	while (last.next ~= nil) do
		last = last.next
	end
	last.next = c
	c.parent = last

	c.clear = _clear
	c.onClearBefore = _onClearBefore
	return c
end

return t
