-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.
local TypeParser = {}
-- 校验int型属性
-- int型属性有两个限制 max 和 min，最大值最小值
TypeParser.int = function(schema, value, pname, properties)
	local v = tonumber(value)
	local target = properties.target
 
 
	assert(schema.max ~= nil and schema.max >= v,  "property " .. pname .. " max value is " .. schema.max .. ", and now is" .. v .. ", target=" .. tostring(target.id)) 
	assert(schema.min ~= nil and schema.min <= v,  "property " .. pname .. " min value is " .. schema.min .. ", and now is" .. v .. ", target=" .. tostring(target.id)) 
	return v			
end
--校验float
TypeParser.float = function(schema, value, pname,properties)
	local v = tonumber(value)
 
	local target = properties.target
	assert(schema.max ~= nil and schema.max >= v,  "property " .. pname .. " max value is " .. schema.max .. ", and now is" .. v .. ", target=" .. tostring(target.id)) 
	assert(schema.min ~= nil and schema.min <= v,  "property " .. pname .. " min value is " .. schema.min .. ", and now is" .. v .. ", target=" .. tostring(target.id)) 
	return v			
end
--校验string型属性
-- string型属性有两个限制 max 和 min，最大长度和最小长度
TypeParser.string = function(schema, value, pname,properties)
	local v = value
	local len = string.len(v)
	local target = properties.target
 
	assert(schema.max ~= nil and schema.max >= len,  "property " .. pname .. " max len is " .. schema.max .. ", and now is" .. len .. ", target=" .. tostring(target.id)) 
	assert(schema.min ~= nil and schema.min <= len,  "property " .. pname .. " min len is " .. schema.min .. ", and now is" .. len .. ", target=" .. tostring(target.id)) 
	return v			
end
--校验bool型属性
TypeParser.bool = function(schema, value, pname, properties)
	if value == 'true' then return true end
	if value == 'false' then return false end
	local target = properties.target
 
	assert(1 == 1,  "property " .. pname .. " should be a bool,  and now is " .. value .. ", target=" .. tostring(target.id)) 
end

TypeParser.number = TypeParser.float

return TypeParser