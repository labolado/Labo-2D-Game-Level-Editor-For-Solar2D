-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local LoaderManager = class("LoaderManager")

local lhTag = {
    start = 1,
    goal = 2,
    ground = 3,
    test = 6,
}
LoaderManager.static.lhTag = lhTag

function LoaderManager:initialize(parent)
	self.lhTag = lhTag
	self.loaders = {}
	self.allSprites = {}
	if parent then
		self.layer = display.newSubGroup(parent)
	else
		self.layer = display.newGroup()
	end
	self.background = display.newSubGroup(self.layer)
	self.backmost = display.newSubGroup(self.layer)
	self.behind = display.newSubGroup(self.layer)
	self.player = display.newSubGroup(self.layer)
	self.grounds = display.newSubGroup(self.layer)
	self.front = display.newSubGroup(self.layer)
	self.frontCover = display.newSubGroup(self.layer)
	self.foremost = display.newSubGroup(self.layer)
	-- self.balloons = display.newSubGroup(lloader.layer)
	self.carPosMark = nil
	self.endPosMark = nil
	self.hasTestTag = false
end

function LoaderManager:setLevelHelperTags(tag)
	self.lhTag = tag
end

function LoaderManager:addLoader(loader)
    loader.grounds = loader:batchWithUniqueName("road")--("road")

	local tags = loader:spritesWithTag(self.lhTag.start)
	if #tags > 0 then
	    self.carPosMark = tags[#tags]
	end
	tags = loader:spritesWithTag(self.lhTag.goal)
	if #tags > 0 then
	    self.endPosMark = tags[#tags]
	end

    local testTags = loader:spritesWithTag(self.lhTag.test)
    if #testTags > 0 then
        self.carPosMark = testTags[#testTags]
        self.hasTestTag = true
	    end

	local index = displayGroupIndexOf(loader.layer, loader.grounds)
	local allGroups = {}
	_.gEach(loader.layer, function(group, idx)
	    allGroups[idx] = group
	end)
	_.each(allGroups, function(group, idx)
	    if idx < index then
	        self.behind:insert(group)
	    elseif idx == index then
	        self.grounds:insert(group)
	    else
	        self.front:insert(group)
	    end
	end)
	_.push(self.allSprites, unpack(loader.allCoronaSprites))
	_.push(self.loaders, loader)
end

function LoaderManager:spriteWithUniqueName(name, loaderID)
	local sprites = loaderID.allCoronaSprites
	for i=1, #sprites do
		local obj = sprites[i]
		-- _D(obj.lhUniqueName)
		if obj.lhUniqueName == name then
			return obj
		end
	end
end

function LoaderManager:getAllSprites()
	local allSprites = {}
	for i=1, #self.loaders do
		local loader = self.loaders[i]
		local allCoronaSprites = loader.allCoronaSprites
		for j=1, #allCoronaSprites do
			allSprites[#allSprites + 1] = allCoronaSprites[j]
		end
	end
	return allSprites
end

function LoaderManager:removeSelf()
	_.each(self.loaders, function(loader)
	    loader:removeAllJoints()
	    loader:removeSelf()
	end)
	display.cleanGroup(self.layer)
	for k, v in pairs(self) do
	    self[k] = nil
	end
end

return LoaderManager
