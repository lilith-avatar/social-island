--- 迷宫游戏
--- @module Maze Module
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local Maze, this = ModuleUtil.New('Maze', ServerBase)

-- Const
local NUM_ROWS, NUM_COLS = 24, 24
local LEFT, UP, RIGHT, DOWN, VISITED = 1, 2, 3, 4, 5
local WALL_ARCH = 'Maze_Wall_Test'
local CELL_SIDE = 2

local WALL_ROOT_CENTER = Vector3(100, 1.5, 0)

local WALL_ROOT_NODE = world.MiniGames.Game_03_Maze.Walls
local WALL_POOL_ROOT = world.WallPool
local WALL_POOL_POS = Vector3.Down * 100
local WALL_POS_OFFSET = 1
local CELL_POS_OFFSET = CELL_SIDE
local WALL_DICT = {}
local WALL_ROOT_POS = WALL_ROOT_CENTER + Vector3(-NUM_COLS, 0, NUM_ROWS) * CELL_SIDE * .5
WALL_DICT[LEFT] = {
    pos = WALL_ROOT_POS + Vector3.Left * WALL_POS_OFFSET,
    rot = EulerDegree(0, -90, 0),
    dir = 'L'
}
WALL_DICT[UP] = {
    pos = WALL_ROOT_POS + Vector3.Forward * WALL_POS_OFFSET,
    rot = EulerDegree(0, 0, 0),
    dir = 'U'
}
WALL_DICT[RIGHT] = {
    pos = WALL_ROOT_POS + Vector3.Right * WALL_POS_OFFSET,
    rot = EulerDegree(0, 90, 0),
    dir = 'R'
}
WALL_DICT[DOWN] = {
    pos = WALL_ROOT_POS + Vector3.Back * WALL_POS_OFFSET,
    rot = EulerDegree(0, 180, 0),
    dir = 'D'
}

-- The array M is going to hold the array information for each cell.
-- The first four coordinates tell if walls exist on those sides
-- and the fifth indicates if the cell has been visited in the search.
-- M(LEFT, UP, RIGHT, DOWN, CHECK_IF_VISITED)
local M = {}

-- Set starting row and column
local r, c = 1, 1

-- # The history is the stack of visited locations
local history = Stack:New()

-- 对象池
local pool, poolDone = {}, false

--! 打印事件日志, true:开启打印
local showLog, PrintMazeData = false

--! 初始化

-- 初始化
function Maze:Init()
    print('[Maze] Init()')
    invoke(InitWallPool)
end

-- 初始化对象池
function InitWallPool()
    if WALL_POOL_ROOT == nil then
        world:CreateObject('FolderObject', 'WallPool', world)
    end
    WALL_POOL_ROOT = world.WallPool

    -- 总共需要多少面墙
    -- 外墙数 = NUM_ROWS * 2 + NUM_COLS * 2
    -- 内墙数 = (NUM_ROWS - 1) * (NUM_COLS - 1) * 2
    -- 出入口 = -2
    local wallNeeded = NUM_ROWS * 2 + NUM_COLS * 2 + (NUM_ROWS - 1) * (NUM_COLS - 1) * 2 - 2
    print('[Maze] InitWallPool() 需要墙数', wallNeeded)
    local rot = EulerDegree(0, 0, 0)
    local wallName
    for i = 1, wallNeeded do
        wallName = string.format('%s_%04d', WALL_ARCH, i)
        objWall = world:CreateInstance(WALL_ARCH, wallName, WALL_POOL_ROOT, WALL_POOL_POS, rot)
        pool[objWall] = true
        if i % 5 == 0 then
            wait()
        end
    end
    poolDone = true
    print('[Maze] InitWallPool() done')
end

function SpawnWall(_pos, _rot)
    for obj, available in pairs(pool) do
        if available then
            pool[obj] = false
            obj.Position = _pos
            obj.Rotation = _rot
            return obj
        end
    end
    error('[Maze] 墙体数量不够')
end

function DespawnWall(_obj)
    assert(_obj and not _obj:IsNull(), '[Maze] DespawnWall(_obj) _obj不能为空')
    assert(pool[_obj] ~= nil, '[Maze] DespawnWall(_obj) _obj不在对象池中')
    assert(pool[_obj] == false, '[Maze] DespawnWall(_obj) _obj对象池状态错误')
    _obj.Position = WALL_POOL_POS
    pool[_obj] = true
end

function DespaceWalls()
    for obj, _ in pairs(pool) do
        obj.Position = WALL_POOL_POS
        pool[obj] = true
    end
end

--! 迷宫生成

-- 迷宫重置
function MazeReset()
    if not poolDone then
        print('[Maze] 对象池初始化未完成，MazeReset() 不能执行')
        return
    end
    print('[Maze] MazeReset() 迷宫重置')
    MazeDataReset()
    MazeWallReset()
    MazeDataGen()
    PrintMazeData()
    MazeWallGen()
end

-- 迷宫数据重置
function MazeDataReset()
    for row = 1, NUM_ROWS do
        M[row] = {}
        for col = 1, NUM_COLS do
            M[row][col] = {0, 0, 0, 0, 0}
        end
    end
end

-- 迷宫墙壁重置
function MazeWallReset()
    DespaceWalls()
end

-- 迷宫数据生成
function MazeDataGen()
    r, c = 1, 1
    -- cell data
    local cell = {r, c}
    -- unvisited cell direction
    local check
    -- move direction
    local dir

    history:Clear()
    history:Push(cell)

    while not history:IsEmpty() do
        -- designate this location as visited
        M[r][c][VISITED] = 1
        -- check if the adjacent cells are valid for moving to
        check = {}
        if c > 1 and M[r][c - 1][VISITED] == 0 then
            table.insert(check, LEFT)
        end
        if r > 1 and M[r - 1][c][VISITED] == 0 then
            table.insert(check, UP)
        end
        if c < NUM_COLS and M[r][c + 1][VISITED] == 0 then
            table.insert(check, RIGHT)
        end
        if r < NUM_ROWS and M[r + 1][c][VISITED] == 0 then
            table.insert(check, DOWN)
        end

        -- If there is a valid cell to move to.
        -- Mark the walls between cells as open if we move
        if #check > 0 then
            history:Push({r, c})
            dir = table.shuffle(check)[1]
            if dir == LEFT then
                M[r][c][LEFT] = 1
                c = c - 1
                M[r][c][RIGHT] = 1
            end
            if dir == UP then
                M[r][c][UP] = 1
                r = r - 1
                M[r][c][DOWN] = 1
            end
            if dir == RIGHT then
                M[r][c][RIGHT] = 1
                c = c + 1
                M[r][c][LEFT] = 1
            end
            if dir == DOWN then
                M[r][c][DOWN] = 1
                r = r + 1
                M[r][c][UP] = 1
            end
        else
            cell = history:Pop()
            r, c = cell[1], cell[2]
        end
    end

    -- Open the walls at the start and finish
    M[1][1][LEFT] = 1
    M[NUM_ROWS][NUM_COLS][RIGHT] = 1
end

-- 迷宫墙体生成
function MazeWallGen()
    local wallName
    local objWall
    local cell, pos, rot
    for dir = 1, 4 do
        for row = 1, NUM_ROWS do
            for col = 1, NUM_COLS do
                cell = M[row][col]
                if cell[dir] == 0 then
                    pos = Vector3(col * CELL_POS_OFFSET, 0, row * -CELL_POS_OFFSET) + WALL_DICT[dir].pos
                    rot = WALL_DICT[dir].rot
                    objWall = SpawnWall(pos, rot)
                end
            end
        end
    end
end

--! Event handlers 事件处理

-- 进入小游戏事件
-- @param _player 玩家
-- @param _gameId 游戏ID
function Maze:EnterMiniGameEventHandler(_player, _gameId)
    print('[Maze] EnterMiniGameEventHandler', _player, _gameId)
    if _player and _gameId == Const.GameEnum.MAZE then
        MazeReset()
    end
end

--! Aux 辅助功能
-- 日志打印
PrintMazeData = showLog and function()
        for row = 1, NUM_ROWS do
            for col = 1, NUM_COLS do
                print(table.dump(M[row][col]))
            end
            print('============================')
        end
    end or function()
    end

return Maze
