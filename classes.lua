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

--- Class system module.
--
-- This module acts as a class path system for classes implemented in lua.
-- It needs to be loaded and initialized with folders containing class source
-- files.
--
-- It supports inheritance, method/field shadowing and static fields.
--
-- Some methods/fields have special meaning when implementing a class:
--
-- _class:init()
--
-- This optional method is also used for initialization after the object is
-- fully constructed, it's optional.
--
-- _class.initClass()
--
-- Like init(), but for initializing static members.
--
-- _class:main(cohandler)
--
-- Caress function that should be run at some moment after the object is
-- initialized. It can be handily run with self:start().
--
-- self.class
--
-- Class object. Has some useful methods like an isA operator and
-- getCompleteName().
--
-- @module classes

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

local function _loadClassesByDir(classroot, dir, classes)
  local files = love.filesystem.getDirectoryItems(dir)
  local modules = {}
  local subdirs = {}
  for i, v in ipairs(files) do
    if love.filesystem.isFile(dir .. "/" .. v) and
      string.sub(v,-4) == '.lua' then
      modules[string.sub(v,1,-5)] = true
    end
    if love.filesystem.isDirectory(dir .. "/" .. v) then
      subdirs[v] = true
    end
  end

  for k, v in pairs(subdirs) do
    if not rawget(classroot, k) and not modules[k] then
      _M.registerClassFolder(classroot, k)
      subdirs[k] = false
    end
  end

  -- add modules to class system
  for k, v in pairs(modules) do
    -- class already exists
    if rawget(classroot, k) then
      error.errhand("duplicate class definition found for \"" ..
        classroot:getCompleteName() .. "." .. k .. "\"")
    end
    _M.registerClass(classroot, k, dir .. "/" .. k)
    classes:push_back(classroot[k])
  end

  -- recursively add subdirectories
  for k, v in pairs(subdirs) do
    -- subdirs that have a module with same name use it as base class,
    -- other dirs inherit current root
    _loadClassesByDir(classroot[k], dir .. "/" .. k, classes)
  end
end

function _M.initStaticMembers(classroot)
  if classroot._chunk then
    local static = classroot._chunk().static
    if static then
      rawset(classroot, "_static", static())
    end
  end

  for _, subclass in classroot._subclasses:iterator() do
    _M.initStaticMembers(subclass)
  end
end

--- Loads classes in a given directory.
-- Classes are loaded in each folder and subfolder, recursively. Each file
-- maps to a class and the file name is also the class name. Folders contains
-- a class's subclasses and a folder name may match a class name already
-- loaded in this or previous calls.
-- @param classroot Root class for this dir or this module itself.
-- @param dir Folder path.
function _M.loadClassesByDir(classroot, dir)
  local classes = collection.List.new()

  _loadClassesByDir(classroot, dir, classes)
  _M.initStaticMembers(classroot)
end

return _M
