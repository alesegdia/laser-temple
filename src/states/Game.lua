local gamestate = require("lib.gamestate")
Game = gamestate.new()
local BlockSpawner = require("src.BlockSpawner")
local LevelManager = require("src.LevelManager")
local Board = require("src.Board")

function Game:loadLevel(level)
  local totems = self:clearTotems(level)
  self.board = Board(level.levelSize[1], level.levelSize[2])
  self.spawner = BlockSpawner(self.board, level)
  print("imere")
end

function Game:clearTotems(level)
  local totem_keys = {}
  local totems = {}
  for k,v in ipairs(level.data) do
    if v.id == "tb" then
      print("totem")
      table.insert(totem_keys, k)
    end
  end
  for k,v in ipairs(totem_keys) do
    local totem = level.data[k]
    table.remove(level.data, k)
    table.insert(totems, totem)
  end
  return {
    levelSize = level.levelSize,
    data = totems
  }
end

function Game:enter()
end

function Game:update()

end

function Game:keypressed(key, scancode, isrepeat)
  if key == "left"  then self.board:moveCursor(-1, 0) end
  if key == "right" then self.board:moveCursor( 1, 0) end
  if key == "up"    then self.board:moveCursor( 0,-1) end
  if key == "down"  then self.board:moveCursor( 0, 1) end

  if key == "f12" then gamestate.switch(Editor) end
end

function Game:draw()
  love.graphics.clear(0, 0, 0)
  if self.board ~= nil then
    self.board:render()
    love.graphics.setColor(1, 1, 1)
  end
end

return Game
