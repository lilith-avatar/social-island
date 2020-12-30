--- 迷宫游戏
--- @module Maze Module
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local Maze, this = ModuleUtil.New('Maze', ServerBase)

--! 常量配置: Maze 迷宫相关

-- 迷宫尺寸
local NUM_ROWS, NUM_COLS = 8, 8

-- 迷宫Hierachy根节点
local MAZE_ROOT = world.MiniGames.Game_03_Maze

-- 迷宫中心位置
local MAZE_CENTER_POS = Vector3(103, -14.25, 14)
local MAZE_CENTER_ROT = EulerDegree(0, 0, 0)

-- 迷宫Cell里面的常量，包括方向和访问，用于M
local LEFT, UP, RIGHT, DOWN, VISITED = 1, 2, 3, 4, 5

-- 入口、出口位置，只能在左右两侧
local ENTRANCE = math.floor((NUM_ROWS + 1) * .5)
local EXIT = math.ceil((NUM_ROWS + 1) * .5)

-- 入口出口对象
local entrace, exit

--! 常量配置: Floor 迷宫地板相关

-- 迷宫地板厚度
local MAZE_FLOOR_THICKNESS = 2
-- 迷宫地板颜色
local MAZE_FLOOR_COLOR = Color(0xFF, 0xFF, 0xFF, 100)
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
local WALL_SPACE
-- 墙壁对象池隐藏默认位置
local WALL_POOL_POS = Vector3.Down * 100

-- 墙壁位置偏移量
local WALL_POS_OFFSET = CELL_SIDE * .5

-- 墙壁字典，根据方向确定墙壁Transform信息，用于墙壁生成
local WALL_DICT = {}
WALL_DICT[LEFT] = {
    pos = CELL_LEFT_UP_POS + Vector3.Left * WALL_POS_OFFSET + Vector3.Up * WALL_HEIGHT * .5,
    rot = EulerDegree(0, -90, 0),
    dir = 'L',
    symbol = '←'
}
WALL_DICT[UP] = {
    pos = CELL_LEFT_UP_POS + Vector3.Forward * WALL_POS_OFFSET + Vector3.Up * WALL_HEIGHT * .5,
    rot = EulerDegree(0, 0, 0),
    dir = 'U',
    symbol = '↑'
}
WALL_DICT[RIGHT] = {
    pos = CELL_LEFT_UP_POS + Vector3.Right * WALL_POS_OFFSET + Vector3.Up * WALL_HEIGHT * .5,
    rot = EulerDegree(0, 90, 0),
    dir = 'R',
    symbol = '→'
}
WALL_DICT[DOWN] = {
    pos = CELL_LEFT_UP_POS + Vector3.Back * WALL_POS_OFFSET + Vector3.Up * WALL_HEIGHT * .5,
    rot = EulerDegree(0, 180, 0),
    dir = 'D',
    symbol = '↓'
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

--! 其他数据

-- 玩家进入Maze前的数据，退出游戏后需要接恢复
local pTrans = {}

-- 寻路节点
local path = {}
local checkPoints = {}

--! 打印事件日志, true:开启打印
local showLog, PrintMazeData, PrintNodePath = false

--! 初始化

-- 初始化
function Maze:Init()
    print('[Maze] Init()')
    InitMazeWallSpace()
    InitMazeFloor()
    InitMazeEntranceAndExit()
    invoke(InitWallPool)

    --* TEST ONLY
    -- invoke(MazeReset, 5)
end

-- 初始化迷宫墙壁空间
function InitMazeWallSpace()
    WALL_SPACE =
        world:CreateObject(
        'NodeObject',
        'Maze_Wall_Space',
        MAZE_ROOT,
        MAZE_CENTER_POS + Vector3.Up * MAZE_FLOOR_THICKNESS * .5,
        MAZE_CENTER_ROT
    )
end

-- 初始化迷宫地板，与Maze_Wall_Space大小一致
function InitMazeFloor()
    floor = world:CreateObject('Cube', 'Maze_Floor', MAZE_ROOT, MAZE_CENTER_POS, MAZE_CENTER_ROT)
    floor.Color = MAZE_FLOOR_COLOR
    floor:SetActive(false)
end

-- 初始化迷宫入口出口
function InitMazeEntranceAndExit()
    entrace = world:CreateObject('Sphere', 'Entrance', floor)
    exit = world:CreateObject('Sphere', 'Exit', floor)
    entrace.Size = Vector3.One * 0.3
    exit.Size = Vector3.One * 0.3
    entrace.Block = false
    exit.Block = false
    entrace.Color = Color(0x00, 0xFF, 0x00, 0xFF)
    exit.Color = Color(0xFF, 0x00, 0x00, 0xFF)
    entrace:SetActive(false)
    exit:SetActive(false)
end

-- 初始化对象池
function InitWallPool()
    assert(WALL_SPACE and not WALL_SPACE:IsNull(), '[Maze] WALL_SPACE 为空')
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
        objWall = world:CreateInstance(WALL_ARCH, wallName, WALL_SPACE, WALL_POOL_POS, rot)
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
        error('[Maze] 对象池初始化未完成，MazeReset() 不能执行')
        return
    end
    print('[Maze] MazeReset() 迷宫重置')
    -- reset
    MazeFloorReset()
    MazeEntraceAndExitReset()
    MazeDataReset()
    MazeWallsReset()
    CheckPointsReset()
    -- data
    MazeDataGen()
    FindNodePath()
    -- print log
    PrintMazeData()
    PrintNodePath()
    -- gen objs
    MazeWallsGen()
    invoke(CheckPointsGen)
end

-- 重置地板
function MazeFloorReset()
    local rowlen = NUM_ROWS * CELL_SIDE
    local collen = NUM_COLS * CELL_SIDE
    floor.Size = Vector3(collen, MAZE_FLOOR_THICKNESS, rowlen)
    floor:SetActive(true)
end

function MazeEntraceAndExitReset()
    entrace.LocalPosition =
        Vector3(1, 0, -ENTRANCE) * CELL_POS_OFFSET + CELL_LEFT_UP_POS + Vector3.Up * MAZE_FLOOR_THICKNESS * .5
    exit.LocalPosition =
        Vector3(NUM_COLS, 0, -EXIT) * CELL_POS_OFFSET + CELL_LEFT_UP_POS + Vector3.Up * MAZE_FLOOR_THICKNESS * .5
    entrace:SetActive(true)
    exit:SetActive(true)
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

-- 迷宫检查点重置
function CheckPointsReset()
    --TODO: 重置
    for k, n in pairs(checkPoints) do
        if n and not n:IsNull() then
            n:Destroy()
        end
    end
    checkPoints = {}
end

-- 迷宫数据生成
function MazeDataGen()
    -- start point
    local r, c = ENTRANCE, 1
    -- destination point
    local tr, tc = EXIT, NUM_COLS
    -- cell data
    local cell = {r, c}
    -- unvisited cell direction
    local dirs
    -- move direction
    local dir

    history:Clear()
    history:Push(cell)

    while not history:IsEmpty() do
        -- designate this location as visited
        -- VISITED, 0:未访问 ,1:已访问
        M[r][c][VISITED] = 1
        -- dirs if the adjacent cells are valid for moving to
        dirs = {}
        if c > 1 and M[r][c - 1][VISITED] == 0 then
            table.insert(dirs, LEFT)
        end
        if r > 1 and M[r - 1][c][VISITED] == 0 then
            table.insert(dirs, UP)
        end
        if c < NUM_COLS and M[r][c + 1][VISITED] == 0 then
            table.insert(dirs, RIGHT)
        end
        if r < NUM_ROWS and M[r + 1][c][VISITED] == 0 then
            table.insert(dirs, DOWN)
        end

        -- If there is a valid cell to move to.
        -- Mark the walls between cells as open if we move
        if #dirs > 0 then
            history:Push({r, c})
            dir = table.shuffle(dirs)[1]
            if dir == LEFT then
                M[r][c][LEFT] = 1
                c = c - 1
                M[r][c][RIGHT] = 1
            elseif dir == UP then
                M[r][c][UP] = 1
                r = r - 1
                M[r][c][DOWN] = 1
            elseif dir == RIGHT then
                M[r][c][RIGHT] = 1
                c = c + 1
                M[r][c][LEFT] = 1
            elseif dir == DOWN then
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
                    pos = Vector3(col, 0, -row) * CELL_POS_OFFSET + WALL_DICT[dir].pos
                    rot = WALL_DICT[dir].rot
                    objWall = SpawnWall(pos, rot)
                end
            end
        end
    end
end

-- 找出迷宫路径
function FindNodePath()
    -- start point
    local r, c = ENTRANCE, 1
    -- target point
    local tr, tc = EXIT, NUM_COLS

    history:Clear()
    path = {}

    -- found destination point
    local found = false
    -- 用于寻路
    local inDir, outDir = nil, RIGHT
    local idx, node = 1
    -- avaliable directions
    local dirs

    while not found do
        inDir = outDir

        -- 找到方向
        dirs = {}
        if M[r][c][LEFT] == 1 and inDir ~= RIGHT then
            table.insert(dirs, LEFT)
        end
        if M[r][c][UP] == 1 and inDir ~= DOWN then
            table.insert(dirs, UP)
        end
        if M[r][c][RIGHT] == 1 and inDir ~= LEFT then
            table.insert(dirs, RIGHT)
        end
        if M[r][c][DOWN] == 1 and inDir ~= UP then
            table.insert(dirs, DOWN)
        end

        -- 根据可用方向判定情况
        if #dirs > 0 then
            -- 继续走
            outDir = dirs[1]
            if dirs[2] then
                history:Push({r, c, inDir, dirs[2], idx})
            end
            if dirs[3] then
                history:Push({r, c, inDir, dirs[3], idx})
            end
        else
            -- 走到尽头
            node = history:Pop()
            r, c, inDir, outDir, idx = table.unpack(node)
        end

        -- 记录节点信息
        path[idx] = {r, c, inDir, outDir}

        -- 移动到下一个节点
        if outDir == LEFT then
            c = c - 1
        elseif outDir == UP then
            r = r - 1
        elseif outDir == RIGHT then
            c = c + 1
        elseif outDir == DOWN then
            r = r + 1
        end
        idx = idx + 1
        found = (r == tr and c == tc)
    end
end

-- 生成检查点
function CheckPointsGen()
    --TODO: 生成检查点
    local point, r, c
    for k, n in pairs(path) do
        r, c = n[1], n[2]
        if k ~= 1 then
            point = world:CreateObject('Sphere', 'Point_' .. k, floor)
            point.Size = Vector3.One * 0.3
            point.Color = Color(0x00, 0xFF, 0xFF, 0xFF)
            point.LocalPosition =
                Vector3(c, 0, -r) * CELL_POS_OFFSET + CELL_LEFT_UP_POS + Vector3.Up * MAZE_FLOOR_THICKNESS * .5
            table.insert(checkPoints, p)
            point.Block = false
            wait()
        end
    end
end

--! 玩家数据的缓存与读取

-- 玩家进入迷宫前，数据缓存
function CachePlayerTrans(_player)
    pTrans.pos = _player.Position
    pTrans.rot = _player.Rotation
end

-- 玩家离开迷宫后，读取数据
function LoadPlayerTrans(_player)
end

--! Event handlers 事件处理

-- 进入小游戏事件
-- @param _player 玩家
-- @param _gameId 游戏ID
function Maze:EnterMiniGameEventHandler(_player, _gameId)
    if _player and _gameId == Const.GameEnum.MAZE then
        print('[Maze] EnterMiniGameEventHandler', _player, _gameId)
        MazeReset()
        CachePlayerTrans(_player)
        NetUtil.Fire_C('ClientMazeEvent', _player, Const.MazeEventEnum.JOIN, entrace.Position)
    end
end

--! Aux 辅助功能
-- 打印迷宫数据
PrintMazeData = showLog and function()
        for row = 1, NUM_ROWS do
            for col = 1, NUM_COLS do
                print(table.dump(M[row][col]))
            end
            print('============================')
        end
    end or function()
    end

-- 打印寻路结果
PrintNodePath = showLog and function()
        print('打印寻路结果')
        for k, n in pairs(path) do
            print(string.format('[%02d] %s (%s, %s) %s', k, WALL_DICT[n[3]].symbol, n[1], n[2], WALL_DICT[n[4]].symbol))
        end
    end or function()
    end

return Maze
