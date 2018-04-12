local gamestate = require("lib.gamestate")
local util = require("lib.util")
local Board = require("src.Board")
local Editor = gamestate.new()
local BlockSpawner = require("src.entities.BlockSpawner")


function Editor:enter()
  self.params = {
    nmapw = 10,
    nmaph = 10
  }
  self.cursor = {1, 1}
end


function Editor:leave()

end


function Editor:update()

end


function Editor:keypressed(key, scancode, isrepeat)
  if key == 'o' then self.params.nmapw = self.params.nmapw+1 end
  if key == 'l' then self.params.nmapw = self.params.nmapw-1 end
  if key == 'i' then self.params.nmaph = self.params.nmaph+1 end
  if key == 'k' then self.params.nmaph = self.params.nmaph-1 end
  if key == 'c' then
    self.board = Board:new(self.params.nmaph, self.params.nmapw)
    self.spawner = BlockSpawner:new(self.board)
  end
  if self.board ~= nil then
    if key == "left"  then self.board:moveCursor(-1, 0) end
    if key == "right" then self.board:moveCursor( 1, 0) end
    if key == "up"    then self.board:moveCursor( 0,-1) end
    if key == "down"  then self.board:moveCursor( 0, 1) end
  end
  if key == 'q' then self.spawner:spawnSolidBlock(self.board.getCursorCoords()) end
end

local legend = [[
arrows -> move
A -> clear
S -> solid block
D -> solid deactivable block

NEW MAP SIZE = ({nmapw}, {nmaph})
O/L -> increase/decrease new map width
I/K -> increase/decrease new map height
C -> create new map
]]

function Editor:renderLegend()
  local final_legend = util.replace_vars {
    legend,
    nmapw = self.params.nmapw,
    nmaph = self.params.nmaph
  }
  love.graphics.scale(1,1)
  love.graphics.print(final_legend, 10, 10) 
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
