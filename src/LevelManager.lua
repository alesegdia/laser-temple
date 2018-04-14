local class = require("lib.30log")
local LevelManager = class "LevelManager"
require "lib.tablesave"

function LevelManager:init()
  self.levelsDir = love.filesystem.getSourceBaseDirectory() .. "/levels/"
  self.levels = {}
  self.lastLoadedLevel = 1
  self.currentSlot = 1

  repeat
    level = self:tryLoadLevel(self.lastLoadedLevel)
    if level ~= nil then
      self.levels[self.lastLoadedLevel] = level
      self.lastLoadedLevel = self.lastLoadedLevel + 1
    end
  until level == nil
end

function LevelManager:increaseCurrentSlot()
  self.currentSlot = math.min(self.lastLoadedLevel + 1, self.currentSlot + 1)
end

function LevelManager:decreaseCurrentSlot()
  self.currentSlot = math.max(1, self.currentSlot - 1)
end

function LevelManager:getCurrentSlotText()
  if self.currentSlot == self.lastLoadedLevel + 1 then
    return self.currentSlot .. ": new level"
  else
    return self.currentSlot
  end 
end

function LevelManager:saveCurrentSlot(data)
  self:saveLevel(self.currentSlot, data)
end

function LevelManager:loadCurrentSlot()
  print("Trying to load current slot level: " .. self.currentSlot)
  return self:tryLoadLevel(self.currentSlot)
end

function LevelManager:saveLevel(level, data)
  table.save(data, self.levelsDir .. level)
end

function LevelManager:tryLoadLevel(level)
  t, err = table.load(self.levelsDir .. level)
  return t
end

return LevelManager
