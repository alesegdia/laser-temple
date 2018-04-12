
return setmetatable({}, {
  __call = function
    local board = require("src.Board")
    board:init(10, 10)
    local block_spawner = require("src.BlockSpawner")
    block_spawner:init(board)
    local b1 = block_spawner:spawnSolidBlock(1, 1)
    assert(false == pcall(function()
      b1:toggle
    end))
  end
})
