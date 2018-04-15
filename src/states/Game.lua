local gamestate = require("lib.gamestate")
Game = gamestate.new()
local BlockSpawner = require("src.BlockSpawner")
local LevelManager = require("src.LevelManager")
local Board = require("src.Board")
local assets = require("src.assets")
local util = require("lib.util")
require ("src.states.ChooseLevel")

function Game:loadLevel(level)
  local totems = self:clearTotems(level)
  self.board = Board(level.levelSize[1], level.levelSize[2], false, false)
  self.spawner = BlockSpawner(self.board, level)
  self.totemBoard = Board(totems.levelSize[1], totems.levelSize[2], true, true)
  self.totemSpawner = BlockSpawner(self.totemBoard, totems)
  self.board:setBroBoard(self.totemBoard)
end

function Game:clearTotems(level)
  local totems = util.deepcopy(level.data)
  local no_totems = util.deepcopy(level.data)

  util.remove_if(totems, function(e)
    return e.id ~= "tb"
  end)

  util.remove_if(no_totems, function(e)
    return e.id == "tb"
  end)

  level.data = no_totems
  
  return {
    levelSize = level.levelSize,
    data = totems
  }
end

function Game:enter()
  below_cursor = nil
  below_cursor_totem = nil
  self.possessedTotem = nil
  self.winThisLevel = false
end

local below_cursor = nil
local below_cursor_totem = nilREMOVE

function Game:update()
  if self.board.dead then
    info_message = "You failed... [PRESS SPACE] to restart level"
  else
    local cur = self.totemBoard.cursor
    below_cursor = self.board:get(cur[1], cur[2])
    below_cursor_totem = self.totemBoard:get(cur[1], cur[2])
    if self.possessedTotem ~= nil then
      info_message = "[PRESS ARROWS] to [MOVE] totem. [PRESS SPACE] to [DROP] the totem."
    elseif below_cursor_totem ~= nil then
      info_message = "[PRESS SPACE] to [LIFT] the totem."
    elseif below_cursor ~= nil then
      if below_cursor.breakable then
        info_message = "This block can be destroyed with lasers."
      elseif below_cursor.sink then
        info_message = "This is a sink. [MOVE] totems here."
      elseif below_cursor.togglables["solid"] then
        info_message = "[PRESS SPACE] to [TOGGLE] solidness."
      else
        info_message = "You must [MOVE] all the totems to sinks."
      end
    else
      info_message = "You must [MOVE] all the totems to sinks."
    end
  end

  if below_cursor ~= nil and below_cursor.bomb and below_cursor_totem ~= nil then
    self.board.dead = true
    below_cursor_totem.quad = love.graphics.newQuad(32, 32, 16, 16, 64, 64)
    assets.explosion:play()
  end

end


function Game:handleMoveKey(pressed_key, test_key, dx, dy)
  if pressed_key == test_key then
    if self.possessedTotem == nil or self:tryMovePossessedTotem(dx, dy) then
      assets.click:play()
      self.totemBoard:moveCursor(dx, dy)
    else
      assets.failSpacePress:play()
    end
    if not self.winThisLevel then
      self.winThisLevel = self:checkWin()
      if self.winThisLevel then
        assets.win:play()
      end
    end
  end
end

function Game:checkWin()
  local sinks = self.board:getWithProp("sink")
  local totems = self.totemBoard.entities
  local wins = 0
  local ntotems = 0
  for kt, totem in pairs(totems) do
    ntotems = ntotems + 1
    for ks, sink in pairs(sinks) do
      if totem.pos.x == sink.pos.x and totem.pos.y == sink.pos.y then
        wins = wins + 1
      end
    end
  end
  return wins == ntotems
end

function Game:keypressed(key, scancode, isrepeat)
  if key == "escape" then
    love.event.quit()
  end
  if not self.board.dead then
    if not self.winThisLevel then
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
  else
    if key == "space" then
      gamestate.switch(ChooseLevel)
    end
  end
  if self.winThisLevel and key == "space" then
    ChooseLevel:nextLevel()
    gamestate.switch(ChooseLevel)
  end
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
  elseif below_cursor ~= nil then
    if below_cursor.togglables["solid"] ~= nil then
      below_cursor:toggle("solid")
      assets.openclose:play()
      if below_cursor.solid and below_cursor.breakable == nil then
        below_cursor.quad = assets.srbOnQuad
      else
        below_cursor.quad = assets.srbOffQuad
      end
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
      print(totem_free)
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

  if self.winThisLevel then
    info_message = "The exit opens! [PRESS SPACE] to procceed to next level."
  end
  if info_message ~= nil then
    love.graphics.print(info_message, 20, 20)
  end
end

return Game
