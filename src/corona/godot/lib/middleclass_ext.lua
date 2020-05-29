local function pkgImport(path, name, level)
    return require(path:match("^(.+)%.[^%.]+") .. '.' .. name)
end

local middleclass = pkgImport(..., "middleclass")

local super_class = middleclass.class
function middleclass.class(name, super)
    local superType = type(super)
    if superType == "function" then
        local newClass = super_class(name)
        newClass.static.allocate = function(self, ...)
            assert(type(self) == 'table', "Make sure that you are using 'Class:allocate' instead of 'Class.allocate'")
            local group = super(...)
            local mt = getmetatable(group)
            self.__index =  self.___index or (mt and mt.__index)
            self.__newindex = self.___newindex or (mt and mt.__newindex)
            group.__super_mt = mt
            group.class = self
            return setmetatable(group, self.__instanceDict)
        end

        newClass.static.new = function(self, ...)
          assert(type(self) == 'table', "Make sure that you are using 'Class:new' instead of 'Class.new'")
          local instance = self:allocate(...)
          instance:initialize(...)
          return instance
        end

        function newClass:__getsupermt()
            return self.__super_mt
        end

        function newClass:_super(k, ...)
            local func = self.__super_mt.__index(self, k)
            return func(self, ...)
        end

        return newClass
    else
        return super_class(name, super)
    end
end

return middleclass
