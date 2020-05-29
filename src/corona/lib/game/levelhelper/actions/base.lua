-- Copyright 2020 Labo Lado.

-- Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
-- http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
-- <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
-- option. This file may not be copied, modified, or distributed
-- except according to those terms.

local B = {}

local Helper = pkgImport(..., "helper", 2)
local TypeParser = pkgImport(..., "type_parser")

--扩展出一个Action
-- @param name Action名称
-- @param propertiesSchema 参数结构，该结构主要用于校验和参数的自动解析，是一个 hash,结构如下
-- {
--		{name = 参数名称1, default="默认值", required = 是否必须, type = 类型1, limit = {类型1限制} },
--      {name = 参数名称1, required = 是否必须, type = 类型2, limit = {类型2限制} }
-- }，如
-- {
--       {name = "speed", default=10, required = true, type = "int", limit = {max=1000, min=100}},
--       {name = "name1", required = false, type = "string", limit = {max=1000, min=100}},
-- }
local function _variableDecode(ctx, value)
	local variable=value
    if variable:match("^%$") then
        variable = ctx.variables[variable:gsub("^%$", "")]
    end
    return variable
end

local function _extensionTypeDecode(ctx, value)
	local typename, str = value:match("([^#]+)#([^#]+)")
	local decodeValue = str
	if typename == "int" or typename == "float" then
		decodeValue = tonumber(str)
	elseif typename == "bool" then
		if str == "false" then
			decodeValue = false
		else
			decodeValue = true
		end
	elseif typename == nil then
		decodeValue = _variableDecode(ctx, value)
	end
	return decodeValue
end

-- 类型包括int, float, string, bool
function B:extend(name, propertiesSchema)
	local baseAction = {}
	baseAction.name= name
	baseAction.propertiesSchema = propertiesSchema
	_.push(propertiesSchema, {name = "delay", default = 0, type = "int", limit = {max = 10000, min = 0}, desc="延迟执行(ms)"})
	_.push(propertiesSchema, {name = "game", default = "self", type = "string", limit = {max = 10000, min = 0}, desc="指定游戏"})
	_.push(propertiesSchema, {name = "role", default = "self", type = "string", limit = {max = 10000, min = 0}, desc="指定角色"})
	_.push(propertiesSchema, {name = "context", default = "self", type = "string", limit = {max = 10000, min = 0}, desc="指定context"})
	-- _.push(propertiesSchema, {name = "parser", default = "self", type = "string", limit = {max = 10000, min = 0}, desc="指定解释器"})

	--参数校验
	function baseAction:parseProperties(ctx, properties)
		local prop = {}
		local target = properties.target
		assert(target ~= nil, "property target cannot be nil")

		if name == "audio_bg" or name == "audio" then
			assert(SoundLoader:findSound(properties.name) ~= nil, "audio " .. properties.name .. " not existed or not loaded. In " .. target.levelName .. " (" .. target.lhUniqueName .. ")")
		end

		_.each(self.propertiesSchema, function(item)
			assert(item.name ~= nil)
			assert(item.type ~= nil)

			local pname = item.name

			_.each(properties, function(v, k)
				if k == pname then
					if type(v) == "string" then
						local tv = TypeParser[item.type](item.limit, _variableDecode(ctx, v), pname, properties)
						prop[k] = tv
					end
				end
			end)
			--属性一定需要
			if item.required == true  then
				assert( (prop[pname] ~= nil and prop[pname] ~= ""), "property " .. pname .. " is required, target=" .. tostring(target.id))
				-- assert( (prop[pname] ~= nil), "property " .. pname .. " is required, target=" .. tostring(target.id))
			end
			--使用默认值
			if prop[pname] == nil and item.default ~= nil then

				prop[pname] = item.default
			end

		end)

		-- 扩展属性
		_.each(properties, function(v, k)
			if prop[k] == nil or prop[k] == "" then
				if type(v) == "string" then
					prop.extension = prop.extension or {}
					prop.extension[k] = _extensionTypeDecode(ctx, v)
				elseif type(v) == "function" or type(v) == "table" then
					if prop[k] == "" then
						prop[k] = v
					else
						prop.extension = prop.extension or {}
						prop.extension[k] = v
					end
				elseif k:find("ext_") then
					prop.extension = prop.extension or {}
					prop.extension[k] = v
				end
			end
		end)
		prop.target = target
		prop.targetAltering = properties.targetAltering
		prop.hasTargetProp = properties.hasTargetProp
		return prop
	end

	function baseAction:new(ctx, properties)
		assert(ctx ~= nil)
		assert(properties ~= nil)
		assert(baseAction.execute ~= nil)
		local obj = {}
		obj.ctx = ctx
		obj.actionName = baseAction.name
		local props = baseAction:parseProperties(ctx, properties)
		_.each(props, function(v, k)
			obj[k] = v
		end)

		function obj:initContext()
			if self.context ~= "self" then
				self.game = self.context
				self.role = self.context
				if self.context ~= "root" then
					self.CONTEXT = Helper.findContext(ctx, self.context, self.target.loaderID)
				end
			end
			if self.GAME == nil then
				if self.game == "root" then
					self.GAME = ctx.root.game
				elseif self.game == "self" then
					self.GAME = ctx.game
				else
					if self.CONTEXT then
						self.GAME = self.CONTEXT.game
					else
						local targetCtx = Helper.findContext(ctx, self.game, self.target.loaderID)
						self.GAME = targetCtx.game
					end
				end
			end
			if self.ROLE == nil then
				if self.role == "root" then
					self.ROLE = ctx.root.car
				elseif self.role == "self" then
					self.ROLE = ctx.car
				else
					if self.CONTEXT then
						self.ROLE = self.CONTEXT.car
					else
						local targetCtx = Helper.findContext(ctx, self.game, self.target.loaderID)
						self.ROLE = targetCtx.car
					end
				end
			end
		end

		function obj:execute()
		 	if self.delay == 0 then
		 		self:initContext()
				return baseAction.execute(self.CONTEXT or ctx, self)
			else
				ctx.timerMgr:setTimeout(self.delay, function()
			 		self:initContext()
					baseAction.execute(self.CONTEXT or ctx, self)
				end)
			end
		end

		return obj
	end

	return baseAction
end



return B
