--- 迷宫游戏
--- @module Maze Module
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local Maze, this = ModuleUtil.New('Maze', ServerBase)

--! 常量配置: Maze 迷宫相关

-- 迷宫尺寸
local NUM_ROWS, NUM_COLS = 6, 8

-- 迷宫中心位置
local MAZE_CENTER_POS = Vector3(100, 1.5, 0)
local MAZE_CENTER_ROT = EulerDegree(0, 0, 0)

-- 迷宫Cell里面的常量，包括方向和访问，用于M
local LEFT, UP, RIGHT, DOWN, VISITED = 1, 2, 3, 4, 5

-- 入口、出口位置，只能在左右两侧
local ENTRANCE = math.floor(NUM_ROWS * .5)
local EXIT = ENTRANCE

--! 常量配置: Floor 迷宫地板相关

-- 迷宫地板厚度
local MAZE_FLOOR_THICKNESS = 0.2
-- 迷宫地板颜色
local MAZE_FLOOR_COLOR = Color(255, 255, 255, 100)
-- 迷宫地板Obj，根据迷宫中心和尺寸生成
local floor

--! 常量配置: Cell 迷宫单元格相关

-- 迷宫Cell单元格尺寸
local CELL_SIDE = 2

-- 迷宫Cell位置偏移量
local CELL_POS_OFFSET = CELL_SIDE

-- 迷宫左上角的Cell中心位置
local CELL_LEFT_UP_POS = Vector3(-NUM_COLS - 1, 0, NUM_ROWS + 1) * CELL_SIDE * .5

--! 常量配置: Wall 墙体相关

-- 墙体的Archetype
local WALL_ARCH = 'Maze_Wall_Test'
local WALL_HEIGHT = 1 -- 对应Size.Y
local WALL_LENGTH = 2 -- 对应Size.X
local WALL_THICKNESS = 0.2 -- 对应Size.Z

-- 墙壁对象池Hierachy根节点
local WALL_POOL_ROOT = world.MiniGames.Game_03_Maze
-- 墙壁对象池隐藏默认位置
local WALL_POOL_POS = Vector3.Down * 100

-- 墙壁位置偏移量
local WALL_POS_OFFSET = CELL_SIDE * .5

-- 墙壁字典，根据方向确定墙壁Transform信息，用于墙壁生成
local WALL_DICT = {}
WALL_DICT[LEFT] = {
    pos = CELL_LEFT_UP_POS + Vector3.Left * WALL_POS_OFFSET + Vector3.Up * WALL_HEIGHT * .5,
    rot = EulerDegree(0, -90, 0),
    dir = 'L'
}
WALL_DICT[UP] = {
    pos = CELL_LEFT_UP_POS + Vector3.Forward * WALL_POS_OFFSET + Vector3.Up * WALL_HEIGHT * .5,
    rot = EulerDegree(0, 0, 0),
    dir = 'U'
}
WALL_DICT[RIGHT] = {
    pos = CELL_LEFT_UP_POS + Vector3.Right * WALL_POS_OFFSET + Vector3.Up * WALL_HEIGHT * .5,
    rot = EulerDegree(0, 90, 0),
    dir = 'R'
}
WALL_DICT[DOWN] = {
    pos = CELL_LEFT_UP_POS + Vector3.Back * WALL_POS_OFFSET + Vector3.Up * WALL_HEIGHT * .5,
    rot = EulerDegree(0, 180, 0),
    dir = 'D'
}

--! 迷宫生成数据信息

-- M用于存储迷宫生成数据
-- The array M is going to hold the array information for each cell.
-- The first four coordinates tell if walls exist on those sides
-- and the fifth indicates if the cell has been visited in the search.
-- M(LEFT, UP, RIGHT, DOWN, CHECK_IF_VISITED)
local M = {}

-- Set starting row and column
local r, c = ENTRANCE, 1

-- # The history is the stack of visited locations
local history = Stack:New()

--! 墙体对象池信息

-- 对象池，对象池生成完毕
local pool, poolDone = {}, false

--! 打印事件日志, true:开启打印
local showLog, PrintMazeData = false

--! 初始化

-- 初始化
function Maze:Init()
    print('[Maze] Init()')
    InitMazeFloor()
    invoke(InitWallPool)
end

-- 初始化迷宫地板
function InitMazeFloor()
    floor = world:CreateObject('Cube', 'Maze_Floor', WALL_POOL_ROOT, MAZE_CENTER_POS, MAZE_CENTER_ROT)
    floor.Color = MAZE_FLOOR_COLOR
end

-- 初始化对象池
function InitWallPool()
    WALL_POOL_ROOT = floor

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

-- 从对象池中拿取墙壁obj
function SpawnWall(_pos, _rot)
    for obj, available in pairs(pool) do
        if available then
            pool[obj] = false
            obj.LocalPosition = _pos
            obj.LocalRotation = _rot
            obj:SetActive(true)
            return obj
        end
    end
    error('[Maze] 墙体数量不够')
end

-- 对象池回收墙壁obj
function DespawnWall(_obj)
    assert(_obj and not _obj:IsNull(), '[Maze] DespawnWall(_obj) _obj不能为空')
    assert(pool[_obj] ~= nil, '[Maze] DespawnWall(_obj) _obj不在对象池中')
    assert(pool[_obj] == false, '[Maze] DespawnWall(_obj) _obj对象池状态错误')
    -- _obj.Position = WALL_POOL_POS
    _obj:SetActive(false)
    pool[_obj] = true
end

-- 回收全部墙壁obj
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
    MazeFloorReset()
    MazeDataReset()
    MazeWallsReset()
    MazeDataGen()
    PrintMazeData()
    MazeWallsGen()
end

function MazeFloorReset()
    local rowlen = NUM_ROWS * CELL_SIDE
    local collen = NUM_COLS * CELL_SIDE
    floor.Size = Vector3(collen, MAZE_FLOOR_THICKNESS, rowlen)
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
function MazeWallsReset()
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
    M[ENTRANCE][1][LEFT] = 1
    M[EXIT][NUM_COLS][RIGHT] = 1
end

-- 迷宫墙体生成
function MazeWallsGen()
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
