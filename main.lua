local gamestate = require("lib.gamestate")
local Boot = require("src.states.Boot")

function love.load(arg)
	math.randomseed(os.time())
	love.mouse.setVisible(false)
  love.keyboard.setKeyRepeat(false)
	gamestate.registerEvents()
	gamestate.switch(Boot)
end


