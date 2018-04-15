local util = require("lib.util")
local class = require("lib.30log")
local util = require("lib.util")

local BlockSpawner = class "BlockSpawner"

local add_togglable_prop = function (block, name, prop)
  block.togglables[name] = {
    active = true,
    data = prop
  }
  return block
end

function BlockSpawner:init(board, level_data)
  if board == nil then
    error("a board must be provided")
  end
  self.board = board
  self:resetLevelSpawns()
  if level_data ~= nil then
    self:resetWithSpawns(level_data)
  end
end

function BlockSpawner:despawn(x, y)
  print("despawning")
  self.board:remove(x, y)
  util.remove_if(self.levelSpawns.data, function(e)
    return e.pos[1] == x and e.pos[2] == y
  end)
end

function BlockSpawner:createBlock(x_, y_, normal_props, togglable_props)
  self:despawn(x_, y_)
  local block = {
    pos = { x = x_, y = y_ },
    togglables = {},
    toggle = function(self, prop)
      local prop_is_togglable = self.togglables[prop] ~= nil
      assert(prop_is_togglable, "'" .. prop .. "' property not togglable")
      self.togglables[prop].active = not self.togglables[prop].active
    end
  }
  setmetatable(block, {
    __index = function(t, k)
      if t.togglables[k] == nil then
        return nil
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
  self:registerSpawn("sb", {}, x, y)
  return block
end

function BlockSpawner:spawnSolidRemovableBlock(x, y)
  local block = self:createBlock(x, y, {
    quad = love.graphics.newQuad(0, 16, 16, 16, 64, 64)
  }, {
    solid = true
  })
  self:registerSpawn("srb", {}, x, y)
end

function BlockSpawner:spawnSolidRemovableBlockOff(x, y)
  local block = self:createBlock(x, y, {
    quad = love.graphics.newQuad(48, 0, 16, 16, 64, 64)
  }, {
    solid = false
  })
  self:registerSpawn("srbf", {}, x, y)
end

function BlockSpawner:spawnSolidBreakableBlock(x, y)
  local block = self:createBlock(x, y, {
    quad = love.graphics.newQuad(0, 48, 16, 16, 64, 64),
    solid = true,
    breakable = true
  })
  self:registerSpawn("sbb", {}, x, y)
end

function BlockSpawner:spawnLaserBlock(x, y, direction)
  local block = self:createBlock(x, y, {
    solid = true,
    laser = direction,
    breakable = true,
    quad = love.graphics.newQuad(0, 32, 16, 16, 64, 64)
  })
  self:registerSpawn("lb", {laser=direction}, x, y)
end

function BlockSpawner:spawnTotemBlock(x, y)
  local block = self:createBlock(x, y, {
    totem = true,
    solid = true,
    quad = love.graphics.newQuad(16, 16, 16, 16, 64, 64)
  })
  self:registerSpawn("tb", {}, x, y)
end

function BlockSpawner:spawnSinkBlock(x, y)
  local block = self:createBlock(x, y, {
    sink = true,
    quad = love.graphics.newQuad(32, 0, 16, 16, 64, 64)
  })
  self:registerSpawn("kb", {}, x, y)
end

function BlockSpawner:spawnBombBlock(x, y)
  local block = self:createBlock(x, y, {
    bomb = true,
    quad = love.graphics.newQuad(32, 48, 16, 16, 64, 64)
  })
  self:registerSpawn("bb", {}, x, y)
end

function BlockSpawner:registerSpawn(block_id, extra_data, x, y)
  table.insert(self.levelSpawns.data, {
    pos = { x, y },
    id = block_id,
    extra = extra_data
  })
end

function BlockSpawner:getLevelSpawns()
  return self.levelSpawns
end

function BlockSpawner:resetLevelSpawns()
  assert(self.board ~= nil)
  self.levelSpawns = {
    data = {},
    levelSize = {
      self.board.width, self.board.height
    }
  }
end


function BlockSpawner:resetWithSpawns(level_data)
  local spawn_data = util.deepcopy(level_data.data)
  for k,spawn in ipairs(spawn_data) do
    if spawn.id == "sb" then self:spawnSolidBlock(spawn.pos[1], spawn.pos[2]) end
    if spawn.id == "srb" then self:spawnSolidRemovableBlock(spawn.pos[1], spawn.pos[2]) end
    if spawn.id == "sbb" then self:spawnSolidBreakableBlock(spawn.pos[1], spawn.pos[2]) end
    if spawn.id == "lb" then self:spawnLaserBlock(spawn.pos[1], spawn.pos[2], spawn.extra.laser) end
    if spawn.id == "tb" then self:spawnTotemBlock(spawn.pos[1], spawn.pos[2]) end
    if spawn.id == "kb" then self:spawnSinkBlock(spawn.pos[1], spawn.pos[2]) end
    if spawn.id == "bb" then self:spawnBombBlock(spawn.pos[1], spawn.pos[2]) end
    if spawn.id == "srbf" then self:spawnSolidRemovableBlockOff(spawn.pos[1], spawn.pos[2]) end

  end
end

return BlockSpawner
