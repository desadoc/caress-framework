-- Caress-Lib, a lua library for games.
-- Copyright (C) 2016, 2017,  Erivaldo Filho "desadoc@gmail.com"

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

--- Filesystem functions module.
--
-- Functions to obtain information about files, directories, and manipulate
-- them.
--
-- @module filesystem

local _M = {}

_M.isFile = nil
_M.isDirectory = nil
_M.getDirectoryItems = nil

function _M.setIsFileFunction(isFileFn)
  _M.isFile = isFileFn
end

function _M.setIsDirectoryFunction(isDirectoryFn)
  _M.isDirectory = isDirectoryFn
end

function _M.setGetDirectoryItemsFunction(getDirectoryItemsFn)
  _M.getDirectoryItems = getDirectoryItemsFn
end

return _M
