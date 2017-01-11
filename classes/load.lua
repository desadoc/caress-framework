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

local _M = require("caress/classes/core")

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
end

return _M
