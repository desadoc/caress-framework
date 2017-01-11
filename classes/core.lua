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

local instanceMt = {
  __index = function(t, k)
    local attrMap = rawget(t, "__attrMap")
    if rawget(attrMap, k) then return rawget(attrMap, k) end
    
    local inherTb = rawget(t, "__inher")
    return rawget(inherTb, k)
  end,
  __newindex = function(t, k, v)
    rawset(t.__attrMap, k, v)
  end,
  __eq = function(t, u)
    return rawequal(t.__attrMap, u.__attrMap)
  end
}

local function _newFn(class, attrMap)
  local instance = class.__chunk()
  
  instance.__inher = class.__inher
  instance.__attrMap = attrMap
  
  if class.super then
    instance.super = _newFn(class.super, attrMap)
    
    local supers = {}
    
    local super = instance.super
    while super do
      table.insert(supers, super)
      super = rawget(super, "super")
    end
    
    instance.__supers = supers
  end
  
  return setmetatable(instance, instanceMt)
end

local function newFn(class, ...)
  local instance = _newFn(class, {
    class=class,
  })
  if instance.init then
    instance:init(...)
  end
  return instance
end

local classMt = {
  __call = newFn
}

function _M.registerClass(base, classname, script)
  local newClass = {
    __chunk = loadfile(script .. ".lua"),
    super = base.__chunk and base,
    __subclasses = collection.List.new(),
    new = newFn,
  }
  
  setmetatable(newClass, classMt)
  rawset(base, classname, newClass)
  base.__subclasses:push_back(newClass)
end

function _M.registerClassFolder(base, name)

end

local function initStaticMembers(classroot)

end

local function createInherCallClosure(fnName, superIndex)
  return function(self, ...)
    local super = self.__supers[superIndex]
    return super[fnName](super, ...)
  end
end

local function _generateInheritanceCache(class, inherTb, depth)

  local classTb = class.__chunk()
  local inher = {}
  
  for fnName, srcDepth in pairs(inherTb) do
    if not classTb[fnName] then
      inher[fnName] = createInherCallClosure(fnName, depth-srcDepth)
    end
  end
  
  rawset(class, "__inher", inher)
  
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
end

return _M
