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

--- A many instances sprite based animation class.
--
-- This class does the same than SpriteAnimation, but for many sprites, being a
-- huge optimization as it eliminates the need to instantiate tens or hundreds
-- of objects.
--
-- @classmod Object.Entity.ManySpriteAnimation

local collection    = require("caress/collection")
local Vector        = require("caress/Vector")

local _class = {}

local super

local sprites

local animations = nil

local game
local graphicsDevice

function _class:init(parent, coh, spriteAnimation, size)
  self.super:init(parent)
  super = self.super

  game = GAME
  graphicsDevice = game.graphicsDevice
  local gd = graphicsDevice

  local assetCache = game.assetCache

  animations = spriteAnimation:getAnimations()

  size = size or 0
  self:adjustSize(size)
end

function _class:adjustSize(size)

  sprites = {}
  for i=1,size do
    sprites[i] = {}

    sprites[i].animation = "__none"
    sprites[i].position = Vector.new()
    sprites[i].color = Vector.color(255, 0, 255)
    sprites[i].elapsedTime = 0.0
    sprites[i].currentFrame = 1
  end
end

function _class:update(dt)
  super:update(dt)

  for _, sprite in ipairs(sprites) do
    local selectedAnimation = animations[sprite.animation]
    if selectedAnimation and #selectedAnimation.frames > 0 then
      sprite.elapsedTime = sprite.elapsedTime + dt

      local currFrameTime = selectedAnimation.frames[sprite.currentFrame].time

      if currFrameTime then
        while sprite.elapsedTime > currFrameTime do
          if sprite.currentFrame < #selectedAnimation.frames then
            sprite.currentFrame = sprite.currentFrame + 1
            sprite.elapsedTime = sprite.elapsedTime - currFrameTime
          else
            if selectedAnimation.loop then
              sprite.currentFrame = 1
              sprite.elapsedTime = sprite.elapsedTime - currFrameTime
            else
              sprite.elapsedTime = 0
            end
          end

          currFrameTime = selectedAnimation.frames[sprite.currentFrame].time
        end
      end
    end
  end
end

function _class:draw()
  super:draw()

  for i, sprite in ipairs(sprites) do
    local currFrame = self:getCurrentFrame(i)

    graphicsDevice:drawSprite(
      currFrame.spriteSheet:getSprite(currFrame.spriteIndex),
      sprite.position.x, sprite.position.y
    )
  end
end

function _class:setElapsedTime(i, time)
  sprites[i].elapsedTime = time
end

function _class:getPosition(i)
  return sprites[i].position
end

function _class:setPosition(i, _position)
  sprites[i].position = _position:cpy()
end

function _class:getCurrentAnimation(i)
  return animations[sprites[i].animation]
end

function _class:getCurrentFrame(i)
  local selectedAnimation = self:getCurrentAnimation(i)
  return selectedAnimation.frames[sprites[i].currentFrame]
end

function _class:getWidth(i)
  local currFrame = self:getCurrentFrame(i)
  return currFrame.spriteSheet:getSprite(currFrame.spriteIndex):getWidth()
end

function _class:getHeight(i)
  local currFrame = self:getCurrentFrame(i)
  return currFrame.spriteSheet:getSprite(currFrame.spriteIndex):getHeight()
end

function _class:setAnimation(i, animation)
  sprites[i].animation = animation
  sprites[i].elapsedTime = 0
  sprites[i].currentFrame = 1
end

function _class:checkAnimation(i, animation)
  if animation ~= sprites[i].animation then
    self:setAnimation(i, animation)
  end
end

function _class:setColor(i, _color)
  sprites[i].color = _color
end

return _class
