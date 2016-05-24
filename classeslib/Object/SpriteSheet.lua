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

--- Sprite Sheet class.
--
-- Represents a sprite sheet. Sprite Sheet files (.sprs) contains information 
-- about sprite size and position within a image.
--
-- @classmod Object.SpriteSheet

local classes = require("caress/classes")

local _class = {}

local image
local sprites = {}

function _class:init(spriteSrc, game, parent, coh)
  local gd = game.graphicsDevice
  local assetCache = game.assetCache
  
  image = assetCache:load(spriteSrc.image)
  
  for _, sprite in ipairs(spriteSrc.sprites) do
    table.insert(sprites, classes.Object.Sprite(self, {
      quad = gd:newQuad(
          sprite[1], sprite[2],
          sprite[3], sprite[4],
          image:getWidth(), image:getHeight()
        ),
      width = sprite[3],
      height = sprite[4],
    }))
  end
end

function _class:getImage()
  return image
end

function _class:getSprite(i)
  return sprites[i]
end

return _class
