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

--- Graphics Device class
--
-- This is an interface for drawing and managing graphics state. It is a
-- wrapper to love.graphics calls and implements layer based rendering.
-- 
-- @classmod Object.GraphicsDevice

local Vector  = require("caress/Vector")
local List    = require("caress/collection").List
local classes = require("caress/classes")

local _class = {}

function _class:init(width, height, layers)
  self.width = width
  self.height = height

  self.canvases = {}

  for layer, depth in pairs(layers) do
    if not self.canvases[depth] then
      self.canvases[depth] = love.graphics.newCanvas(width, height)
    end
  end
end

function _class:setDefaultFilter(min, mag, aniso)
  love.graphics.setDefaultFilter(min, mag, aniso)
end

function _class:setBackgroundColor(color)
  love.graphics.setBackgroundColor(color.x, color.y, color.z, color.w)
end

function _class:newCanvas(width, height, format, msaa)
  return love.graphics.newCanvas(width, height, format, msaa)
end

function _class:getCanvas()
  return love.graphics.getCanvas()
end

function _class:setCanvas(canvas)
  love.graphics.setCanvas(canvas)
end

function _class:getColor()
  return Vector.color(love.graphics.getColor())
end

function _class:setColor(color)
  love.graphics.setColor(color.x, color.y, color.z, color.w)
end

function _class:getBackgroundColor()
  return Vector.color(love.graphics.getBackgroundColor())
end

function _class:setBackgroundColor(color)
  love.graphics.setBackgroundColor(color.x, color.y, color.z, color.w)
end

function _class:getFont()
  return love.graphics.getFont()
end

function _class:newQuad(...)
  return love.graphics.newQuad(...)
end

function _class:newSpriteBatch(...)
  return love.graphics.newSpriteBatch(...)
end

function _class:newImageData(width, height)
  return love.image.newImageData(width, height)
end

function _class:newImage(imageData)
  return love.graphics.newImage(imageData)
end

function _class:getLineStyle()
  return love.graphics.getLineStyle()
end

function _class:setLineStyle(style)
  love.graphics.setLineStyle(style)
end

function _class:getBlendMode()
  return love.graphics.getBlendMode()
end

function _class:setBlendMode(mode)
  love.graphics.setBlendMode(mode)
end

function _class:push()
  love.graphics.push()
end

function _class:pop()
  love.graphics.pop()
end

function _class:origin()
  love.graphics.origin()
end

--- Clears current canvas/layer.
function _class:clear(bgColor)
  local _bgColor

  if bgColor then
    _bgColor = self:getBackgroundColor()
    self:setBackgroundColor(bgColor)
  end

  love.graphics.clear()

  if bgColor then
    self:setBackgroundColor(_bgColor)
  end
end

--- Clears all layers.
function _class:clearLayers()
  local _canvas = love.graphics.getCanvas()
  local _bgColor = {love.graphics.getBackgroundColor()}
  love.graphics.setBackgroundColor(0, 0, 0, 0)
  for depth, canvas in pairs(self.canvases) do
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
  end
  love.graphics.setBackgroundColor(unpack(_bgColor))
  love.graphics.setCanvas(_canvas)
end

--- Switches to 'target' layer then calls 'func'.
function _class:renderTo(func, target)
  local canvas

  if type(target) == "number" then
    canvas = self.canvases[target]
  end

  if getmetatable(target) and target.type and target:type() == "Canvas" then
    canvas = target
  end

  if canvas then
    local _canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(canvas)
    func()
    love.graphics.setCanvas(_canvas)
  else
    love.errhand("invalid render target")
  end
end

function _class:flush()
  local depthList = List.new()
  for depth, _ in pairs(self.canvases) do
    depthList:push_back(depth)
  end
  depthList:sort(nil, "desc")

  self:origin()

  for _, depth in depthList:iterator() do
    love.graphics.draw(self.canvases[depth])
  end
end

local function drawAABBLine(aabb, lineWidth)
  local pos = Vector.new(aabb.x, aabb.y)
  local size = Vector.new(aabb.z, aabb.w)

  lineWidth = lineWidth or 1.0

  -- bottom
  love.graphics.rectangle(
    "fill", pos.x, pos.y + size.y - lineWidth, size.x, lineWidth)
  -- top
  love.graphics.rectangle(
    "fill", pos.x, pos.y, size.x, lineWidth)
  -- left
  love.graphics.rectangle(
    "fill", pos.x, pos.y, lineWidth, size.y)
  -- right
  love.graphics.rectangle(
    "fill", pos.x + size.x - lineWidth, pos.y, lineWidth, size.y)
end

local function drawAABBFill(aabb)
  local r_pos = {x = aabb.x, y = aabb.y}
  love.graphics.rectangle(
    "fill", r_pos.x, r_pos.y,
    aabb.z, aabb.w
  )
end

local function _drawAABB(mode, aabb, color, lineWidth)
  if mode == "line" then
    drawAABBLine(aabb, lineWidth)
  end
  if mode == "fill" then
    drawAABBFill(aabb)
  end
end

function _class:drawAABB(mode, aabb, color, lineWidth)
  color = color or Vector.color(255, 0, 255)

  local _color = {love.graphics.getColor()}
  love.graphics.setColor(color.x, color.y, color.z, color.w)

  _drawAABB(mode, aabb, color, lineWidth)

  love.graphics.setColor(unpack(_color))
end

function _class:drawAABBList(mode, aabbList, color, lineWidth)
  color = color or Vector.color(255, 0, 255)

  local _color = {love.graphics.getColor()}
  love.graphics.setColor(color.x, color.y, color.z, color.w)

  local drawFunc
  if mode == "line" then
    drawFunc = drawAABBLine
  end
  if mode == "fill" then
    drawFunc = drawAABBFill
  end

  for _, aabb in aabbList:iterator() do
    drawFunc(aabb, lineWidth)
  end

  love.graphics.setColor(unpack(_color))
end

function _class:drawCircle(mode, baseX, baseY, radius, color, segments)
  color = color or Vector.color(255, 0, 255)
  segments = segments or 24

  local _color = {love.graphics.getColor()}
  love.graphics.setColor(color.x, color.y, color.z, color.w)

  love.graphics.circle(mode, baseX, baseY+radius, radius, segments)

  love.graphics.setColor(unpack(_color))
end

local function drawAnimf(anim, x, y, r, sx, sy)

end

local function drawSprite(spr, x, y, r, sx, sy)
  love.graphics.draw(
    spr:getSpriteSheet():getImage(),
    spr:getQuad(), x, y, r, sx, sy
  )
end

--- Draws animations, sprites or other love.graphics objects like canvases.
function _class:draw(obj, x, y, color, sx, sy, r)
  color = color or Vector.color(255, 255, 255)
  sx = sx or 1.0
  sy = sy or 1.0
  r = r or 0.0

  local _color = {love.graphics.getColor()}

  love.graphics.setColor(color.x, color.y, color.z, color.w)

  local width = obj:getWidth() * sx
  local height = obj:getHeight() * sy

  x = x or 0.0
  y = y or 0.0

  if obj.class == classes.Object.FrameAnimation then
    local currAnimation = obj:getCurrentAnimation()
    local currFrame = obj:getCurrentFrame()

    drawSprite(
      currFrame.spriteSheet:getSprite(currFrame.spriteIndex),
       x, y, r, sx, sy
    )
  elseif obj.class == classes.Object.Sprite then
    drawSprite(obj, x, y, r, sx, sy)
  else
    love.graphics.draw(obj, x, y, r, sx, sy)
  end

  love.graphics.setColor(unpack(_color))
end

function _class:drawBatch(batch)
  love.graphics.draw(batch)
end

function _class:rawPrintf(text, px, py, limit, align,
    r, sx, sy, ox, oy, kx, ky)
  love.graphics.printf(text, px, py, limit, align, r, sx, sy, ox, oy, kx, ky)
end

return _class
