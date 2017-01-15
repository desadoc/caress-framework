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

local _M = {
  __subclasses = collection.List.new()
}

local superBaseMt = {
  __index = function(t, k)
    if t.__attr[k] then
      return t.__attr[k]
    end
    
    return t.__bottomClosures[k]
  end,
  __newindex = function(t, k, v)
    t.__attr[k] = v
  end,
  __eq = function(t, u)
    return u.__attr and (t.__attr == u.__attr)
  end
}

local fakeSuperMt = {
  __index = function(t, k)
    return t.__inher[k]
  end,
  __newindex = function(t, k, v)
    error.errhand("values at this table aren't supposed to be set: k=" .. tostring(k) .. ", v=" .. tostring(v))
  end
}

local bottomMt = {
  __index = function(t, k)
    if t.__attr[k] then
      return t.__attr[k]
    end
    
    return t.__inher[k]
  end,
  __newindex = function(t, k, v)
    t.__attr[k] = v
  end,
  __eq = function(t, u)
    return u.__attr and (t.__attr == u.__attr)
  end
}

local function _newFn(class, bottom, bottomClosures, attr)
  
  local base = {}
  base.__class = class.__chunk()
  base.__bottom = bottom
  base.__bottomClosures = bottomClosures
  base.__attr = attr

  local fake_super = {}
  fake_super.__inher = class.__inher
  fake_super.__base = base

  if class.super then
    base.super = _newFn(class.super, bottom, bottomClosures, attr)

    local supers = {}

    local _super = base.super.__base
    while _super do
      table.insert(supers, _super)
      _super = _super.super and _super.super.__base
    end

    fake_super.__supers = supers
  end
  
  setmetatable(base, superBaseMt)
  setmetatable(fake_super, fakeSuperMt)

  return fake_super
end

local function newFn(class, ...)

  local bottom = {}

  bottom.__class = class.__chunk()
  bottom.__attr = {class=class}
  bottom.__inher = class.__inher
  bottom.__base = bottom

  if class.super then
    bottom.super = _newFn(class.super, bottom, class.__bottom, bottom.__attr)
    
    local supers = {}
    
    local _super = bottom.super.__base
    while  _super do
      table.insert(supers, _super)
      _super = _super.super and _super.super.__base
    end
    
    bottom.__supers = supers
  end
  
  setmetatable(bottom, bottomMt)
  
  if bottom.init then
    bottom:init(...)
  end
  
  return bottom
end

local function createSuperCallClosure(superIndex, fnName)
  return function(fake_super, ...)
    local base = fake_super.__supers[superIndex]
    local f = base.__class[fnName]
    return f(base, ...)
  end
end

local function createLocalCallClosure(fnName)
  return function(self, ...)
    local f = self.__base.__class[fnName]
    return f(self.__base, ...)
  end
end

local function createBottomCallClosure(fnName)
  return function(superBase, ...)
    local bottom = superBase.__bottom
    return bottom[fnName](bottom, ...)
  end
end

local classMt = {
  __call = newFn,
  __index = function(t, k)
    return t.__static[k] or (rawget(t, "super") and t.super[k])
  end
}

function _M.registerClass(base, classname, script)
  local newClass = {
    __chunk = loadfile(script .. ".lua"),
    __name = classname,
    __static = {},
    super = base.__chunk and base or base.super,
    __subclasses = collection.List.new(),
    getSubclasses = function(class) return class.__subclasses end,
    new = newFn
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

local function _generateInheritanceCache(class, inherTb, depth)

  local classTb = class.__chunk()
  local inher = {}
  local bottom = {}
  
  for fnName, srcDepth in pairs(inherTb) do
    inher[fnName] = createSuperCallClosure(depth-srcDepth, fnName)
  end
  
  for fnName, fnValue in pairs(classTb) do
    inher[fnName] = createLocalCallClosure(fnName)
  end
  
  for fnName, _ in pairs(inher) do
    bottom[fnName] = createBottomCallClosure(fnName)
  end
  
  rawset(class, "__inher", inher)
  rawset(class, "__bottom", bottom)
  
  for fnName, fnValue in pairs(classTb) do
    inherTb[fnName] = depth
  end
  
  for i, subclass in class.__subclasses:iterator() do
    _generateInheritanceCache(subclass, inherTb, depth+1)
  end
end

function _M.generateInheritanceCache()
  for _, subclass in _M.__subclasses:iterator() do
    _generateInheritanceCache(subclass, {}, 1)
  end
end

function _M.finish()
  _M.generateInheritanceCache()
  _M.initStaticMembers()
end

return _M
