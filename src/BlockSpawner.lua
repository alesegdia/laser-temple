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

function BlockSpawner:init(board, level_data)
  if board == nil then
    error("a board must be provided")
  end
  self.board = board
  self:resetLevelSpawns()
  if level_data ~= nil then
    print("Resetting with previous data file")
    self:resetWithSpawns(level_data)
  end
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
  self:registerSpawn("sb", {}, x, y)
  return block
end

function BlockSpawner:spawnSolidRemovableBlock(x, y)
  local block = self:createBlock(x, y, {
    quad = love.graphics.newQuad(32, 16, 16, 16, 64, 64)
  }, {
    solid = true
  })
end

function BlockSpawner:spawnLaserBlock(x_, y_, direction)
  local block = self:createBlock(x, y, {
    solid = true,
    laser = direction,
    quad = love.graphics.newQuad(0, 32, 16, 16, 64, 64)
  })
  return block
end

function BlockSpawner:spawnTotemBlock(x, y)
  local block = self:createBlock(x, y, {
    totem = true,
    quad = love.graphics.newQuad(16, 16, 16, 16, 64, 64)
  })
end

function BlockSpawner:spawnSinkBlock(x, y)
  local block = self:createBlock(x, y, {
    sink = true,
    quad = love.graphics.newQuad(32, 0, 16, 16, 64, 64)
  })
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

local inspect = require 'lib.inspect'

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function BlockSpawner:resetWithSpawns(level_data)
  local spawn_data = deepcopy(level_data.data)
  for k,spawn in ipairs(spawn_data) do
    print(spawn.pos[1] .. ", " .. spawn.pos[2])
    if spawn.id == "sb" then
      self:spawnSolidBlock(spawn.pos[1], spawn.pos[2])
    end
  end
  print("finished")
end

return BlockSpawner
