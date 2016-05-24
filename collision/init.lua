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

--- Collision module.
-- This module has several functions for collision detection. Currently
-- it only accepts objects modeled with AABB's. Also, collision detection
-- is discrete on a frame per frame basis, processed without any temporal
-- ordering. Because of this, the algorithm checks for collision two times,
-- once for each axis, when checking on X axis, Y velocity is zeroed, and vice-
-- versa, so certain special cases are avoided.
--
-- @module collision

local _M = {}

_M.base = require("caress/collision/base")

_M.detection = require("caress/collision/detection")

_M.reaction = {}

_M.reaction.basic   = require("caress/collision/reaction/basic")
_M.reaction.filter  = require("caress/collision/reaction/filter")
_M.reaction.chain   = require("caress/collision/reaction/chain")

_M.reaction.new = 
function(...)
  return _M.reaction.filter.new(...)
end

return _M
