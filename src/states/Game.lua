local gamestate = require("lib.gamestate")
Game = gamestate.new()
local BlockSpawner = require("src.BlockSpawner")
local LevelManager = require("src.LevelManager")
local Board = require("src.Board")
local assets = require("src.assets")

function Game:loadLevel(level)
  local totems = self:clearTotems(level)
  self.board = Board(level.levelSize[1], level.levelSize[2], false, false)
  self.spawner = BlockSpawner(self.board, level)
  self.totemBoard = Board(totems.levelSize[1], totems.levelSize[2], true, true)
  self.totemSpawner = BlockSpawner(self.totemBoard, totems)
  self.board:setBroBoard(self.totemBoard)
end

function Game:clearTotems(level)
  local totem_keys = {}
  local totems = {}
  for k,v in ipairs(level.data) do
    if v.id == "tb" then
      table.insert(totem_keys, k)
    end
  end
  for k,v in ipairs(totem_keys) do
    local totem = level.data[v]
    table.remove(level.data, v)
    table.insert(totems, totem)
  end
  return {
    levelSize = level.levelSize,
    data = totems
  }
end

function Game:enter()
  love.graphics.setFont(assets.font)
end

function Game:update()

end

function Game:handleMoveKey(pressed_key, test_key, dx, dy)
  if pressed_key == test_key then
    assets.click:play()
    if self.possessedTotem == nil or self:tryMovePossessedTotem(dx, dy) then
      self.totemBoard:moveCursor(dx, dy)
    end
  end
end

function Game:keypressed(key, scancode, isrepeat)
  self:handleMoveKey(key, "left", -1, 0)
  self:handleMoveKey(key, "right", 1, 0)
  self:handleMoveKey(key, "up", 0, -1)
  self:handleMoveKey(key, "down", 0, 1)

  local cx, cy = self.totemBoard.cursor[1], self.totemBoard.cursor[2]

  if key == "space" then
    self:handleSpacePress(cx, cy)
  end

  if key == "f12" then gamestate.switch(Editor) end
end

function Game:handleSpacePress(cx, cy)
  local success_click = false
  local totem = self.totemBoard:get(cx, cy)
  if totem ~= nil then
    success_click = true
    if self.possessedTotem == nil then
      self.possessedTotem = totem
      totem.quad = assets.totemPossessedQuad
      assets.possess:play()
    else
      self.possessedTotem.quad = assets.totemNormalQuad
      self.possessedTotem = nil
      assets.unpossess:play()
    end
  end
  return success_click
end

function Game:tryMovePossessedTotem(dx, dy)
  if self.possessedTotem ~= nil then
    local tx, ty = self.possessedTotem.pos.x, self.possessedTotem.pos.y
    local nx, ny = tx + dx, ty + dy
    if self.board:validCoords(nx, ny) then
      local board_free = self:isFree(self.board, nx, ny)
      local totem_free = self:isFree(self.totemBoard, nx, ny)
      if board_free and totem_free then
        self.totemBoard:movePiece(tx, ty, nx, ny)
        return true
      end
      return false
    end
    return false
  end
  return false
end

function Game:isFree(board, x, y)
  local cell = board:get(x, y)
  return cell == nil or (cell ~= nil and not cell.solid)
end

function Game:draw()
  love.graphics.clear(0, 0, 0)
  if self.board ~= nil then
    self.board:render()
    self.totemBoard:render()
    love.graphics.setColor(1, 1, 1)
  end
end

return Game
