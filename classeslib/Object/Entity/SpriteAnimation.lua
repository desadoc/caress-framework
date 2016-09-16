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

--- A sprite based animation class.
--
-- This class implements an animation with frames loaded from images.
-- The animation is described by an lua file which contains image paths,
-- timing and possibly more information like relative position and size.
-- An animation file may contain more than one animation, as the example below.
--
-- Fields position, size and rect aren't mandatory optional. Position, size and
-- image may be defined at any level inside the structure and deeper fields
-- override values inherited from less nested levels, eg., you may specify image
-- a single time directly at the root and it will apply to every animation and
-- frame. Rect and time may only exist at frame level. Time is optional too,
-- and it's absence indicates that all frames have equal times and they sum up
-- to 1 second.
--
-- @classmod Object.Entity.SpriteAnimation

--- @usage
local usage = [[
return {
   still = {
       frames = {
           {
               image = "dog/dog_still.png"
           }
       }
   },
   walking = {
       frames = {
           {
               image = "dog/dog_walking_01.png",
               time = 0.16,
           },
           {
               image = "dog/dog_walking_02.png",
               time = 0.16,
           }
       },
       loop = true,
   },
   yump = {
       position = {x=0, y=0.1},
       size = {x=1.0, y=1.0},
       frames = {
           {
               rect = {x=0.25, y=0, z=0.5, w=0.5}
               image = "dog/dog_yump.png"
           }
       }
   }
}
]]

local collection    = require("caress/collection")
local Vector        = require("caress/Vector")

local _class = {}

local position = Vector.new()
local color = Vector.color(255, 0, 255)
local elapsedTime = 0.0
local currentFrame = 1

local animations = nil
local selectedAnimation = nil

local game
local graphicsDevice

function _class:init(parent, layer, coh, aniCfg)
  self.super:init(parent, layer, coh)

  game = _game
  graphicsDevice = game.graphicsDevice
  local gd = graphicsDevice

  local assetCache = game.assetCache 

  animations = collection.tableCopy(aniCfg, true)

  for aniName, aniInfo in pairs(animations) do
    if not aniInfo.size then
      aniInfo.size = {x=1.0, y=1.0}
    end
    for i, frame in pairs(aniInfo.frames) do
      frame.spriteSheet = assetCache:load(frame.spriteSheet .. ".sprs")
      if coh then
        coh:checkTimeLimit()
      end
    end
  end

  self.parent = parent
end

function _class:update(dt)
  self.super:update(dt)
  
  if not selectedAnimation then
    return
  end

  if #selectedAnimation.frames == 0 then
    return
  end

  elapsedTime = elapsedTime + dt
  
  local currFrameTime = selectedAnimation.frames[currentFrame].time
  
  if not currFrameTime then
    return
  end
  
  while elapsedTime > currFrameTime do
    if currentFrame < #selectedAnimation.frames then
      currentFrame = currentFrame + 1
      elapsedTime = elapsedTime - currFrameTime
    else
      if selectedAnimation.loop then
        currentFrame = 1
        elapsedTime = elapsedTime - currFrameTime
      end
    end
    
    currFrameTime = selectedAnimation.frames[currentFrame].time
  end
end

function _class:draw()
  self.super:draw()
  graphicsDevice:draw(self, position.x, position.y)
end

function _class:setElapsedTime(time)
  elapsedTime = time
end

function _class:getPosition()
  return position
end

function _class:setPosition(_position)
  position = Vector.new_cpy(_position)
end

function _class:getCurrentAnimation()
  return selectedAnimation
end

function _class:getCurrentFrame()
  return selectedAnimation.frames[currentFrame]
end

function _class:getWidth()
  local currFrame = self:getCurrentFrame()
  return currFrame.spriteSheet:getSprite(currFrame.spriteIndex):getWidth()
end

function _class:getHeight()
  local currFrame = self:getCurrentFrame()
  return currFrame.spriteSheet:getSprite(currFrame.spriteIndex):getHeight()
end

function _class:setAnimation(animation)
  selectedAnimation = animations[animation]
  elapsedTime = 0
  currentFrame = 1
end

function _class:checkAnimation(animation)
  if selectedAnimation ~= animations[animation] then
    self:setAnimation(animation)
  end
end

function _class:setColor(_color)
  color = _color
end

return _class
