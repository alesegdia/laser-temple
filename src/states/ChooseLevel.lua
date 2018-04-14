local gamestate = require("lib.gamestate")
ChooseLevel = gamestate.new()
local LevelManager = require("src.LevelManager")

local level_mgr = LevelManager()
local current_level = 1
local win_game = false

function ChooseLevel:nextLevel()
  current_level = current_level + 1
  if current_level == level_mgr.lastLoadedLevel then
    win_game = true
  end
end

function ChooseLevel:enter()
end

function ChooseLevel:draw()
  if not win_game then
    love.graphics.print("LEVEL " .. current_level, 10, 10)
    love.graphics.print("Press space to begin", 10, 30)
  else
    love.graphics.print("You reached the exit!")
  end
end

function ChooseLevel:keypressed(key, scancode, isrepeat)
  if key == "space" then
    if win_game then
      
    else
      Game:loadLevel(level_mgr:tryLoadLevel(current_level))
      gamestate.switch(Game) 
    end
  end
end
