-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.


local Helper = {}

local function encodeActionsInfo(actionStr)
	local str = actionStr:gsub("%s", '')
    local t = {}
    local i = 1
    local newStr = string.gsub(str, "%b{}", function(v)
    	local m = ("{%d}"):format(i)
    	t[i] = v
    	i = i + 1
		return m
    end)
    return newStr, t
end

local function decodeActionInfo(str, t)
    local m = str:match("{(%d+)}")
    local newStr = str
    if m ~= nil then
       newStr = str:gsub(str, t[tonumber(m)])
    end
    return newStr
end

local function getActionTarget(ctx, lhObject, targetName)
	local target = lhObject
	if targetName then
	    local customTarget = Helper.findLevelObject(ctx, targetName, lhObject.loaderID)
	    assert(customTarget ~= nil, "target " .. tostring(targetName) .. " not exist in " .. tostring(lhObject.levelName) .. " (!" .. tostring(lhObject.lhUniqueName) .. ")")
	    target = customTarget or lhObject
	end
	return target
end

function Helper.clearTargetJoint(ctx, target)
	local found = _.find(ctx.physicsJoints, function(joint)
	    if joint.target == target then
	        return true
	    end
	    return false
	end)
	if found then
	    found:removeSelf()
	    table.remove(ctx.physicsJoints, found)
	end
end

function Helper.findTargetJoint(ctx, target)
	return _.find(ctx.physicsJoints, function(joint)
	    if joint.target == target then
	        return true
	    end
	    return false
	end)
end

function Helper.getVariable(ctx, name)
	local variable = name
    if variable:match("^%$") then
        variable = ctx.variables[variable:gsub("^%$", "")]
    end
    return variable
end

function Helper.setVariable(ctx, name, value)
    if name:match("^%$") then
        ctx.variables[name:gsub("^%$", "")] = value
    end
end

function Helper.findLevelObject(ctx, name, loaderID)
	local lhName = name
    if lhName:match("^%$") then
        lhName = ctx.variables[lhName:gsub("^%$", "")]
    end
    -- if loaderID then
    -- 	return loaderID:getSpriteByUniqueName(lhName)
    -- end
	return ctx.levelLoader:spriteWithUniqueName(lhName, loaderID)
end

function Helper.createAction(ctx, str, lhObject, opts)
	local newStr, encodeInfo = encodeActionsInfo(str)
	-- local actPropeties = _.split(newStr, ",")
	local actPropeties = newStr:fastSplit("[^,]+")
    local properties = {}
    for i=2, #actPropeties do
        local key, value = actPropeties[i]:match("(.*)=(.*)")
        if key ~= nil and value ~= nil then
            properties[key] = decodeActionInfo(value, encodeInfo)
        end
    end
	local ActionManager = import("game.levelhelper.action_manager")
    local target = getActionTarget(ctx, lhObject, properties.target)
    properties.hasTargetProp = (properties.target ~= nil)
    properties.targetAltering = not (target == lhObject)
    local act = ActionManager.create(ctx, actPropeties[1], target, _.extend(properties, opts) )
    return act
end

function Helper.runAction(ctx, str, target, opts)
	local act = Helper.createAction(ctx, str, target, opts)
	return act:execute()
end

function Helper.createActions(ctx, str, lhObject, opts)
	local acts = {}
    local newActionStr, encodeInfo = encodeActionsInfo(str)
    -- local actions = _.split(newActionStr, ";")
	local actions = newActionStr:fastSplit("[^;]+")
	local ActionManager = import("game.levelhelper.action_manager")
    for i=1, #actions do
    	local actionStr = actions[i]
    	_D("helper:", actionStr)
    	-- local actPropeties = _.split(actionStr, ",")
		local actPropeties = actionStr:fastSplit("[^,]+")
    	local properties = {}
    	for j=2, #actPropeties do
	        local key, value = actPropeties[j]:match("(.*)=(.*)")
	        if key ~= nil and value ~= nil then
	            properties[key] = decodeActionInfo(value, encodeInfo)
	        end
    	end

    	local target = getActionTarget(ctx, lhObject, properties.target)
	    properties.hasTargetProp = (properties.target ~= nil)
	    properties.targetAltering = not (target == lhObject)
	    local act = ActionManager.create(ctx, actPropeties[1], target, _.extend(properties, opts) )
	    acts[#acts + 1] = act
    end
    return acts
end

function Helper.runActions(ctx, str, target, opts)
	local acts = Helper.createActions(ctx, str, target, opts)
	for i=1, #acts do
		acts[i]:execute()
	end
end

function Helper.parseAndRun(ctx, order, target, opts)
	if type(order) == "function" then
		order(opts)
	else
		local str = order:match("{(.*)}")
		if str then
			local acts = Helper.createActions(ctx, str, target, opts)
			for i=1, #acts do
				acts[i]:execute()
			end
		end
	end
end

function Helper.onActionComplete(ctx, act)
	if type(act.extension) == "table" then
		local onComplete = act.extension.onComplete
		local typename = type(onComplete)
		if typename == "string" then
			-- local str = onComplete:gsub("[{}]", "")
			-- Helper.runActions(ctx, str, act.target)
			Helper.parseAndRun(ctx, onComplete, act.target)
		elseif typename == "function" then
			onComplete()
		end
	end
end

function Helper.getNpcCarByExtension(ctx, act)
	if type(act.extension) == "table" then
		local npc = act.extension.npc
		local typename = type(npc)
		if typename == "string" then
			local npcTarget = Helper.findLevelObject(ctx, npc, act.target.loaderID)
			return ctx.npcs[npcTarget]
		elseif typename == "table" then
			return ctx.npcs[npc]
		end
	end
end

function Helper.getNpcCarBodyByExtension(ctx, act)
	local npc = Helper.getNpcCarByExtension(ctx, act)
	if npc then
		return npc.train:getBody()
	end
end

function Helper.getNpcCarBodyByTarget(ctx, target)
	local npc = ctx.npcs[target]
	if npc then
		return npc.train:getBody()
	end
end

function Helper.findMiniGame(ctx, obj)
	local loaderID = obj.target.loaderID
	-- if _G["obj"] then
	-- 	print('SURPRISE: !!!')
	-- end
	return Helper.findMiniGameByLoaderID(ctx, loaderID)
end

function Helper.findMiniGameByTarget(ctx, target)
	return Helper.findMiniGameByLoaderID(ctx, target.loaderID)
end

function Helper.findContext(ctx, targetName, loaderID)
	local target = Helper.findLevelObject(ctx, targetName, loaderID)
	local rootCtx = ctx.root or ctx
	local last = rootCtx
	_D("!-> Helper.findContext: ", targetName, "start:", last, "target:", target)
	while last do
		_D("id: ", last.id)
		if type(last.id) == "table" then _D(last.id.name or last.id.lhUniqueName) end
		if last.id == target then
			break
		end
		last = last.next
	end
	_D("!-> Helper.findContext: ", targetName, "end:", last, "target:", target)
	return last
end


function Helper.findMiniGameByLoaderID(ctx, loaderID)
	local miniGames = ctx.miniGames
	local game
	for i=1, #miniGames do
		local g = miniGames[i]
		if g.id == loaderID then
			game = g
			break
		end
	end
	-- if obj == nil or obj.id == nil or obj.id == "" then
	-- else
	-- 	local insertedGames = ctx.insertedGames
	-- 	for i=1, #insertedGames do
	-- 		local g = insertedGames[i]
	-- 		if g.triggerID == obj.id then
	-- 			game = g
	-- 			break
	-- 		end
	-- 	end
	-- end
	return game
end

function Helper.findGameByID(ctx, obj)
	local game
	local insertedGames = ctx.insertedGames
	for i=1, #insertedGames do
		local g = insertedGames[i]
		if g.triggerID == obj.id then
			game = g
			break
		end
	end
	return game
end

local function randomUnique(numStart, numEnd, except)
	local random = math.random
    local r = random(numStart, numEnd)
    while table.indexOf(except, r) do
        r = random(numStart, numEnd)
    end
    return r
end

local function randomSomeUnique(numStart, numEnd, count, except)
    local except1 = except or{}
    local result  = {}
    for i=1, count do
        local first  = randomUnique(numStart, numEnd, except1)
        except1[#except1 + 1] = first
        result[i] = first
    end
    return result
end
Helper.randomSomeUnique = randomSomeUnique


return Helper
