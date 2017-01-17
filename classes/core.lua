-- Caress, a small framework for games in lua and love.
-- Copyright (C) 2016  Erivaldo Filho "desadoc@gmail.com"

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.

-- You should have received a copy of the GNU Lesser General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local collection  = require("caress/collection")
local error       = require("caress/error")

local loadScriptFn = love and love.filesystem.load or loadfile

local _M = {
  __subclasses = collection.List.new()
}

local table_insert = table.insert

local objMt = {
  __index = function(t, k)
    return t.__inherCache[k]
  end,
  __call = function(t, fnName, ...)
    return t.__inherCache[fnName](t, ...)
  end
}

local function __newFn(class, bottom)
  
  local parent = {}
  
  parent.class = class
  parent.__inherCache = class.__inherCache
  parent.__instance = class.__chunk()
  parent.__bottom = bottom
  
  if class.super then
    local super = __newFn(class.super, bottom)
    local supers = super.__supers
    
    table_insert(supers, parent)
    
    parent.__super = super
    parent.__supers = supers
  else
    parent.__supers = {parent}
  end
  
  setmetatable(parent, objMt)
  
  return parent
end

local function _newFn(class, inplaceTb, ...)
  
  local bottom = inplaceTb or {}
  
  bottom.class = class
  bottom.__inherCache = class.__inherCache
  bottom.__instance = class.__chunk()
  bottom.__bottom = bottom
  
  if class.super then
    local super = __newFn(class.super, bottom)
    local supers = super.__supers
    
    table_insert(supers, bottom)
    
    bottom.__super = super
    bottom.__supers = supers
    bottom.super = super
  else
    bottom.__supers = {bottom}
  end
  
  setmetatable(bottom, objMt)
  
  if bottom.init then
    bottom:init(...)
  end
  
  return bottom
end

local function newFn(class, ...)
  return _newFn(class, {}, ...)
end

local function newInplaceFn(class, inplaceTb, ...)
  return _newFn(class, inplaceTb, ...)
end

local classMt = {
  __call = newFn,
  __index = function(t, k)
    return t.__static[k] or (rawget(t, "super") and t.super[k])
  end
}

local function isAFn(self, class)
  while self do
    if self == class then return true end
    self = rawget(self, "super")
  end
end

local function anonymousClass(class, chunk)

  local anonClass = {
    __chunk = chunk,
    __name = "__Anonymous",
    static = {},
    super = class,
    new = newFn,
    newInplace = newInplaceFn,
    isA = isAFn
  }
  
  setmetatable(anonClass, classMt)
  
  _M._cacheInherited(anonClass)
  _M._initStaticMembers(anonClass)
  
  return anonClass
end

function _M.registerClass(base, classname, script)
  local newClass = {
    __chunk = loadScriptFn(script .. ".lua"),
    __name = classname,
    getCompleteName = function(self)
      return (rawget(self, "super") and self.super:getCompleteName() or "") .. self.__name
    end,
    __static = {},
    super = base.__chunk and base or base.super,
    __subclasses = collection.List.new(),
    getSubclasses = function(class) return class.__subclasses end,
    new = newFn,
    newInplace = newInplaceFn,
    isA = isAFn,
    AnonClass = anonymousClass
  }
  
  setmetatable(newClass, classMt)
  rawset(base, classname, newClass)
  base.__subclasses:push_back(newClass)
end

function _M.registerClassFolder(base, name)
  local newFolder = {
    __name = name,
    __static = {},
    isFolder = function() return true end,
    super = base.__chunk and base or base.super,
    __subclasses = collection.List.new(),
    getSubclasses = function(class) return class.__subclasses end
  }

  setmetatable(newFolder, classMt)
  rawset(base, name, newFolder)
  base.__subclasses:push_back(newFolder)
end

local function superResetter(bottom, super, ...)
  rawset(bottom, "super", super)
  return ...
end

local superCallObjMt = {
  __call = function(callObj, self, ...)
    local base = self.__supers[callObj.__superIndex]
    local f = base.__instance[callObj.__fnName]
    local bottom = self.__bottom
    
    local oldSuper = rawget(bottom, "super")
    bottom.super = rawget(base, "__super")
    
    return superResetter(bottom, oldSuper, f(bottom, ...))
  end
}

local function createSuperCallObj(fnName, superIndex)
  return setmetatable({
    __fnName = fnName,
    __superIndex = superIndex,
  }, superCallObjMt)
end

local function _queryInheritedMethods(class, inherCache)
  for fnName, fnClosure in pairs(class.__inherCache) do
    if not inherCache[fnName] then
      inherCache[fnName] = fnClosure
    end
  end
  
  if class.super then
    _queryInheritedMethods(class.super, inherCache)
  end
end

local function _queryClassDepth(class)
  local depth = 1
  while class.super do
    depth = depth + 1
    class = class.super
  end
  return depth
end

function _M._cacheInherited(class)
  
  local classTb = class.__chunk()
  local inherCache = {}
  local currDepth = _queryClassDepth(class)
  
  for fnName, fnValue in pairs(classTb) do
    inherCache[fnName] = createSuperCallObj(fnName, currDepth)
  end
  
  if class.super then
    _queryInheritedMethods(class.super, inherCache)
  end
  
  rawset(class, "__inherCache", inherCache)
end

function _M.cacheInherited()
  local queue = collection.LinkedList.new()
  queue:append(_M.__subclasses)
  
  while not queue:is_empty() do
    local class = queue:remove_front()
    _M._cacheInherited(class)
    queue:append(class.__subclasses)
  end
end

function _M._initStaticMembers(class)
  local staticFn = class.__chunk()._static
  if staticFn then
    class.__static = staticFn()
  end
  
  if rawget(class, "__subclasses") then
    for _, subclass in class.__subclasses:iterator() do
      _M._initStaticMembers(subclass)
    end
  end
end

function _M.initStaticMembers()
  for _, class in _M.__subclasses:iterator() do
    _M._initStaticMembers(class)
  end
end

function _M.finish()
  _M.cacheInherited()
  _M.initStaticMembers()
end

return _M
