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

--- Abstract game class.
--
-- Only one implementation of this class needs to exist per application. It
-- coordinates top level game logic, like intro, title screen, level start and
-- end, load, save, and acts as a root of game entity hierarchy, being the
-- uppermost parent.
--
-- @classmod Object.Entity.Game

local Vector      = require("caress/Vector")
local collection  = require("caress/collection")
local classes     = require("caress/classes")
local save        = require("caress/save")

local AssetCache  = require("caress/AssetCache")

local Input     = classes.Object.Entity.Input

local _class = {}

local CONFIG
local gamepad
local canvas
local frameTimeAccum = 0.0

--- Initializes a Game instance.
-- Game mantains a reference to game configuration loaded from 'conf.lua' on
-- game's root folder. It also initializes asset cache, graphics and input
-- devices.
function _class:init(_CONFIG, layers)
  self.super:init()

  CONFIG = _CONFIG
  self.CONFIG = CONFIG

  self.layers = layers

  math.randomseed(os.time())

  for i, joystick in ipairs(love.joystick.getJoysticks()) do
    if joystick:isGamepad() then
      gamepad = joystick
      break
    end
  end

  local tgtWidth, tgtHeight = self:getTargetDimensions()

  canvas = love.graphics.newCanvas(tgtWidth, tgtHeight)
  canvas:setFilter("nearest", "nearest", 1)

  self.assetCache = AssetCache.new()
  self.graphicsDevice = classes.Object.GraphicsDevice(tgtWidth, tgtHeight, self.layers)
  self.graphicsDevice:setDefaultFilter("nearest", "nearest", 1)
end

function _class:hasGamepad()
  if gamepad then return true end
end

function _class:getDefaultConfig()
  return save.load("conf.lua")
end

--- Flushes user configuration to conf.ini on save folder
-- This method compares current CONFIG variable with defaults returned by
-- conf.lua, and flushes to disk all the differences.
function _class:flushUserConfig()

  local diff = {}
  local defaults_root = self:getDefaultConfig()

  local function copyDifferences(defaults, custom, target)
    for k, v in pairs(defaults) do
      local custom_value = custom[k]

      if type(v) ~= "table" then
        if type(v) ~= "function" then
          if custom_value and custom_value ~= v then
            target[k] = custom_value
          end
        end
      else
        target[k] = {}
        copyDifferences(defaults[k], custom_value, target[k])
      end
    end
  end

  copyDifferences(defaults_root, CONFIG, diff)

  save.save(CONFIG.userConfFilename, diff)
end

function _class:main(coh)
  self.input = self:create(Input, nil, coh, gamepad):start()
end

function _class:getMaxScaling()
  local maxScalingX =
    math.modf(CONFIG.window.width/CONFIG.game.baseCanvasWidth)
  local maxScalingY =
    math.modf(CONFIG.window.height/CONFIG.game.baseCanvasHeight)

  return math.min(maxScalingX, maxScalingY)
end

--- Returns the internal game resolution,
-- This resolution is scaled proportionaly to screen size by an integer number.
function _class:getTargetDimensions()
  return CONFIG.game.baseCanvasWidth, CONFIG.game.baseCanvasHeight
end

--- Updates game by a fixed timestep.
-- Timestep is fixed and multiple child updates are run if necessary.
function _class:update(dt)
  -- if framerate drops bellow 16 fps, a slowdown is introduced
  -- to keep gameplay smooth
  local maxTimePerFrame = 1.0/16
  if dt > maxTimePerFrame then
    dt = maxTimePerFrame
  end

  if not self:isPaused() then
    frameTimeAccum = frameTimeAccum + dt

    local timestep = CONFIG.game.updateTimeStepSize
    while(frameTimeAccum >= timestep) do
      self.super:update(timestep)

      frameTimeAccum = frameTimeAccum - timestep
    end
  end
end

function _class:_drawCanvas(canvas)
  love.graphics.origin()

  local canvasWidth, canvasHeight = self:getTargetDimensions()

  local scaling = self:getMaxScaling()
  local x = (CONFIG.window.width - canvasWidth*scaling)/2.0
  local y = (CONFIG.window.height - canvasHeight*scaling)/2.0
  love.graphics.draw(canvas, x, y, 0, scaling, scaling)
end

--- Draws childs then merges layers to screen.
function _class:draw()
  local gd = self.graphicsDevice

  if gd then
    gd:clear()

    gd:clearLayers()
    if not self:isHidden() then
      self.super:draw()
    end

    gd:setCanvas(canvas)
    canvas:clear()
    gd:flush()
    gd:setCanvas()

    self:_drawCanvas(canvas)
  end
end

function _class:keypressed(key, isRepeat)
  if self.input and not self.input:isPaused() then
    self.input:registerKeyboardInput("keypressed", key, isRepeat)
  end
end

function _class:keyreleased(key)
  if self.input and not self.input:isPaused() then
    self.input:registerKeyboardInput("keyreleased", key)
  end
end

function _class:gamepadpressed(joystick, button)
  if not gamepad then return end

  if self.input and not self.input:isPaused() then
    if joystick:getID() ~= gamepad:getID() then
      return
    end
    self.input:registerGamepadInput("keypressed", button)
  end
end

function _class:gamepadreleased(joystick, button)
  if not gamepad then return end

  if self.input and not self.input:isPaused() then
    if joystick:getID() ~= gamepad:getID() then
      return
    end
    self.input:registerGamepadInput("keyreleased", button)
  end
end

--- Closes application.
function _class:quit()
  love.event.quit()
end

return _class
