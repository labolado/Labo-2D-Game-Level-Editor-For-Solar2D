local GodotGlobal = {}

--@param path ...
local function currentPackage(path)
    return path:match("^(.+)%.[^%.]+")
end

--@param path ...
--@usage: pkgImport(..., "lib.file_util")
local function pkgImport(path, name, level)
    local n = level or 1
    local _PACKAGE = path
    for i=1, n do
        _PACKAGE = currentPackage(_PACKAGE)
    end
    return require(_PACKAGE .. '.' .. name)
end

local defaultOptions = setmetatable({}, {
    __newindex = function(t, k, v)
        -- donothing
    end})

local mathAbs = math.abs
local function equalToZero(value, accuracy)
    local accuracy = accuracy or 0.0000001
    if mathAbs(value - 0) < accuracy then
        return true
    end
    return false
end

local function clamp(value, min_inclusive, max_inclusive)
    return value < min_inclusive and min_inclusive or (value < max_inclusive and value or max_inclusive)
end

local Color = pkgImport(..., "lib.mod_color")

local function hexColor(hex)
    return Color.fromHex(hex)
end

local function uHexColor(hex)
    return unpack(Color.fromHex(hex))
end

local function log(...)
    local args = {"[GODOT]", ...}
    for i=1, #args do
        args[i] = tostring(args[i])
    end
    print(table.concat(args, ""))
end

pkgImport(..., "lib.display_ext")
pkgImport(..., "lib.table_ext")

GodotGlobal.DEFAULT_OPTIONS = defaultOptions
GodotGlobal.currentPackage = currentPackage
GodotGlobal.pkgImport = pkgImport
GodotGlobal.equalToZero = equalToZero
GodotGlobal.clamp = clamp
GodotGlobal.hexColor = hexColor
GodotGlobal.unpackHexColor = uHexColor
GodotGlobal.class = pkgImport(..., "lib.middleclass_ext")
GodotGlobal.DataManager = pkgImport(..., "lib.data_manager")
GodotGlobal.Vector = pkgImport(..., "lib.vector-light")
GodotGlobal.Shader = pkgImport(..., "lib.shader")
GodotGlobal._ = pkgImport(..., "lib.underscore")
GodotGlobal.log = log

return GodotGlobal
