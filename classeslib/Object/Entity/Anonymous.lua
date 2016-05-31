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

--
--- Anonymous class.
--
-- This class allows the declaration of inline anonymous classs.
--
-- @classmod Object.Entity.Anonymous

local _class = {}

local methods

local update
local draw

function _class:init(parent, layer, coh, _methods)
  self.super:init(parent, layer, coh)
  
  methods = _methods
  update = methods.update
  draw = methods.draw
  
  if methods.init then methods.init(self, parent, layer, coh) end
end

function _class:main(coh)
  if methods.main then methods.main(self, coh) end
end

function _class:update(dt)
  if update then
    update(self, dt)
  else
    self.super:update(dt)
  end
end

function _class:draw()
  if draw then
    draw(self)
  else
    self.super:draw()
  end
end

return _class
