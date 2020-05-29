local lfs = require "lfs"

local FileUtil = {}

local GGFile = {
    Attribute = {
        Dev          = "dev",
        Ino          = "ino",
        Mode         = "mode",
        Nlink        = "nlink",
        Uid          = "uid",
        Gid          = "gid",
        Rdev         = "rdev",
        Access       = "access",
        Modification = "modification",
        Change       = "change",
        Size         = "size",
        Blocks       = "blocks",
        Blksize      = "blksize",
    }
}

function FileUtil:fileExists( fname, path )
    local exists = false

    local filePath = system.pathForFile( fname, path )

    if ( filePath ) then
        filePath = io.open( filePath, "r" )
    end

    if ( filePath ) then
        -- print( "File found: " .. fname )
        filePath:close()
        exists = true
    else
        -- print( "File dos not exist: " .. fname )
    end

    return exists
end

function FileUtil:newAFloder( name, baseDir, systemBaseDir )
    local baseDir = baseDir or ""

    -- get raw path to app's Temporary directory
    local temp_path = system.pathForFile( baseDir, systemBaseDir or system.DocumentsDirectory )

    -- change current working directory
    local success = lfs.chdir( temp_path ) -- returns true on success

    -- local new_folder_path
    if success then
        lfs.mkdir( name )
        -- new_folder_path = lfs.currentdir() .. "/" .. name
    end
end


function FileUtil:dirExists( name, systemBaseDir )
    local temp_path = system.pathForFile( name, systemBaseDir or system.DocumentsDirectory )
    local success = lfs.chdir( temp_path )
    if success then
        return true
    else
        return false
    end
end


function FileUtil:dirRecursive(folderName, systemBaseDir)
    local name = string.match( folderName, "(.*)/$" )
    folderName = name or folderName
    local path = system.pathForFile( folderName, systemBaseDir )
    local t = {}
    local subfolderList = {}
    subfolderList[#subfolderList + 1] = folderName
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local name = file
            if folderName:len() > 0 then
                name = folderName .. "/" .. file
            end
            if self:isDirectory( name, systemBaseDir) then
                local newt, newSub = self:dirRecursive(name, systemBaseDir)
                for i=1, #newt do
                    t[#t + 1] = newt[i]
                end

                for i=1, #newSub do
                    subfolderList[#subfolderList + 1] = newSub[i]
                end
            else
                t[#t + 1] = name
            end
        end

    end
    return t, subfolderList
end

function FileUtil:removeDirRecursive( dirName, systemBaseDir, deleteChildrenOnly )
    local baseDir = systemBaseDir or system.DocumentsDirectory
    if self:isDirectory(dirName, baseDir) then
        local t, subfolderList = self:dirRecursive(dirName, baseDir)
        for i=1, #t do
            os.remove( system.pathForFile(t[i], baseDir) )
            -- print(t[i])
        end
        lfs.chdir( system.pathForFile("", baseDir) )
        local endNum = 1
        if deleteChildrenOnly then endNum = endNum + 1 end
        for i = #subfolderList, endNum, -1 do
            -- print(subfolderList[i])
            lfs.rmdir( system.pathForFile(subfolderList[i], baseDir) )
        end
    elseif self:exists(dirName, baseDir) then -- Delete file directly
        os.remove(system.pathForFile(dirName, baseDir))
    end
end


--- Reads data from a file.
-- @param path The path to the file.
-- @param baseDir The base directory for the path, optional and defaults to system.DocumentsDirectory.
-- @return The read in content.
function FileUtil:read( path, baseDir )

    path = system.pathForFile( path, baseDir or system.DocumentsDirectory )

    local file = io.open( path, "rb" )

    if file then
        local data = file:read( "*a" )
        io.close( file )
        return data
    end

end

--- Retrieves the lines from a file and returns them in a list.
-- @param path The path to the file.
-- @param baseDir The base directory for the path, optional and defaults to system.DocumentsDirectory.
-- @return A list of lines read in.
function FileUtil:readLines( path, baseDir )

    path = system.pathForFile( path, baseDir or system.DocumentsDirectory )

    local file = io.open( path, "r" )

    if file then

        local lines = {}

        for line in file:lines() do
            lines[ #lines + 1 ] = line
        end

        io.close( file )

        return lines

    end

end

--- Writes data to a file.
-- @param path The path to the file.
-- @param data The date to write.
-- @param baseDir The base directory for the path, optional and defaults to system.DocumentsDirectory.
function FileUtil:write( path, data, baseDir )

    path = system.pathForFile( path, baseDir or system.DocumentsDirectory )

    local file = io.open( path, "wb" )

    if file then
        file:write( data )
        io.close( file )
        file = nil
    end

end

--- Appends data to a file.
-- @param path The path to the file.
-- @param data The date to write.
-- @param baseDir The base directory for the path, optional and defaults to system.DocumentsDirectory.
function FileUtil:append( path, data, baseDir )

    path = system.pathForFile( path, baseDir or system.DocumentsDirectory )

    local file = io.open( path, "a" )

    if file then
        file:write( data )
        io.close( file )
        file = nil
    end

end

--- Deletes a file.
-- @param path The path to the file.
-- @param baseDir The base directory for the path, optional and defaults to system.DocumentsDirectory.
-- @return True if it was removed or nil and a reason if not.
function FileUtil:delete( path, baseDir )
    path = system.pathForFile( path, baseDir or system.DocumentsDirectory )
    return os.remove( path )
end

--- Copies a file.
-- @param sourcePath The path to the source file.
-- @param sourceBaseDir The base directory for the source path, optional and defaults to system.DocumentsDirectory.
-- @param destinationPath The path to the destination file.
-- @param destinationBaseDir The base directory for the destination path, optional and defaults to system.DocumentsDirectory.
function FileUtil:copy( sourcePath, sourceBaseDir, destinationPath, destinationBaseDir )
    local data = self:read( sourcePath, sourceBaseDir )
    self:write( destinationPath, data, destinationBaseDir )
end

--- Moves a file.
-- @param sourcePath The path to the source file.
-- @param sourceBaseDir The base directory for the source path, optional and defaults to system.DocumentsDirectory.
-- @param destinationPath The path to the destination file.
-- @param destinationBaseDir The base directory for the destination path, optional and defaults to system.DocumentsDirectory.
function FileUtil:move( sourcePath, sourceBaseDir, destinationPath, destinationBaseDir )
    self:copy( sourcePath, sourceBaseDir, destinationPath, destinationBaseDir )
    self:delete( sourcePath, sourceBaseDir )
end

--- Renames a file.
-- @param path The path to the file.
-- @param newName The new name for the file.
-- @param baseDir The base directory for the path, optional and defaults to system.DocumentsDirectory.
-- @return True if it was renamed or nil and a reason if not.
function FileUtil:rename( path, newName, baseDir )
    path = system.pathForFile( path, baseDir or system.DocumentsDirectory )
    newName = system.pathForFile( newName, baseDir or system.DocumentsDirectory )
    return os.rename( path, newName )
end

--- Checks if a file exists.
-- @param path The path to the file.
-- @param baseDir The base directory for the path, optional and defaults to system.DocumentsDirectory.
-- @return True if it exists, false otherwise.
function FileUtil:exists( path, baseDir )
    local mode = self:getAttributes( path, GGFile.Attribute.Mode, baseDir )
    return mode == "file" or mode == "directory"
end

--- Checks if a file is a directory.
-- @param path The path to the file.
-- @param baseDir The base directory for the path, optional and defaults to system.DocumentsDirectory.
-- @return True if the file is a directory and false if it isn't or if it doesn't exist.
function FileUtil:isDirectory( path, baseDir )
    return self:getAttributes( path, GGFile.Attribute.Mode, baseDir ) == "directory"
end

--- Returns a list of all files in a directory.
-- @param path The path to the directory.
-- @param baseDir The base directory for the path, optional and defaults to system.DocumentsDirectory.
-- @return A list of all found files, empty if none found.
-- function FileUtil:getFilesInDirectory( path, baseDir )

--     path = system.pathForFile( path, baseDir or system.DocumentsDirectory )

--     if path then

--         local files = {}

--         for file in lfs.dir( path ) do

--             if file ~= "." and file ~= ".." and file ~= ".DS_Store" then
--                 files[ #files + 1 ] = file
--             end

--         end

--         return files

--     end

-- end


function FileUtil:getFilesInDirectory( path, baseDir, ext )
    if ext ~= nil then
        ext = string.upper(ext)
    end


    path = system.pathForFile( path, baseDir or system.DocumentsDirectory )

    if path then

        local files = {}

        for file in lfs.dir( path ) do

            if file ~= "." and file ~= ".." and file ~= ".DS_Store" and (ext == nil  or    string.upper(file):endWith(ext) ) then
                files[ #files + 1 ] = file
            end

        end

        return files

    end

end

--- Create a new directory.
-- @param path The path to the parent directory.
-- @param newDirectory The name/path of the new directory.
-- @param baseDir The base directory for the path, optional and defaults to system.DocumentsDirectory.
-- @return True if successful and false ( or nil ) otherwise as well as a reason.
function FileUtil:makeDirectory( path, newDirectory, baseDir )

    path = system.pathForFile( path, baseDir or system.DocumentsDirectory )

    if lfs.chdir( path ) then
        local success, reason = lfs.mkdir( newDirectory )
        return success, reason
    end

    return false, "Parent directory doesn't exist."

end

--- Removes an existing directory.
-- @param path The path to the directory.
-- @param baseDir The base directory for the path, optional and defaults to system.DocumentsDirectory.
-- @return True if successful and false ( or nil ) otherwise as well as a reason.
function FileUtil:removeDirectory( path, baseDir )

    path = system.pathForFile( path, baseDir or system.DocumentsDirectory )

    return lfs.rmdir( path )

end

--- Gets attributes of a file.
-- @param path The path to the file.
-- @param attribute The attribute to check for, optional. Can be any value from GGFile.Attribute. See this page for explanations - http://keplerproject.github.com/luafilesystem/manual.html#reference
-- @param baseDir The base directory for the path, optional and defaults to system.DocumentsDirectory.
-- @return A list of attributes or a single value if a specific attribute is asked for.
function FileUtil:getAttributes( path, attribute, baseDir )

    path = system.pathForFile( path, baseDir or system.DocumentsDirectory )

    if not path then
        return nil
    end

    return lfs.attributes( path, attribute )

end

----------- Add by bc ---------------
--- Create a new directory.
-- @param path The name/path of the new directory.
-- @param baseDir The base directory for the path, optional and defaults to system.DocumentsDirectory.
-- @return True if successful and false ( or nil ) otherwise as well as a reason.
function FileUtil:makeDirP( path, baseDir )
    path = string.match(path, "^/(.*)/$") or path
    local t = {}
    while path:find("/") do
        if self:isDirectory(path, baseDir) then
            break
        else
            t[#t + 1] = path
        end
        local rindex = path:reverse():find("/")
        path = path:sub(1, -rindex-1)
    end
    if not self:isDirectory(path, baseDir) then
        t[#t + 1] = path
    end

    for i=#t, 1, -1  do
        -- Log:debug("makeDirP ------> " .. t[i])
        local dirPath = system.pathForFile(t[i], baseDir or system.DocumentsDirectory)
        local success, reason = lfs.mkdir(dirPath)
        if not success then
            return success, reason
        end
    end

    return true
end

function FileUtil.pathinfo(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 then -- 47 = char "/"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

return FileUtil
