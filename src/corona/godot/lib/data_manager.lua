local function pkgImport(path, name, level)
    return require(path:match("^(.+)%.[^%.]+") .. '.' .. name)
end

local Data = {}
local json = require("json")
local FileUtils = pkgImport(..., "file_util")

function Data:read( _name, baseDir )
	local rPath = system.pathForFile( _name, baseDir or system.DocumentsDirectory )
	local rfile = io.open( rPath, "rb")
	local data = ""
	if rfile then
		data = rfile:read( "*a" )
		io.close( rfile )
	end
	return data
end

function Data:write( _name, _string, baseDir )
	local path = system.pathForFile( _name, baseDir or system.DocumentsDirectory)
	local file = io.open( path, "wb" )
	if file then
		file:write( _string )
		io.close( file )
	end
end

function Data:loadJson(filename, baseDir)
	return self:jsonDecode(self:read(filename, baseDir))
end

function Data:loadJsonSafe(filename, baseDir, errorCallback)
	if FileUtils:exists(filename, baseDir) then
		return self:jsonDecode(self:read(filename, baseDir))
	else
		if errorCallback then return errorCallback() end
	end
end

function Data:jsonDecode(data)
	return json.decode( data )
end

return Data
