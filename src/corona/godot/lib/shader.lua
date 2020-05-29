local function currentPackage(path)
    return path:match("^(.+)%.[^%.]+")
end

local _currenPath = currentPackage(...)

local shader = {}

local function lf(category, name)
	local kernel = require(_currenPath .. ".shaders." .. category .. ".".. name)
	graphics.defineEffect( kernel )
	return category .. ".custom." ..name
end

local function lfg(category, name)
	local kernelGenerator =  require(_currenPath .. ".shaders." .. category .. ".".. name)
	local kernel = kernelGenerator:create(shader)
	graphics.defineEffect( kernel )
	return category .. ".custom." ..name
end

local function lff(name)
	return lf("filter", name)
end

local function lfc(name)
	return lf("composite", name)
end

shader.filters = {
	tiling = lff("tiling"),
}

shader.composites = {
}

return shader
