local util = require("lib.util")
local class = require("lib.30log")

local BlockSpawner = class "BlockSpawner"

local add_togglable_prop = function (block, name, prop)
  block.togglables[name] = {
    active = true,
    data = prop
  }
  return block
end

function BlockSpawner:init(board)
  if board == nil then
    error("a board must be provided")
  end
  self.board = board
end

function BlockSpawner:createBlock(x_, y_, normal_props, togglable_props)
  self.board:remove(x_, y_)
  local block = {
    pos = { x = x_, y = y_ },
    togglables = {},
    toggle = function(self, prop)
      local prop_is_togglable = self.togglables[prop] ~= nil
      assert(prop_is_togglable, "'" .. prop .. "' property not togglable")
      self.togglables[prop].active = false
    end
  }
  setmetatable(block, {
    __index = function(t, k)
      if t.togglables[k] == nil then
        error(k .. " property not togglable")
      end
      if t.togglables[k].active then
        return t.togglables[k].data
      else
        return nil
      end
    end
  })
  self.board:set(block.pos.x, block.pos.y, block)
  util.mergeAtFirst(block, normal_props)
  if togglable_props ~= nil then 
    for k,v in pairs(togglable_props) do
      add_togglable_prop(block, k, v)
    end
  end
  return block
end

function BlockSpawner:spawnSolidBlock(x, y)
  local block = self:createBlock(x, y, {
    solid = true,
    quad = love.graphics.newQuad(16, 0, 16, 16, 64, 64)
  })
  return block
end

function BlockSpawner:spawnLaserBlock(x_, y_, direction)
  local block = {
    solid = true,
    position = { x = x_, y = y_ },
    laser = direction,
  }
  return self:addToBoard(block)
end

function BlockSpawner: spawnTwinBlocks(x1, y1, x2, y2)
  local plus = self:createBlock(x1, y1, {
    solid = true
  })
  local minus = self:createBlock(x2, y2, {
    solid = true,
    twin = plus,
    breakable = true
  });
  return plus, minus
end


return BlockSpawner
