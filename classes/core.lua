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
  _subclasses = collection.List.new()
}

local instanceMt = {
  __index = function(t, k)
    local upward =
      t.__attrMap[k] or
      (rawget(t, "super") and rawget(t, "super")[k])
    
    if upward then return upward end
    
    local u = rawget(t, "__bottomClass")
    while u and not rawequal(t, u) do
      if rawget(u, k) then return rawget(u, k) end
      u = rawget(u, "super")
    end
  end,
  __newindex = function(t, k, v)
    rawset(t.__attrMap, k, v)
  end,
  __eq = function(t, u)
    return rawget(u, "__attrMap") and (rawequal(t.__attrMap, u.__attrMap))
  end
}

local function _newFn(class, bottomClass, attrMap, inplaceTable)
  local instance = class._chunk()
  
  if inplaceTable then
    for k,v in pairs(instance) do
      inplaceTable[k] = v
    end
    instance = inplaceTable
  end
  
  bottomClass = bottomClass or instance
  
  instance.__attrMap = attrMap
  instance.__bottomClass = bottomClass
  
  if class.super then
    instance.super = _newFn(class.super, bottomClass, attrMap)
  end
  
  return setmetatable(instance, instanceMt)
end

local function newFn(class, ...)
  local instance = _newFn(class, nil, {class=class})
  if instance.init then
    instance:init(...)
  end
  return instance
end

local function newInplaceFn(class, inplaceTable, ...)
  local instance = _newFn(class, nil, {class=class}, inplaceTable)
  if instance.init then
    instance:init(...)
  end
  return instance
end

local classMt = {
  __call = newFn,
  __index = function(t, k)
    return (rawget(t, "_static") and rawget(t, "_static")[k]) or (rawget(t, "super") and rawget(t, "super")[k])
  end
}

local classes = {}
function _M.registerClass(base, classname, script)
  
  local newClass = {
    _chunk = loadfile(script .. ".lua"),    
    _name = classname, 
    super = base._chunk and base,
    _subclasses = collection.List.new(),
    
    getSubclasses = function(self) return self._subclasses end,
    getName = function(self) return self._name end,
    getCompleteName = function(self)
      return
        (self.super and self.super:getCompleteName() .. "." or "") ..
        self:getName()
    end,
     
    new = newFn,
    newInplace = newInplaceFn
  }
  
  setmetatable(
    newClass,
    classMt
  )

  rawset(base, classname, newClass)
  base._subclasses:push_back(newClass)
end

function _M.registerClassFolder(base, name)

  local folder = {
    _name = name,
    super = rawget(base, "_chunk") and base or rawget(base, "super"),
    _subclasses = collection.List.new(),
    
    getSubclasses = function(self) return self._subclasses end,
    getName = function(self) return self._name end,
    getCompleteName = function(self)
      return
        (self.super and self.super:getCompleteName() .. "." or "") ..
        self:getName()
    end,
  }
  
  rawset(base, name, folder)
end

local function initStaticMembers(classroot)
  if classroot._chunk then
    local static = classroot._chunk()._static
    if static then
      rawset(classroot, "_static", static())
    end
  end

  for _, subclass in classroot._subclasses:iterator() do
    initStaticMembers(subclass)
  end
end

function _M.finish()
  initStaticMembers(_M)
end

return _M
