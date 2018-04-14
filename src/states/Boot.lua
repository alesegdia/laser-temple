local gamestate = require ("lib.gamestate")
Editor = require("src.states.Editor")
local assets = require("src.assets")
local Boot = gamestate.new()

function Boot:enter()
  love.graphics.setFont(assets.font)
  love.audio.setVolume(0)
  assets.theme:play()
end


function Boot:update()

  if love.keyboard.isDown("space") then
    gamestate.switch(ChooseLevel)
  elseif love.keyboard.isDown("f12") then
    gamestate.switch(Editor)
  end

end

local txt = [[
LASER TEMPLE
============

Captain's log - Gagarin-F384 - Stardate 4385.3 

We have landed in a X2S sized asteroid we called X2S9348-3. We sent Kisaka's sentinel team to reckon the surface, but the meeting time has already exceeded the designated threshold. Not anomalous weather was detected and the surface does not show any signs of life, so we start to think that they got trapped or killed. The readings on this asteroid suggests strangely big sized holes in the core. We do not rule out the idea of this being an alien structure. We will continue the search for our crew members, trying to figure out what is happening or at least find some of Kisaka's sentinel team member.

Press space to start...

]]

function Boot:draw()

  love.graphics.clear(0, 0, 0)

  love.graphics.printf(txt, 20, 20, 600, "left")

end

return Boot
