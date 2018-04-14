local multisource = require("lib.multisource")
local assets = {}

love.graphics.setDefaultFilter("nearest", "nearest")

assets.tilesheet = love.graphics.newImage("assets/sheet.png")
assets.emptyQuad = love.graphics.newQuad(0, 0, 16, 16, 64, 64)
assets.markerQuad = love.graphics.newQuad(48, 48, 16, 16, 64, 64)
assets.font = love.graphics.newFont("assets/perfectdos.ttf", 20)
assets.totemNormalQuad = love.graphics.newQuad(16, 16, 16, 16, 64, 64)
assets.totemPossessedQuad = love.graphics.newQuad(16, 32, 16, 16, 64, 64)
assets.srbOnQuad = love.graphics.newQuad(0, 16, 16, 16, 64, 64)
assets.srbOffQuad = love.graphics.newQuad(48, 0, 16, 16, 64, 64)
assets.brokenQuad = love.graphics.newQuad(16, 48, 16, 16, 64, 64)

assets.spacePress = multisource.new(love.audio.newSource("assets/select.wav", "static"))
assets.failSpacePress = multisource.new(love.audio.newSource("assets/fail.wav", "static"))
assets.click = multisource.new(love.audio.newSource("assets/click2.wav", "static"))
assets.possess = multisource.new(love.audio.newSource("assets/possess.wav", "static"))
assets.unpossess = multisource.new(love.audio.newSource("assets/unpossess.wav", "static"))
assets.explosion = multisource.new(love.audio.newSource("assets/explo.wav", "static"))
assets.win = multisource.new(love.audio.newSource("assets/win.wav", "static"))
assets.openclose = multisource.new(love.audio.newSource("assets/openclose.wav", "static"))

assets.theme = love.audio.newSource("assets/theme.wav", "stream")
assets.theme:setLooping(true)

return assets
