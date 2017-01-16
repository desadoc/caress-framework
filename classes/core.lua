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

local function superResetter(bottom, super, ...)
  rawset(bottom, "super", super)
  return ...
end

local parentMt = {
  __index = function(t, k)
    return t.class.__inherCache[k]
  end,
  __call = function(t, fnName, ...)
    local bottom = t.__bottom
    
    local base = t
    while not rawget(base.__instance, fnName) do
      base = rawget(base, "__super")
      if not base then break end
    end
    
    if not base then
      error.errhand("Field or method \"" .. fnName .. "\" not found at superclasses. t=" .. t.class.__name .. ", bottom=" .. bottom.class.__name)
      return
    end
    
    bottom.super = rawget(base, "__super")
    return superResetter(bottom, t, base.__instance[fnName](bottom, ...))
  end
}

local function createSuperCallClosure(newSuper, f)
  return function(self, ...)
    local oldSuper = rawget(self, "super")
    self.super = newSuper
    return superResetter(self, oldSuper, f(self, ...))
  end
end

local bottomMt = {
  __index = function(bottom, k)
    return bottom.class.__inherCache[k]
  end
}

local function __newFn(class, bottom)
  
  local parent = {}
  
  parent.class = class
  parent.__instance = class.__chunk()
  parent.__bottom = bottom
  
  if class.super then
    local super = __newFn(class.super, bottom)
    parent.__super = super
    
    local supers = {}
    while super do
      table.insert(supers, 1, super)
      super = rawget(super, "__super")
    end
    
    table.insert(supers, parent)
    
    parent.__supers = supers
  else
    parent.__supers = {parent}
  end
  
  setmetatable(parent, parentMt)
  
  return parent
end

local function _newFn(class, inplaceTb, ...)
  
  local bottom = inplaceTb or {}
  
  bottom.class = class 
  bottom.__instance = class.__chunk()
  
  if class.super then
    local super = __newFn(class.super, bottom)
    bottom.__super = super
    bottom.super = super
    
    local supers = {}
    while super do
      table.insert(supers, 1, super)
      super = rawget(super, "__super")
    end
    
    table.insert(supers, bottom)
    
    bottom.__supers = supers
  else
    bottom.__supers = {bottom}
  end
  
  setmetatable(bottom, bottomMt)
  
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

function _M.registerClass(base, classname, script)
  local newClass = {
    __chunk = loadScriptFn(script .. ".lua"),
    __name = classname,
    __static = {},
    super = base.__chunk and base or base.super,
    __subclasses = collection.List.new(),
    getSubclasses = function(class) return class.__subclasses end,
    new = newFn,
    newInplace = newInplaceFn,
    isA = function(self, class)
      while self do
        if self == class then return true end
        self = rawget(self, "super")
      end
    end
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

local function createSuperCallClosure(fnName, superIndex)
  return function(self, ...)
    local base = self.__supers[superIndex]
    local f = base.__instance[fnName]
    
    local oldSuper = rawget(self, "super")
    self.super = rawget(base, "__super")
    
    if not f then
      print("SATAN1: " .. self.class.__name)
      print("SATAN2: " .. fnName)
      print("SATAN3: " .. superIndex)
    end
    
    return superResetter(self, oldSuper, f(self, ...))
  end
end

local function createLocalCallClosure(fnName)
  return function(self, ...)
    local f = self.__instance[fnName]
    
    local oldSuper = rawget(self, "super")
    self.super = rawget(self, "__super")
    
    return superResetter(self, oldSuper, f(self, ...))
  end
end

local function _cacheInherited(class, inherTb, depth, superCache)
  
  local instance = class.__chunk()
  local inherCache = {}
  
  if not superCache[depth] then
    superCache[depth] = {}
  end
  
  for fnName, srcDepth in pairs(inherTb) do
    if not superCache[srcDepth][fnName] then
      superCache[srcDepth][fnName] = createSuperCallClosure(fnName, srcDepth)
    end
    
    inherCache[fnName] = superCache[srcDepth][fnName]
  end
  
  for fnName, fnValue in pairs(instance) do
    if not superCache[depth][fnName] then
      superCache[depth][fnName] = createSuperCallClosure(fnName, depth)
    end
    inherCache[fnName] = superCache[depth][fnName]
    inherTb[fnName] = depth
  end
  
  rawset(class, "__inherCache", inherCache)
  
  for _, subclass in class.__subclasses:iterator() do
    _cacheInherited(subclass, collection.tableCopy(inherTb), depth+1, collection.tableCopy(superCache, true))
  end
end

function _M.cacheInherited()
  for _, class in _M.__subclasses:iterator() do
    _cacheInherited(class, {}, 1, {})
  end
end

local function _initStaticMembers(class)
  local staticFn = class.__chunk()._static
  if staticFn then
    class.__static = staticFn()
  end
  
  for _, subclass in class.__subclasses:iterator() do
    _initStaticMembers(subclass)
  end
end

function _M.initStaticMembers()
  for _, class in _M.__subclasses:iterator() do
    _initStaticMembers(class)
  end
end

function _M.finish()
  _M.cacheInherited()
  _M.initStaticMembers()
end

return _M
