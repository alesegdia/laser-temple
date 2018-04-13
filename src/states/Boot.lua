local gamestate = require ("lib.gamestate")
local Editor = require("src.states.Editor")

local Boot = gamestate.new()


function Boot:update()

  if love.keyboard.isDown("1") then
    print("meh")
    gamestate.switch(Editor)
  end

end

function Boot:draw()

  love.graphics.clear(1, 0, 0)
  love.graphics.print("1. choose level", 10, 10) 
  love.graphics.print("2. editor", 10, 30) 

end

return Boot
