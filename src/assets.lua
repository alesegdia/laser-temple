
local assets = {}

love.graphics.setDefaultFilter("nearest", "nearest")

assets.tilesheet = love.graphics.newImage("assets/sheet.png")
assets.emptyQuad = love.graphics.newQuad(0, 0, 16, 16, 64, 64)

return assets
