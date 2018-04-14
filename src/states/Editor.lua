local gamestate = require("lib.gamestate")
local util = require("lib.util")
local Board = require("src.Board")
Editor = gamestate.new()
local BlockSpawner = require("src.BlockSpawner")
local LevelManager = require("src.LevelManager")
local Game = require("src.states.Game")

function Editor:enter()
  self.params = {
    nmapw = 10,
    nmaph = 10,
    current_slot = 1
  }
  self.levelManager = LevelManager()
end

function Editor:leave()

end

function Editor:update()

end

function Editor:keypressed(key, scancode, isrepeat)
  if key == 'u' then self.levelManager:increaseCurrentSlot() end
  if key == 'j' then self.levelManager:decreaseCurrentSlot() end
  if key == 'o' then self.params.nmapw = self.params.nmapw+1 end
  if key == 'l' then self.params.nmapw = self.params.nmapw-1 end
  if key == 'i' then self.params.nmaph = self.params.nmaph+1 end
  if key == 'k' then self.params.nmaph = self.params.nmaph-1 end
  if key == 'c' then
    self.board = Board:new(self.params.nmaph, self.params.nmapw, true, false)
    self.spawner = BlockSpawner:new(self.board)
  end
  if self.board ~= nil then
    if key == "left"  then self.board:moveCursor(-1, 0) end
    if key == "right" then self.board:moveCursor( 1, 0) end
    if key == "up"    then self.board:moveCursor( 0,-1) end
    if key == "down"  then self.board:moveCursor( 0, 1) end
    local cx, cy= self.board:getCursorCoords()
    if key == '1' then self.spawner:spawnSolidBlock(cx, cy) end
    if key == '2' then self.spawner:spawnSolidRemovableBlock(cx, cy) end
    if key == '3' then self.spawner:spawnTotemBlock(cx, cy) end
    if key == '4' then self.spawner:spawnSinkBlock(cx, cy) end
    if key == '5' then self.spawner:spawnSolidBreakableBlock(cx, cy) end

    if key == 'w' then self.spawner:spawnLaserBlock(cx, cy, "d") end
    if key == 'a' then self.spawner:spawnLaserBlock(cx, cy, "l") end
    if key == 's' then self.spawner:spawnLaserBlock(cx, cy, "u") end
    if key == 'd' then self.spawner:spawnLaserBlock(cx, cy, "r") end

    if key == 'q' then
      self.spawner:despawn(cx, cy)
      self.board:remove(cx, cy)
      print ("Despawn")
    end

    if key == "f2" then
      self.levelManager:saveCurrentSlot(self.spawner:getLevelSpawns())
    end
    if key == "f4" then
      local level = self.levelManager:loadCurrentSlot()
      print(level.levelSize[1] .. ", " .. level.levelSize[2])
      self.board = Board:new(level.levelSize[1], level.levelSize[2], true, false)
      self.spawner = BlockSpawner:new(self.board, level)
    end

    if key == "f12" then
      self.levelManager:saveCurrentSlot(self.spawner:getLevelSpawns())
      Game:loadLevel(self.levelManager:loadCurrentSlot())
      gamestate.switch(Game)
    end
  end
end

local legend = [[
arrows -> move
WASD -> laser
1234 -> blocks
Q -> remove block

NEW MAP SIZE = ({nmapw}, {nmaph})
O/L -> increase/decrease new map width
I/K -> increase/decrease new map height
C -> create new map

CURRENT SLOT = {currentslot}
U/J -> increase/decrease current slot
F2 -> save map in current slot
F4 -> load map from current slot
]]

function Editor:renderLegend()
  local final_legend = util.replace_vars {
    legend,
    nmapw = self.params.nmapw,
    nmaph = self.params.nmaph,
    currentslot = self.levelManager:getCurrentSlotText()
  }
  love.graphics.scale(1,1)
  love.graphics.setColor(1, 0, 1)
  love.graphics.print(final_legend, 10, 10) 
  love.graphics.setColor(1, 1, 1)
end

function Editor:draw()
  love.graphics.clear(0, 0, 0)
  if self.board ~= nil then
    self.board:render()
    love.graphics.setColor(1, 1, 1)
  end
  self:renderLegend()
end

return Editor
