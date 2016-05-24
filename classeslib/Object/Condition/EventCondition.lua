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

local _class = {}

local source = nil
local name = nil
local cb = nil

local result = nil

function _class:init(coh, _source, _name, _cb)
  self.super:init(coh)

  _cb = _cb or function(evt) return evt end

  source = _source
  name = _name
  cb =
    function(evt)
      result = _cb(evt)
      return "keep"
    end
end

function _class:resume()
  source:addEventListener(name, cb)
  self.super:resume()
end

function _class:pause()
  source:removeEventListener(name, cb)
  self.super:pause()
end

function _class:update(dt)
end

function _class:result()
  local r = result
  result = nil
  return r
end

return _class
