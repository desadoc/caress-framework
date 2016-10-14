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
-- _class:new()
--
-- This method serves as a place to declare and initialize instance fields
-- with basic default values, optional.
--
-- _class:init()
--
-- This method is also used for initialization, but it's called after the
-- object was fully constructed, it is too optional.
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

local _M = {}

--- Root name.
-- Class path root is named "classes" and for clarity this module also should
-- be named "classes" when requiring.
-- @return Root name.
function _M.getCompleteName()
  return "classes"
end

-- List of classes at root of class hierarchy.
_M._subclasses = collection.List.new()

-- This function creates and registers a new class as a subclass of the given
-- root. Chunk is the loaded lua file defining the class.
local function _registerClass(root, classname, chunk)
  local newClass = {
    _classname = classname,
    _super = not rawget(root, "_is_folder") and root or root._super,
    _subclasses = collection.List.new(),
    -- we save the chunk which returns a module containing methods
    -- and private fields
    _classChunk = chunk,
    _mt = {
      __call = function(class, ...)
        return _M.createInstance(class, ...)
      end,
      __index = function(class, k)
        local field = rawget(class._static, k)
        if field then return field end
        if rawget(class, "_super") then return class._super[k] end
      end,
      __newindex = function(class, k, v)
        local field = rawget(class._static, k)
        if field then rawset(class._static, k, v); return end
        if class._super[k] then class._super[k] = v; return end
        rawset(class._static, k, v)
      end
    },
    nameAndClassPairs =
    function(self)
      return collection.filteredPairs(self,
        function(k, v)
          return
            type(v) == 'table' and
            v._classname and
            v._super == root[classname]
        end
      )
    end,
    getSubclasses = function(self)
      return self._subclasses
    end,
    getRandomSubclasses =
    function(self, quantity)
      return collection.randomSubList(self._subclasses, quantity)
    end,
    -- ISA operator. It returns true when class inherits directly or indirectly
    -- from this class or is equal to it.
    isA =
    function(self, class)
      while self do
        if self == class then return true end
        self = self._super
      end
    end,
    -- returns this class complete name, including each super class in order
    -- and separated by dots.
    getCompleteName =
    function()
      return root.getCompleteName() .. "." .. classname
    end,
    -- instantiates a class, same result as Class(...)
    new =
    function(self, ...)
      return _M.createInstance(self, ...)
    end,
    newInplace =
    function(self, tb, ...)
      return _M.createInstanceInplace(self, tb, ...)
    end
  }

  setmetatable(newClass, newClass._mt)
  rawset(root, classname,  newClass)
  root._subclasses:push_back(newClass)
end

local function initStaticMembers(class)
  if class._classChunk then
    local static = class._classChunk()._static
    if static then
      rawset(class, "_static", static())
    else
      rawset(class, "_static", {})
    end
  end

  for _, subclass in class._subclasses:iterator() do
    initStaticMembers(subclass)
  end
end

local loadScriptFunc = love.filesystem.load

--- Loads and registers a class from it's source file.
-- @param root Parent class.
-- @param classname New class name.
-- @param script Path to lua source file.
function _M.registerClass(root, classname, script)
  script = script .. ".lua"

  local chunk, msg

  chunk, msg = loadScriptFunc(script)

  if not chunk then
    error.errhand(msg)
    return
  end

  _registerClass(root, classname, chunk)
end

--- Registers a folder into the classpath.
-- Classes within a folder inherit a class with the same name as this folder,
-- it it exists, otherwise they inherit from the parent of the parent, if it
-- exists too, or so on, recursively.
-- This method registers a folder that doesn't have a source file for it, as a
-- dummy, empty class. 
function _M.registerClassFolder(root, classname)
  local newClassFolder = {
    _classname = classname,
    _is_folder = true,
    _super = not rawget(root, "_is_folder") and root or root._super,
    _subclasses = collection.List.new(),
    nameAndClassPairs =
    function(self)
      return collection.filteredPairs(self,
        function(k, v)
          return
            type(v) == 'table' and
            v._classname and
            v._super == root[classname]
        end
      )
    end,
    getSubclasses = function(self)
      return self._subclasses
    end,
    getRandomSubclasses =
    function(self, quantity)
      return collection.randomSubList(self._subclasses, quantity)
    end,
    getCompleteName =
    function()
      return root.getCompleteName() .. "." .. classname
    end,
  }
  
  rawset(root, classname,  newClassFolder)
end

local function _resetter(base, oldSuper, ...)
  rawset(base, "super", oldSuper)
  return ...
end

-- This method creates a closure that is responsible for setting the correct
-- super to an object, call '_field' and reset it back to the previous super.
local function createSuperClosure(base, instance, _instance, _field)
  return function(u, ...)
    if rawequal(u, instance) then
      local _oldSuper = rawget(base, "super")
      rawset(base, "super", rawget(_instance, "_super"))
      return _resetter(base, _oldSuper, _field(base, ...))
    else
      return _field(u, ...)
    end
  end
end

-- Creates an instance's metatable.
-- @param fieldCache Maps which parent class instance contains a given field.
-- @param closureCache Cache of closure functions that do the setup of "super"
--        attribute and reset it back after the call is made. It exists only as
--        an optimization, because closures are expensive to create.
local function createMetatable(base, instance, fieldCache, closureCache)
  return {
    __index = function(t, k)

      local _instance, _field

      _instance = fieldCache[k]
      if _instance then _field = _instance._instance[k] end

      if type(_field) ~= "function" then
        return _field
      end

      return closureCache[k]
    end,
    __newindex = function(t, k, v)

      if type(v) ~= "function" then
        rawset(base, k, v)
        return
      end

      local _instance = fieldCache[k]

      if _instance then
        rawset(_instance._instance, k, v)
        closureCache[k] =
          createSuperClosure(base, instance, _instance, v)
      else
        rawset(t._instance, k, v)
        fieldCache[k] = t
        closureCache[k] =
          createSuperClosure(base, instance, instance, v)
      end
    end,
  }
end

local function initFieldCache(instance, super)
  for k, v in pairs(instance._instance) do
    instance._fieldCache[k] = instance
  end

  if not super then return end

  for k, v in pairs(rawget(super, "_fieldCache")) do
    if not instance._fieldCache[k] then
      instance._fieldCache[k] = rawget(super, "_fieldCache")[k]
    end
  end
end

local function initSuperClosureCache(base, instance)
  instance._closureCache = {}

  for k, v in pairs(instance._fieldCache) do
    instance._closureCache[k] = createSuperClosure(base, instance, v, v._instance[k])
  end
end

local function __createInstance(tb, base, class)
  local instance = tb or {}

  instance._instance = class._classChunk()

  if instance._instance.new then
    instance._instance:new()
  end

  instance._instance._static = nil
  instance._fieldCache = {}

  base = base or instance

  if class._super and class._super._classChunk then
    local super = __createInstance(nil, base, class._super)
    -- this field wont be modified
    instance._super = super
  end

  initFieldCache(instance, instance._super)
  initSuperClosureCache(base, instance)

  setmetatable(instance,
    createMetatable(
      base, instance, instance._fieldCache, instance._closureCache
    )
  )

  return instance
end

-- Copies fields into the base table for optimal access.
-- Only fields created within the "class:new()" call are copied.
local function copyFieldsIntoBase(base, source)
  if not source then
    return
  end

  local fieldsToNil = collection.List.new()

  for k, v in pairs(source._instance) do
    if type(v) ~= "function" then
      if rawget(base, k) then
        print("warning: inherited field named " .. k .. " shadows or conflicts with internal use field.")
      else
        rawset(base, k, v)
        fieldsToNil:push_back(k)
      end
    end
  end

  for _, k in fieldsToNil:iterator() do
    rawset(source._instance, k, nil)
  end

  copyFieldsIntoBase(base, source._super)
end

local function _createInstance(class, tb, ...)
  local instance = __createInstance(tb, nil, class)

  rawset(instance, "class", class)
  -- this field needs to be adjusted depending on context
  rawset(instance, "super", rawget(instance, "_super"))
  rawset(getmetatable(instance), "__gc", function()
    instance:disable()
    instance:clearListeners()
  end)

  copyFieldsIntoBase(instance, instance)

  if instance.init then
    instance:init(...)
  end

  return instance
end

--- Instantiates a class, creating an entity.
-- @param class to instantiate.
-- @param ... additional parameters are passed to instance's init(), usually a
--            Game instance, new instance's parent, layer and an optional
--            cohandler for asynchronous initialization.
function _M.createInstance(class, ...)
  return _createInstance(class, nil, ...)
end

function _M.createInstanceInplace(class, tb, ...)
  return _createInstance(class, tb, ...)
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
  initStaticMembers(classroot)
end

return _M
