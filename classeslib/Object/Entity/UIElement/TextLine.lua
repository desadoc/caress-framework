
local _class = {}

local game

local text

function _class:init(parent, layer, coh, _text)
  self.super:init(parent, layer, coh)

  game = _game

  text = _text
end

function _class:draw()
  local gd = game.graphicsDevice
  local yOfs = math.floor((self:getSize().y - game.graphicsDevice:getFont():getHeight())/2)
  gd:rawPrintf(text, self:getPosition().x, self:getPosition().y + yOfs, 10000, "left")
end

return _class
