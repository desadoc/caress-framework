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

local List = require("collection").ArrayList

local _class = {}

function _class:init(coh, conditions)
  self.super:init(coh)

  self.conditions = List.new()
  self.results = {}

  for _, condition in ipairs(conditions) do
    self.conditions:push_back(condition)
  end
end

function _class:pause()
  for _, condition in self.conditions:iterator() do
    condition:pause()
  end

  self.super:pause()
end

function _class:resume()
  for _, condition in self.conditions:iterator() do
    condition:resume()
  end

  self.super:resume()
end

function _class:update(dt)
  for _, condition in self.conditions:iterator() do
    condition:update(dt)
  end
end

function _class:result()
  for i=1,self.conditions:size() do
    self.results[i] = self.conditions:at_index(i):result()
  end
end

return _class
