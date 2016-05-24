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

--- Profiler entity.
--
-- This entity allows to enable and disable profiling at runtime. By default it
-- uses the special 'profiling' button configured at 'conf.lua'. It uses a
-- profiler implementation that can be found on internet.
--
-- @classmod Object.Entity.Profiler

local performance_graph = require("performance_graph")
local profiler          = require("pepperfish_profiler")

-- default: profiler.setParams('time', 100000)
profiler.setParams('time', 100000, false)

local _class = {}

local game
local graphicsDevice

function _class:init(...)
  self.super:init(...)
  
  game = _game
  graphicsDevice = game.graphicsDevice

  profiler.preventAll(_class)
  profiler.preventAll(performance_graph)
end

function _class:main(coh)
  self:on(game.input, "input.keypressed", self.inputListener)
end

function _class:update(dt)
end

function _class:inputListener(event)
  if event.data.key == "profiling" then
    if profiler.isRunning() then
      print("stopping profiler")
      profiler.stop()
      profiler.report(io.open("profiling.txt", "w+"))
    else
      print("starting profiler")
      profiler.start()
    end
  end
  
  return "keep"
end

return _class
