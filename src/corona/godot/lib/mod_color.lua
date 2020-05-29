-----------------------------
-- Color Handler  - v.0.4
-- Author : Aaron Wheeler
-- URL : https://bitbucket.org/awmods/mod_color/
-----------------------------

-- 使用示例
-- rec2:setFillColor( color.fromRGB( 187, 187, 187 ) )
-- rec3:setFillColor( unpack( color.fromHex("#FFCCFDD") ) )

local C = {}

local colorList = {}
--local json = require("json")

-- --- pass through a colorString in a and get a perecentage rgb value in return
-- function C.fromString( colorString )
-- 	assert( type(colorString) == "string", "fromString() requires a colorString to be passed in as a string")

-- 	if colorList[colorString] then
-- 		return colorList[colorString][1] / 255, colorList[colorString][2] / 255, colorList[colorString][3] / 255
-- 	else
-- 		print("invalid colorString please try another")
-- 	end
-- end

--- pass through a rgb value through and recieve a corona perentage value in return
function C.fromRGB(r, g, b)
	local function checkValue(value)
		assert(type(value) == "number", "fromRGB needs value passed as a number")
		assert(value > 0 and value < 255 , "value " .. value ..  " is not in the range 0 - 255")
	end

	checkValue(r); checkValue(g); checkValue(b)

	return r / 255, g / 255, b /255
end

-- ==
--    	fromHex(  ) - converts hex color codes to rgba Graphics 2.0 values by roamingGamer
-- 		source : http://forums.coronalabs.com/topic/52740-is-it-a-tool-to-find-easily-a-color/
-- ==
function C.fromHex( hex )
	assert( type(hex) == "string", "fromHex requires a hex value passed in as a string")

	hex = string.gsub( hex , "#", "") or "FFFFFFFF"
	hex = string.gsub( hex , " ", "")
	-- local colors = {1,1,1,1}
	while hex:len() < 8 do
	  hex = hex .. "F"
	end
	local r = tonumber("0X" .. string.sub( hex, 1, 2 ))
	local g = tonumber("0X" .. string.sub( hex, 3, 4 ))
	local b = tonumber("0X" .. string.sub( hex, 5, 6 ))
	local a = tonumber("0X" .. string.sub( hex, 7, 8 ))
	local colors = { r/255, g/255, b/255, a/255  }
	return colors
end

--- returns a random color to you in the form of Graphics 2.0 values
function C.random()
	local a = math.random( )
	local b = math.random( )
	local c = math.random( )

	return a, b, c
end

function C.toHex(r, g, b, a)
	string.format("%x%x%x%x", r*255, g*255, b*255, a*255)
end

-- --- load and set a colorList from a json file.
-- function C:loadColorlistJSON(path, baseDirectory)
-- 	assert(path, "loadColorlistJSON needs a path defined.")
-- 	local path = system.pathForFile( path, baseDirectory or system.ResourceDirectory )

-- 	if path then

-- 		local file = io.open(path, "r")

-- 		if file then

-- 			local data = file:read("*a") or "{}"

-- 			local colors = json.decode( data ) or {}

-- 			self:setColorListLUA(colors)

-- 		end

-- 	end

-- end

--- load and set a colorList from a LUA table.
function C:setColorListLUA(table)
	assert(table, "lua Table needed for setColorListLUA")

	colorList = table
end

return C
