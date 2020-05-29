local class = GodotGlobal.class
local type = type
local tostring = tostring

local GodotSpriteBase = class("GodotSpriteBase", function(info)
	local obj
	if info.res_path:find("/_tags") or info.res_path:find("/tags") then
		obj = display.newRect(0, 0, info.width, info.height)
		obj.isLevelTag = true
		obj.isVisible = false
	else
		if info.type == "animated_sprite" then
			if info.texture_type == "sprite_sheet" then
				local options = info.sheets
				local sequenceData = info.animations
				local imageSheet = graphics.newImageSheet(info.res_path, options)
				obj = display.newSprite(imageSheet, sequenceData)
				obj:setSequence(info.current)
				obj.timeScale = info.speed_scale
				if info.playing then
					obj:play()
				else
					obj:setFrame(info.frame + 1)
				end
			else
				local options = info.sheets
				local frame = options.frames[1]
				obj = display.newRect(0, 0, frame.width, frame.height)
			end
		else
			if type(info.region) == "table" then
				local region = info.region
				local options = {
				    frames =
				    {
				        {
				            x = region.x,
				            y = region.y,
				            width = info.width,
				            height = info.height
				        }
				    },
				    sheetContentWidth = region.cw,
				    sheetContentHeight = region.ch
				}
				local imageSheet = graphics.newImageSheet(info.res_path, options)
				obj = display.newImage(imageSheet, 1)
			else
				obj = display.newImageRect(info.res_path, info.width, info.height)
			end
		end
	end
	if type(obj._uniqueTableId) ~= "string" then
		obj._uniqueTableId = tostring(obj)
	end
	return obj
end)

function GodotSpriteBase.static.new(self, ...)
	local instance = self:allocate(...)
	instance:addEventListener("finalize")
	instance:initialize(...)
	return instance
end

function GodotSpriteBase:onRemove()
end

function GodotSpriteBase:finalize(e)
	-- _D(tostring(self.class) .. " removeSelf")
	self:onRemove()
    for k,v in pairs(self) do
    	if k:find("^_") == nil then
	    	self[k] = nil
	    end
    end
end

return GodotSpriteBase
