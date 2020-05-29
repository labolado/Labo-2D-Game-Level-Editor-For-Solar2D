--local allen = require("lib.text.allen")
---- 查找字符串中匹配pattern的子串个数
--function numOfPatternMatch( str, pattern )
--    local count = 0
--    local find = function(s)
--        count = count + 1
--    end
--    string.gsub( str, pattern, find )
--
--    return count
--end
--
--string.numOfPatternMatch = numOfPatternMatch
--string.capFirst = allen.capitalizeFirst
--string.capEach = allen.capitalizesEach
--string.caps = allen.capitalizesEach
--string.cap = allen.capitalize
--string.isLower = allen.isLowerCase
--string.isUpper = allen.isUpperCase
--string.startsLower = allen.startsLowerCase
--string.startsUpper = allen.startsUpperCase
--string.split = allen.chop
--string.trim = allen.clean
--string.esc = allen.escape
--string.subst = allen.substitute
--string.interpolate = allen.substitute
--string.isNum = allen.isNumeric
--string.charAt = allen.index
--string.next = allen.succ
--string.numFmt = allen.numberFormat
--string.rjust = allen.lpad
--string.ljust = allen.rpad
--string.center = allen.lrpad
--
--



-- =============================================================
-- Copyright The Doppler FX. 2012-2013
-- =============================================================
-- Math
-- =============================================================
-- Short and Sweet License:
-- 1. You may use anything you find in the CoronaFX library and sampler to make apps and games for free or $$.
-- 2. You may not sell or distribute CoronaFX or the sampler as your own work.
-- 3. If you intend to use the art or external code assets, you must read and follow the licenses found in the
--    various associated readMe.txt files near those assets.
--
-- Credit?:  Mentioning CoronaFX library and/or The Doppler FX. in your credits is not required, but it would be nice.  Thanks!
--
-- =============================================================
-- This module provides additional math helpers / functions
-- ================================================================================
-- =============================================================
-- Docs: https://thedopplerfx.com/dev/CoronaFX/wiki
-- =============================================================

--if( not _G.fx.string ) then
--    _G.fx.string = {}
--end
local stringLib = {}
local __string_find = string.find

function string:subString(from, to)
    return string.sub(self, from, to)
end
-- ==
--    string:replace(search, replace) - returns the string with the replacement
-- ==
function string:replace(search, replace)
    return string.gsub(self, search, replace)
end

-- ==
--    string:startWith(start) - returns true the the string starts with the given string
-- ==
function string:startWith(starts)
    return string.sub(self, 1, string.len(starts))==starts
end

-- ==
--    string:startWith( string, start ) - returns true the the string ends with the given string
-- ==
function string:endWith(ends)
    return ends=='' or string.sub(self, -string.len(ends))==ends
end

-- ==
--    string:split( tok ) - Splits token (tok) separated string into integer indexed table.
-- ==
function string:split(tok)
    local str = self
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local ftok = "(.-)" .. tok
    local last_end = 1
    local s, e, cap = str:find(ftok, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t,cap)
        end
        last_end = e+1
        s, e, cap = str:find(ftok, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end

function string:fastSplit(pattern)
    local t = {}
    for str in self:gmatch(pattern) do
        t[#t + 1] = str
    end
    return t
end

-- ==
--    string:getWord( index ) - Gets indexed word from string, where words are separated by a single space (' ').
-- ==
function string:getWord( index )
    local index = index or 1
    local aTable = self:split(" ")
    return aTable[index]
end

-- ==
--    string:getWordCount( ) - Counts words in a string, where words are separated by a single space (' ').
-- ==
function string:getWordCount( )
    local aTable = self:split(" ")
    return #aTable
end

-- ==
--    Words are separated by a single space (' ') - Gets indexed words from string, starting at index and ending at endindex or end of line if not specified.
-- ==
function string:getWords( index, endindex )
    local index = index or 1
    local offset = index - 1
    local aTable = self:split(" ")
    local endindex = endindex or #aTable

    if(endindex > #aTable) then
        endindex = #aTable
    end

    local tmpTable = {}

    for i = index, endindex do
        tmpTable[i-offset] = aTable[i]
    end

    local tmpString = table.concat(tmpTable, " ")

    return tmpString
end

-- ==
--    string:setWord( index , replace ) - Replaces indexed word in string with replace, where words are separated by a single space (' ').
-- ==
function string:setWord( index, replace )
    local index = index or 1
    local aTable = self:split(" ")
    aTable[index] = replace
    local tmpString = table.concat(aTable, " ")
    return tmpString
end


-- ==
--    string:getField( index ) - Gets indexed field from string, where fields are separated by a single TAB ('\t').
-- ==
function string:getField( index )
    local index = index or 1
    local aTable = self:split("\t")
    return aTable[index]
end

-- ==
--    string:getFieldCount( ) - Counts fields in a string, where fields are separated by a single TAB ('\t').
-- ==
function string:getFieldCount( )
    local aTable = self:split("\t")
    return #aTable
end

-- ==
--    string:getFields( index [, endIndex ] ) - Gets indexed fields from string, starting at index and ending at endindex or end of line if not specified.
-- ==
function string:getFields( index, endindex )
    local index = index or 1
    local offset = index - 1
    local aTable = self:split("\t")
    local endindex = endindex or #aTable

    if(endindex > #aTable) then
        endindex = #aTable
    end

    local tmpTable = {}

    for i = index, endindex do
        tmpTable[i-offset] = aTable[i]
    end

    local tmpString = table.concat(tmpTable, "\t")

    return tmpString
end

-- ==
--    string:setField( index , replace ) - Replaces indexed field in string with replace, where fields are separated by a single TAB ('\t').
-- ==
function string:setField( index, replace )
    local index = index or 1
    local aTable = self:split("\t")
    aTable[index] = replace
    local tmpString = table.concat(aTable, "\t")
    return tmpString
end

-- ==
--    string:getRecord( index ) - Gets indexed record from string, where records are separated by a single NEWLINE ('\n').
-- ==
function string:getRecord( index )
    local index = index or 1
    local aTable = self:split("\n")
    return aTable[index]
end

-- ==
--    string:getRecordCount( ) - Counts records in a string, where records are separated by a single NEWLINE ('\n').
-- ==
function string:getRecordCount( )
    local aTable = self:split("\n")
    return #aTable
end

-- ==
--    string:getRecords( index [, endIndex ] ) - Gets indexed records from string, starting at index and ending at endindex or end of line if not specified.
-- ==
function string:getRecords( index, endindex )
    local index = index or 1
    local offset = index - 1
    local aTable = self:split("\n")
    local endindex = endindex or #aTable

    if(endindex > #aTable) then
        endindex = #aTable
    end

    local tmpTable = {}

    for i = index, endindex do
        tmpTable[i-offset] = aTable[i]
    end

    local tmpString = table.concat(tmpTable, "\n")

    return tmpString
end

-- ==
--    string:setRecord( index , replace ) - Replaces indexed record in string with replace, where records are separated by a single NEWLINE ('\n').
-- ==
function string:setRecord( index, replace )
    local index = index or 1
    local aTable = self:split("\n")
    aTable[index] = replace
    local tmpString = table.concat(aTable, "\n")
    return tmpString
end

function string:urlEncode()
     s = self
     s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

function string:urlDecode()
    s = self
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

-- ==
--    string:spaces2underbars( ) - Replaces all instances of spaces with underbars.
-- ==
function string:spaces2underbars( )
    return self:gsub( "%s", "_" )
end

-- ==
--    string:underbars2spaces( ) - Replaces all instances of underbars with spaces.
-- ==
function string:underbars2spaces( )
    return self:gsub( "_", " " )
end

-- ==
--    string:printf( ... ) - Replicates C-language printf().
-- ==
function string:printf(...)
    return io.write(self:format(...))
end -- function

-- ==
--    string:lpad( len, char ) - Places padding on left side of a string, such that the new string is at least len characters long.
-- ==
function string:lpad (len, char)
    local theStr = self
    if char == nil then char = ' ' end
    return string.rep(char, len - #theStr) .. theStr
end

-- ==
--    string:rpad( len, char ) - Places padding on right side of a string, such that the new string is at least len characters long.
-- ==
function string:rpad(len, char)
    local theStr = self
    if char == nil then char = ' ' end
    return theStr .. string.rep(char, len - #theStr)
end

---- ==
----    utf8charbytes(s, i) - returns the number of bytes used by the UTF-8 character at byte i in s
----      also doubles as a UTF-8 character validator
---- ==
--function stringLib.utf8charbytes(s, i)
--    -- argument defaults
--    i = i or 1
--    local c = string.byte(s, i)
--
--    -- determine bytes needed for character, based on RFC 3629
--    if c > 0 and c <= 127 then
--        -- UTF8-1
--        return 1
--    elseif c >= 194 and c <= 223 then
--        -- UTF8-2
--        local c2 = string.byte(s, i + 1)
--        return 2
--    elseif c >= 224 and c <= 239 then
--        -- UTF8-3
--        local c2 = s:byte(i + 1)
--        local c3 = s:byte(i + 2)
--        return 3
--    elseif c >= 240 and c <= 244 then
--        -- UTF8-4
--        local c2 = s:byte(i + 1)
--        local c3 = s:byte(i + 2)
--        local c4 = s:byte(i + 3)
--        return 4
--    end
--end
--
---- ==
----    utf8len(s) - returns the number of characters in a UTF-8 string
---- ==
--function stringLib.utf8len(s)
--    local pos = 1
--    local bytes = string.len(s)
--    local len = 0
--
--    while pos <= bytes and len ~= chars do
--        local c = string.byte(s,pos)
--        len = len + 1
--
--        pos = pos + stringLib.utf8charbytes(s, pos)
--    end
--
--    if chars ~= nil then
--        return pos - 1
--    end
--
--    return len
--end
--
---- ==
----    utf8sub(s, i, j) - functions identically to string.sub except that i and j are UTF-8 characters
----    instead of bytes
---- ==
--function stringLib.utf8sub(s, i, j)
--    j = j or -1
--
--    if i == nil then
--        return ""
--    end
--
--    local pos = 1
--    local bytes = string.len(s)
--    local len = 0
--
--    -- only set l if i or j is negative
--    local l = (i >= 0 and j >= 0) or stringLib.utf8len(s)
--    local startChar = (i >= 0) and i or l + i + 1
--    local endChar = (j >= 0) and j or l + j + 1
--
--    -- can't have start before end!
--    if startChar > endChar then
--        return ""
--    end
--
--    -- byte offsets to pass to string.sub
--    local startByte, endByte = 1, bytes
--
--    while pos <= bytes do
--        len = len + 1
--
--        if len == startChar then
--            startByte = pos
--        end
--
--        pos = pos + stringLib.utf8charbytes(s, pos)
--
--        if len == endChar then
--            endByte = pos - 1
--            break
--        end
--    end
--    return string.sub(s, startByte, endByte)
--end

-- complex funcs
function string:charAt(index) -- Int -> String
    return __string_sub(self, index+1, index+1)
end

function string:charCodeAt(index) -- Int -> Null<Int>
    return __string_byte(__string_sub(self, index+1, index+1))
end

function string:indexOf(str, startIndex) -- String -> ?Int -> Int
    local r = string.find(self, str, startIndex, true)
    return r and (r - 1) or nil
end

-- TODO startIndex
function string:lastIndexOf(str, startIndex) -- String -> ?Int -> Int
    local i, j
    local k = 0
    repeat
        i = j
        j, k = __string_find(self, str, k + 1, true)
        until j == nil

    local ret =  (i or 0) - 1
    if ret == -1 then
        return nil
    end
    return ret
end

---- ==
----    utf8replace(s, mapping) - replace UTF-8 characters based on a mapping table
----    instead of bytes
---- ==
--function stringLib.utf8replace(s, mapping)
--    local pos = 1
--    local bytes = string.len(s)
--    local charbytes
--    local newstr = ""
--
--    while pos <= bytes do
--        charbytes = stringLib.utf8charbytes(s, pos)
--        local c = string.sub(s, pos, pos + charbytes - 1)
--        newstr = newstr .. (mapping[c] or c)
--        pos = pos + charbytes
--    end
--
--    return newstr
--end
