--[[
	Compares two tables and returns true if they contain the same values, false if not.
	Does not do a deep comparison - only using pairs() function to retrieve keys.

	Parameters:
		a: first table to compare
		b: second table to compare

	Returns:
		true if both contain the same values
]]--
local function compare( a, b )
	for k,v in pairs(a) do
		if (a[k] ~= b[k]) then
			return false
		end
	end
	for k,v in pairs(b) do
		if (b[k] ~= a[k]) then
			return false
		end
	end
	return true
end
table.compare = compare

-- like table.copy except this copies entries returned by pairs()
-- multiple tables can be combined but beware of overwriting entries
table.clone = function( ... )
	local output = {}
	for i=1, #arg do
		for k,v in pairs(arg[i]) do
			output[ k ] = v
		end
	end
	return output
end

table.deepclone = function( tbl )
	local output = {}
	for k,v in pairs(tbl) do
		if (type(v) == "table") then
			output[k] = table.deepclone(v)
		else
			output[k] = v
		end
	end
	return output
end

-- returns a new table containing the elements of the passed table which the compare function returned true for
-- works with display groups
table.find = function( t, compare )
	local newT = {}
	local count = t.numChildren

	if (count == nil) then
		count = #t
	end

	for i=1, count do
		local item = t[i]
		if (compare(item)) then
			newT[#newT+1] = item
		end
	end

	return newT
end

-- if sep is a table its items are used as separators for table t
-- Example:
--local a,b = {1,3,5,7,9}, {2,4,6,8,10}
--print(table.concat(a,b))
-- prints 12345678910
local table_concat = table.concat
table.concat = function( t, sep, i, j )
	if (i == nil and j == nil and type(sep) == "table") then
		return strZip( t, sep )
	else
		return table_concat( t, sep, i, j )
	end
end

-- extends the table.indexOf to work with display groups
local _indexof = table.indexOf
table.indexOf = function( tbl, element )
	if (tbl.numChildren == nil) then
		return _indexof( tbl, element )
	else
		for i=1, tbl.numChildren do
			if (tbl[i] == element) then
				return i
			end
		end
		return nil
	end
end

-- returns shallow copy of table elements from index for count of size (or to end if size is nil)
table.range = function( tbl, index, size )
	if (index == nil or index < 1) then return nil end
	size = size or #tbl-index+1
	local output = {}
	for i=index, index+size-1 do
		output[i] = tbl[i]
		dump(tbl[i])
		dump(output[i])
	end
	return output
end

--[[
	Returns a range of values from the provided table, wrapping the copy when the end of the table is reached.
	Will also wrap multiple times making this a duplicating function.

	Parameters:
		tbl: Table to copy values from
		index: Start of the position to copy values from
		size: Number of values to copy, including the index position

	Returns:
		A copy of the tbl parameter table, wrapped at the end so that indices start from 1 when the end of the table is hit.

	Example:
		See the test_wraprange() function
]]--
table.wraprange = function( tbl, index, size )
	local out = {}
	while (size > 0) do
		out[#out+1] = tbl[index]
		index = index + 1
		if (index > #tbl) then index=1 end
		size = size - 1
	end
	return out
end

local function test_wraprange()
	local tbl = {1,2,3,4,5,6,7,8,9,10}
	print("(tbl, 1, 10)",table.concat(table.wraprange(tbl, 1, 10),","))
	print("(tbl, 4, 3)",table.concat(table.wraprange(tbl, 4, 3),","))
	print("(tbl, 6, 10)",table.concat(table.wraprange(tbl, 6, 10),","))
	print("(tbl, 6, 20)",table.concat(table.wraprange(tbl, 6, 20),","))
	print("(tbl, 2, 20)",table.concat(table.wraprange(tbl, 2, 20),","))
end
--test_wraprange()

-- extends table.remove to remove objects directly, without requiring table.indexOf
local _remove = table.remove
table.remove = function( t, pos )
	if (type(pos) == "number") then
		return _remove( t, pos )
	else
		pos = table.indexOf( t, pos )
		return _remove( t, pos )
	end
end

-- replaces entries of old with new
-- returns number of entries replaced
table.replace = function( tbl, old, new )
	local index = table.indexOf( tbl, old )
	local count = 0
	while (index) do
		count = count + 1
		tbl[index] = new
		index = table.indexOf( tbl, old )
	end
	return count
end

-- allows display groups to be sorted
local sort = table.sort
table.sort = function( t, compare )
	if (t.numChildren == nil) then
		sort( t, compare )
	else
		local tbl = {}
		for i=1, t.numChildren do
			tbl[#tbl+1] = t[i]
		end
		sort( tbl, compare )
		for i=1, #tbl do
			t:insert( tbl[i] )
		end
		return t
	end
end

-- reverses the order of the items in the table
local function reverse( t )
	local tbl = {}
	for i=#t, 1, -1 do
		tbl[#tbl+1] = t[i]
	end
	return tbl
end
table.reverse = reverse

-- pops # items off the top of the table (top == [1])
table.pop = function( tbl, count )
	local output = {}
	for i=1, count do
		output[#output+1] = table.remove(tbl,1)
	end
	return unpack(output)
end

-- pushes items onto tbl at bottom ([#tbl])
table.push = function( tbl, ... )
	for i=1, #arg do
		tbl[#tbl+1] = arg[i]
	end
end

-- concatenates the key value pairs of a table into a single string with optional separator
-- sep: separator between pairs, default: ', '
-- equ: separator key and value, default: '='
-- incKeys: false to exclude keys, default: true
-- incVals: false to exclude values, default: true
table.concatPairs = function( tbl, sep, equ, incKeys, incVals )
	local str = ""

	if (sep == nil) then sep = ', ' end
	if (equ == nil) then equ = '=' end
	if (incKeys == nil) then incKeys = true end
	if (incVals == nil) then incVals = true end

	for k,v in pairs(tbl) do
		if (str ~= "") then
			str = str .. sep
		end
		if (incKeys and incVals) then
			str = str .. k .. equ .. v
		elseif (incKeys) then
			str = str .. k
		elseif (incVals) then
			str = str .. v
		end
	end

	return str
end



--[[
	Converts a table of integer indexed values into a series of named-index tables.

	Parameters:
		values: The table of values, eg: {100,200,300,400}
		names: The names of the properties to be assigned, in order, eg: {"x","y"}

	Returns:
		A collection of tables with named-index values, eg: { {x=100,y=200}, {x=300,y=400} }
]]--
local function pack( values, names )
	local nameIndex = 1
	local collections = {}
	local tbl = {}

	for i=1, #values do
		local name = names[nameIndex]

		tbl[name] = values[i]

		nameIndex = nameIndex + 1
		if (nameIndex > #names) then
			nameIndex=1
			collections[ #collections+1 ] = tbl
			tbl = {}
		end
	end

	return collections
end
table.pack = pack

local function test_pack()
	local tbl = table.pack( {100,200,300,400}, {"x","y"} )
	for i=1, #tbl do
		print("Named table: "..i)
		dump(tbl[i])
	end
end
--test_pack()


local removeElement = function(arr, ele)
	local index = table.indexOf( arr, ele )
	if index ~= nil then
    	table.remove(arr, index)
    	return true
    end
    return false
end

table.removeElement = removeElement

local removeElements = function(arr, eles)
    for i = 1, #eles do
        removeElement(arr, eles[i])
    end

end

table.removeElements = removeElements

local removeAll = function(arr)
    while #arr > 0 do
        table.remove(arr, #arr)
    end

end

table.removeAllElements = removeAll
