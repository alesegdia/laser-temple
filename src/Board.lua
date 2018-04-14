local class = require("lib.30log")
local Board = class "Board"
local assets = require("src.assets")

function Board:init(width, height, showcursor, totemboard)
  self.totemBoard = totemboard or false
  self.showCursor = showcursor or false 
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

function Board:movePiece(x1, y1, x2, y2)
  local piece = self:get(x1, y1)
  piece.pos.x, piece.pos.y = x2, y2
  self:set(x1, y1, nil)
  self:set(x2, y2, piece)
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
  assert(self:validCoords(x, y), "Board get out of bounds!")
end

function Board:validCoords(x, y)
  return x >= 1 and x <= self.width and
         y >= 1 and y <= self.height
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
  local lasers = {}
  self:eachCell(function(cell, x, y)
    local quad = assets.emptyQuad
    if cell ~= nil then
      quad = cell.quad
    end
    local cx, cy = (x-1) * 16, (y-1) * 16
    if not self.totemBoard or (self.totemBoard and cell ~= nil and cell.totem) then
      love.graphics.draw(assets.tilesheet, quad, cx, cy)
    end
    if cell ~= nil and cell.laser then
      local rx, ry = self:ray(cell.pos.x, cell.pos.y, cell.laser)
      local rcx, rcy = (rx-1) * 16 + 8, (ry-1) * 16 + 8
      local ocx, ocy = cx + 8, cy + 8
      if cell.laser == 'u' then rcy = rcy + 8 end
      if cell.laser == 'd' then rcy = rcy - 8 end
      if cell.laser == 'l' then rcx = rcx - 8 end
      if cell.laser == 'r' then rcx = rcx + 8 end
      table.insert(lasers, { from = {ocx, ocy}, to = {rcx, rcy} })
    end
  end)
  for k,v in pairs(lasers) do
      love.graphics.setColor(1, 0, 1)
      love.graphics.line(v.from[1], v.from[2], v.to[1], v.to[2])
      love.graphics.setColor(1, 1, 1)
  end
  if self.showCursor then
    love.graphics.draw(assets.tilesheet, assets.markerQuad, (self.cursor[1]-1) * 16, (self.cursor[2]-1) * 16)
  end
  love.graphics.pop()
end

function Board:ray(x, y, dir)
  local dx, dy
  local hit = false
  if dir == 'u' then dx, dy =  0,  1 end
  if dir == 'd' then dx, dy =  0, -1 end
  if dir == 'l' then dx, dy = -1,  0 end
  if dir == 'r' then
    x = x + 2
    dx, dy =  1,  0
  end
  while hit == false do
    x, y = x + dx, y + dy
    if self:validCoords(x, y) then
      local cell = self:get(x, y)
      if cell ~= nil and cell.solid then
        hit = true
        x, y = x - dx, y - dy
      end
    else
      hit = true
      x, y = x - dx, y - dy
    end
  end
  return x, y
end

return Board
