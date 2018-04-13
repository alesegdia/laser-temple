local class = require("lib.30log")
local Board = class "Board"
local assets = require("src.assets")

function Board:init(width, height)
  self.width, self.height = width, height
  self.size = width * height
  self.entities = {}
  self:alloc()
  self.cursor = { 1, 1 }
end

function Board:alloc()
  self.data = {}
  for i=1,self.height do
    self.data[i] = {}
    for j=1,self.width do
      self.data[i][j] = nil
    end
  end
end

function Board:get(x, y)
  self:validateCoords(x, y)
  return self.data[y][x]
end

function Board:set(x, y, element)
  self:validateCoords(x, y)
  self.data[y][x] = element
  table.insert(self.entities, element)
  return element
end

function Board:remove(x, y)
  local removed_value = self:get(x, y)
  if removed_value ~= nil then
    local key_to_remove = nil
    for k,v in pairs(self.entities) do
      if v == removed_value then
        key_to_remove = k
      end
    end
    table.remove(self.entities, k)
  end
  return removed_value
end

function Board:validateCoords(x, y)
  assert(x >= 1 and x <= self.width and
         y >= 1 and y <= self.height, "Board get out of bounds!")
end

function Board:eachCell(fun)
  for i=1,self.height do
    for j=1,self.width do
      fun(self.data[i][j], j, i)
    end
  end
end

function Board:eachEntity(fun)
  for k,v in pairs(self.entities) do
    fun(v)
  end
end

function Board:moveCursor(x, y)
  local ncx = self.cursor[1] + x
  local ncy = self.cursor[2] + y
  self.cursor[1] = math.max(1, math.min(self.width, ncx))
  self.cursor[2] = math.max(1, math.min(self.height, ncy))
end

function Board:getCursorCoords()
  return self.cursor[1], self.cursor[2]
end

function Board:render()
  love.graphics.push()
  local s = 3
  local ww = love.graphics.getWidth() / 2
  local wh = love.graphics.getHeight() / 2
  love.graphics.scale(s, s)
  local dx = ww / s - self.width  * 16 / 2
  local dy = wh / s - self.height * 16 / 2
  love.graphics.translate(dx, dy)
  self:eachCell(function(cell, x, y)
    local quad = assets.emptyQuad
    if cell ~= nil then
      quad = cell.quad
    end
    love.graphics.draw(assets.tilesheet, quad, (x-1) * 16, (y-1) * 16) 
  end)
  love.graphics.draw(assets.tilesheet, assets.markerQuad, (self.cursor[1]-1) * 16, (self.cursor[2]-1) * 16)
  love.graphics.pop()
end

return Board
