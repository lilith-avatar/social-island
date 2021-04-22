--- 迷宫游戏
--- @module Maze Module
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local Maze, this = ModuleUtil.New('Maze', ServerBase)

--! 打印事件日志, true:开启Debug模式
local debug, PrintMazeData, PrintNodePath, GenNodePath = false

--! 常量配置: 玩家相关

-- 游戏时长(秒)
local TOTAL_TIME = 30
local PRE_WAIT_TIME = 1 --迷宫开始前，玩家等待时间
local POST_WAIT_TIME = .8 --迷宫结束后，玩家等待时间

--! 常量配置: Maze 迷宫相关

-- 迷宫尺寸
local NUM_ROWS, NUM_COLS = 10, 10

-- 迷宫Hierachy根节点
local MAZE_ROOT = world.MiniGames.Game_03_Maze

-- 迷宫中心位置
local MAZE_CENTER_POS = Vector3(-10, 40, 0)
local MAZE_CENTER_ROT = EulerDegree(0, 0, 0)

-- 迷宫大小缩放
local MAZE_SCALE = 6

-- 迷宫Cell里面的常量，包括方向和访问，用于M
local LEFT, UP, RIGHT, DOWN, VISITED = 1, 2, 3, 4, 5

-- 入口、出口位置，只能在左右两侧
local ENTRANCE = 1
local EXIT = NUM_ROWS

-- 入口出口对象
local entrace, exit
-- 角落flag，用于计算角落的位置
local cornerFlag
-- 四个角落的坐标
local corners = {}

--! 常量配置: Floor 迷宫地板相关

-- 迷宫地板厚度
local MAZE_FLOOR_THICKNESS = 2
-- 迷宫地板颜色
-- local MAZE_FLOOR_COLOR = Color(0x9E, 0x9E, 0x9E, 255)
local MAZE_FLOOR_COLOR = Color(0x9E, 0x9E, 0x9E, 00)
-- 迷宫地板Obj，根据迷宫中心和尺寸生成
local floor, floorDeco
-- 地板的Archetype（仅装饰）
local FLOOR_DECO_ARCH = 'Big_Cloud'
-- 地板装饰的偏移
local FLOOR_DECO_OFFSET = Vector3(0, -4, 0)

--! 常量配置: Cell 迷宫单元格相关

-- 迷宫Cell单元格尺寸
local CELL_SIDE = .54 * MAZE_SCALE
-- 迷宫Cell位置偏移量
local CELL_POS_OFFSET = CELL_SIDE
-- 迷宫左上角的Cell中心位置
local CELL_LEFT_UP_POS = Vector3(-NUM_COLS - 1, 0, NUM_ROWS + 1) * CELL_SIDE * .5

--! 常量配置: Wall & Pillar 墙体相关

-- 墙体的Archetype
local WALL_ARCH = 'Maze_Wall_Cloud'
-- 对应Size.Y
local WALL_HEIGHT = .35 * MAZE_SCALE
-- 对应Size.X
local WALL_LENGTH = CELL_SIDE
-- 对应Size.Z
local WALL_THICKNESS = 0.04 * MAZE_SCALE
-- 墙壁位移
local WALL_OFFSET = Vector3(0, 0.75, 0)

-- 柱子的Archetype
-- local PILLAR_ARCH = 'Maze_Pillar'
-- 对应Size.Y
local PILLAR_HEIGHT = WALL_HEIGHT

-- 墙壁对象池Hierachy根节点
local WALL_SPACE
-- 墙壁对象池隐藏默认位置
local WALL_POOL_POS = Vector3.Down * 100

-- 墙壁对象池Hierachy根节点
local PILLAR_SPACE
-- 墙壁对象池隐藏默认位置
local PILLAR_POOL_POS = Vector3.Down * 100

-- 墙壁位置偏移量
local WALL_POS_OFFSET = CELL_SIDE * .5

-- 墙壁字典，根据方向确定墙壁Transform信息，用于墙壁生成
local WALL_DICT = {}
WALL_DICT[LEFT] = {
    pos = CELL_LEFT_UP_POS + Vector3.Left * WALL_POS_OFFSET,
    rot = EulerDegree(0, -180, 0),
    dir = 'L',
    symbol = '←'
}
WALL_DICT[UP] = {
    pos = CELL_LEFT_UP_POS + Vector3.Forward * WALL_POS_OFFSET,
    rot = EulerDegree(0, -90, 0),
    dir = 'U',
    symbol = '↑'
}
WALL_DICT[RIGHT] = {
    pos = CELL_LEFT_UP_POS + Vector3.Right * WALL_POS_OFFSET,
    rot = EulerDegree(0, 0, 0),
    dir = 'R',
    symbol = '→'
}
WALL_DICT[DOWN] = {
    pos = CELL_LEFT_UP_POS + Vector3.Back * WALL_POS_OFFSET,
    rot = EulerDegree(0, 90, 0),
    dir = 'D',
    symbol = '↓'
}

--! 常量配置: Boundary 空气墙相关

-- 高度，厚度
local BOUNDARY_HEIGHT, BOUNDARY_THICKNESS = 3, .5
local boundary = {}

--! 常量配置: Check Point 积分点相关

-- 积分点总数
local TOTAL_CHECKER = 20

-- 墙壁对象池Hierachy根节点
local CHECKER_SPACE
-- 墙壁对象池隐藏默认位置
local CHECKER_POOL_POS = Vector3.Down * 100

--! 常量配置: 金币相关

-- 金币价值
local COIN_VAL = 100

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

--! 对象池

-- 墙壁对象池，墙壁对象池生成完毕
local wallPool, wallPoolDone = {}, false
-- 柱子对象池，柱子对象池生成完毕
local pillarPool, pillarPoolDone = {}, false
-- 积分点对象池，积分点对象池生成完毕
local checkerPool, checkerPoolDone = {}, false

--! 其他数据

-- 玩家数据
local playerData

-- 寻路节点
local path = {}
local pathNodes = {}

-- 计数器id
local timer, startTime, now = 0, 0, Timer.GetTime

-- Debug模式下显示透明度，非debug模式为0
local DEBUG_ALPHA = debug and 0x10 or 0x00

--! 初始化

-- 初始化
function Maze:Init()
    print('[Maze] Init()')
    InitMazeWallSpace()
    InitPillarSpace()
    InitMazeCheckerSpace()
    InitMazeFloor()
    InitMazeEntranceAndExit()
    InitMazeCornerFlog()
    invoke(InitBoundary) -- 空气墙
    invoke(InitCheckerPool, .2) -- 对象池：检查点
    invoke(InitWallPool, 1) -- 对象池：墙
    invoke(InitPillarPool, 1) -- 对象池：柱子
    MazeHide()
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

-- 初始化柱子空间
function InitPillarSpace()
    PILLAR_SPACE =
        world:CreateObject(
        'NodeObject',
        'Maze_Pillar_Space',
        MAZE_ROOT,
        MAZE_CENTER_POS + Vector3.Up * MAZE_FLOOR_THICKNESS * .5,
        MAZE_CENTER_ROT
    )
end

-- 初始化检查点空间
function InitMazeCheckerSpace()
    CHECKER_SPACE =
        world:CreateObject(
        'NodeObject',
        'Maze_Checker_Space',
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

    -- 生成地板实体
    if not string.isnilorempty(FLOOR_DECO_ARCH) then
        floorDeco =
            world:CreateInstance(
            FLOOR_DECO_ARCH,
            'Maze_Floor_Deco',
            MAZE_ROOT,
            MAZE_CENTER_POS + FLOOR_DECO_OFFSET,
            MAZE_CENTER_ROT
        )
        floorDeco:SetActive(false)
    end
end

-- 初始化迷宫入口出口
function InitMazeEntranceAndExit()
    entrace = world:CreateObject('Sphere', 'Entrance', floor)
    exit = world:CreateObject('Sphere', 'Exit', floor)
    entrace.Size = Vector3.One * 0.3 * CELL_SIDE
    exit.Size = Vector3.One * 0.3 * CELL_SIDE
    entrace.Block = false
    exit.Block = false
    entrace.Color = Color(0x00, 0xFF, 0x00, DEBUG_ALPHA)
    exit.Color = Color(0xFF, 0x00, 0x00, DEBUG_ALPHA)
    entrace:SetActive(false)
    exit:SetActive(false)
    --* 出口事件绑定
    -- exit.OnCollisionBegin:Connect(PlayerReachExit)
end

-- 初始化迷宫角落flag
function InitMazeCornerFlog()
    cornerFlag = world:CreateObject('Sphere', 'CornerFlag', floor)
    cornerFlag.Size = Vector3.One * 0.3 * CELL_SIDE
    cornerFlag.Color = Color(0xFF, 0x00, 0x00, DEBUG_ALPHA)
    cornerFlag:SetActive(false)
end

-- 初始化空气墙
function InitBoundary()
    wait()
    boundary.left = world:CreateObject('Cube', 'Boundary_Left', floor)
    boundary.right = world:CreateObject('Cube', 'Boundary_Right', floor)
    boundary.up = world:CreateObject('Cube', 'Boundary_Up', floor)
    boundary.down = world:CreateObject('Cube', 'Boundary_Down', floor)
    boundary.ceil = world:CreateObject('Cube', 'Boundary_Ceil', floor)
    -- 尺寸
    boundary.left.Size = Vector3(NUM_COLS * CELL_SIDE, BOUNDARY_HEIGHT, BOUNDARY_THICKNESS)
    boundary.right.Size = Vector3(NUM_COLS * CELL_SIDE, BOUNDARY_HEIGHT, BOUNDARY_THICKNESS)
    boundary.up.Size = Vector3(NUM_ROWS * CELL_SIDE, BOUNDARY_HEIGHT, BOUNDARY_THICKNESS)
    boundary.down.Size = Vector3(NUM_ROWS * CELL_SIDE, BOUNDARY_HEIGHT, BOUNDARY_THICKNESS)
    boundary.ceil.Size = Vector3(NUM_ROWS * CELL_SIDE, BOUNDARY_THICKNESS, NUM_ROWS * CELL_SIDE)
    -- 颜色
    boundary.left.Color = Color(0xFF, 0xFF, 0xFF, DEBUG_ALPHA)
    boundary.right.Color = Color(0xFF, 0xFF, 0xFF, DEBUG_ALPHA)
    boundary.up.Color = Color(0xFF, 0xFF, 0xFF, DEBUG_ALPHA)
    boundary.down.Color = Color(0xFF, 0xFF, 0xFF, DEBUG_ALPHA)
    boundary.ceil.Color = Color(0xFF, 0xFF, 0xFF, DEBUG_ALPHA)
    -- Transform
    local arroundHeight = (MAZE_FLOOR_THICKNESS + BOUNDARY_HEIGHT) * .5
    local offsetX = (NUM_ROWS * CELL_SIDE + BOUNDARY_THICKNESS) * .5
    local offsetY = (NUM_COLS * CELL_SIDE + BOUNDARY_THICKNESS) * .5
    -- local pos
    boundary.left.LocalPosition = Vector3(-offsetX, arroundHeight, 0)
    boundary.right.LocalPosition = Vector3(offsetX, arroundHeight, 0)
    boundary.up.LocalPosition = Vector3(0, arroundHeight, -offsetY)
    boundary.down.LocalPosition = Vector3(0, arroundHeight, offsetY)
    boundary.ceil.LocalPosition = Vector3(0, (MAZE_FLOOR_THICKNESS + BOUNDARY_THICKNESS) * .5 + BOUNDARY_HEIGHT, 0)
    -- local rot
    boundary.left.LocalRotation = EulerDegree(0, 90, 0)
    boundary.right.LocalRotation = EulerDegree(0, 90, 0)
end

-- 初始化对象池 - 墙壁
function InitWallPool()
    if wallPoolDone then
        return
    end
    assert(WALL_SPACE and not WALL_SPACE:IsNull(), '[Maze] WALL_SPACE 为空')
    -- 总共需要多少面墙
    -- 外墙数 = NUM_ROWS * 2 + NUM_COLS * 2
    -- 内墙数 = (NUM_ROWS - 1) * (NUM_COLS - 1)
    -- 出入口 = -2
    local wallNeeded = NUM_ROWS * 2 + NUM_COLS * 2 + (NUM_ROWS - 1) * (NUM_COLS - 1)
    print('[Maze] InitWallPool() 需要墙数', wallNeeded)
    local rot = EulerDegree(0, 0, 0)
    local name
    for i = 1, wallNeeded do
        name = string.format('%s_%04d', WALL_ARCH, i)
        objWall = world:CreateInstance(WALL_ARCH, name, WALL_SPACE, WALL_POOL_POS, rot)
        objWall.Scale = MAZE_SCALE
        wallPool[objWall] = true
        if i % 5 == 0 then
            wait()
        end
    end
    wallPoolDone = true
    print('[Maze] InitWallPool() done 迷宫墙壁对象池初始化完毕')
end

-- 初始化对象池 - 柱子
function InitPillarPool()
    -- 如果不需要柱子或者柱子已经生成
    if pillarPoolDone or string.isnilorempty(PILLAR_ARCH) then
        pillarPoolDone = true
        return
    end
    assert(PILLAR_SPACE and not PILLAR_SPACE:IsNull(), '[Maze] PILLAR_SPACE 为空')
    -- 总共需要多少柱子
    local pillarNeeded = (NUM_ROWS + 1) * (NUM_COLS + 1)
    print('[Maze] InitPillarPool() 需要柱子数', pillarNeeded)
    local rot = EulerDegree(0, 0, 0)
    local name
    for i = 1, pillarNeeded do
        name = string.format('%s_%04d', PILLAR_ARCH, i)
        objPillar = world:CreateInstance(PILLAR_ARCH, name, PILLAR_SPACE, PILLAR_POOL_POS, rot)
        objPillar.Scale = MAZE_SCALE
        pillarPool[objPillar] = true
        if i % 5 == 0 then
            wait()
        end
    end
    pillarPoolDone = true
    print('[Maze] InitPillarPool() done 迷宫柱子对象池初始化完毕')
end

-- 初始化对象池 - 积分点
function InitCheckerPool()
    if checkerPoolDone then
        return
    end
    assert(CHECKER_SPACE and not CHECKER_SPACE:IsNull(), '[Maze] CHECKER_SPACE 为空')
    local rot = EulerDegree(0, 0, 0)
    local name
    for i = 1, TOTAL_CHECKER do
        name = string.format('Check_Point_%04d', i)
        local objChecker = world:CreateObject('Sphere', name, CHECKER_SPACE, CHECKER_POOL_POS, rot)
        objChecker.Size = Vector3.One * 0.5 * CELL_SIDE * MAZE_SCALE
        objChecker.Block = false
        objChecker.Color = Color(0x00, 0x00, 0xFF, DEBUG_ALPHA * 3)
        objChecker.OnCollisionBegin:Connect(
            function(_hitObj)
                PlayerHitChecker(_hitObj, objChecker)
            end
        )
        checkerPool[objChecker] = true
        wait()
    end
    checkerPoolDone = true
    print('[Maze] InitCheckerPool() done 迷宫积分点对象池初始化完毕')
end

--! 对象池生成和回收，墙壁

-- 从对象池中拿取墙壁obj
function SpawnWall(_pos, _rot)
    for obj, available in pairs(wallPool) do
        if available then
            wallPool[obj] = false
            obj.LocalPosition = _pos
            obj.LocalRotation = _rot
            obj:SetActive(true)
            return obj
        end
    end
    error('[Maze] SpawnWall() 墙体数量不够')
end

-- 对象池回收墙壁obj
function DespawnWall(_obj)
    assert(_obj and not _obj:IsNull(), '[Maze] DespawnWall(_obj) _obj不能为空')
    assert(wallPool[_obj] ~= nil, '[Maze] DespawnWall(_obj) _obj不在对象池中')
    assert(wallPool[_obj] == false, '[Maze] DespawnWall(_obj) _obj对象池状态错误')
    -- _obj.Position = WALL_POOL_POS
    _obj:SetActive(false)
    wallPool[_obj] = true
end

-- 回收全部墙壁obj
function DespawnWalls()
    for obj, _ in pairs(wallPool) do
        obj.Position = WALL_POOL_POS
        wallPool[obj] = true
    end
end

--! 对象池生成和回收，柱子

-- 从对象池中拿取墙壁obj
function SpawnPillar(_pos, _rot)
    for obj, available in pairs(pillarPool) do
        if available then
            pillarPool[obj] = false
            obj.LocalPosition = _pos
            obj.LocalRotation = _rot
            obj:SetActive(true)
            return obj
        end
    end
    error('[Maze] SpawnPillar() 柱子数量不够')
end

-- 对象池回收墙壁obj
function DespawnPillar(_obj)
    assert(_obj and not _obj:IsNull(), '[Maze] DespawnPillar(_obj) _obj不能为空')
    assert(pillarPool[_obj] ~= nil, '[Maze] DespawnPillar(_obj) _obj不在对象池中')
    assert(pillarPool[_obj] == false, '[Maze] DespawnPillar(_obj) _obj对象池状态错误')
    _obj:SetActive(false)
    pillarPool[_obj] = true
end

-- 回收全部墙壁obj
function DespawnPillars()
    for obj, _ in pairs(pillarPool) do
        obj.Position = PILLAR_POOL_POS
        pillarPool[obj] = true
    end
end

--! 对象池生成和回收，积分点

-- 从对象池中取出积分点obj
function SpawnChecker(_pos, _rot)
    for obj, available in pairs(checkerPool) do
        if available then
            checkerPool[obj] = false
            obj.LocalPosition = _pos
            obj.LocalRotation = _rot
            obj:SetActive(true)
            return obj
        end
    end
    error('[Maze] SpawnChecker() 积分点数量不够')
end

-- 对象池回积分点obj
function DespawnChecker(_obj)
    assert(_obj and not _obj:IsNull(), '[Maze] DespawnChecker(_obj) _obj不能为空')
    assert(checkerPool[_obj] ~= nil, '[Maze] DespawnChecker(_obj) _obj不在对象池中')
    assert(checkerPool[_obj] == false, '[Maze] DespawnChecker(_obj) _obj对象池状态错误')
    _obj:SetActive(false)
    checkerPool[_obj] = true
end

-- 回收全部积分点obj
function DespawnCheckers()
    for obj, _ in pairs(checkerPool) do
        obj.Position = CHECKER_POOL_POS
        obj:SetActive(false)
        checkerPool[obj] = true
    end
end

--! 迷宫生成

-- 迷宫重置
function MazeReset()
    if not wallPoolDone or not pillarPoolDone or not checkerPoolDone then
        error('[Maze] 对象池初始化未完成，MazeReset() 不能执行')
        return
    end
    print('[Maze] MazeReset() 迷宫重置')
    -- reset
    MazeFloorReset()
    MazeEntraceAndExitReset()
    MazeConrnerReset()
    MazeDataReset()
    MazeObjsReset()
    -- data
    MazeDataGen()
    FindNodePath()
    -- print log
    PrintMazeData()
    PrintNodePath()
    -- gen objs
    invoke(MazeWallsGen)
    invoke(PillarsGen)
    invoke(CoinGen)
    -- MazeCheckersGen()
    -- invoke(GenNodePath)
    -- show maze
    MazeShow()
end

-- 重置地板
function MazeFloorReset()
    local rowlen = NUM_ROWS * CELL_SIDE
    local collen = NUM_COLS * CELL_SIDE
    floor.Size = Vector3(collen, MAZE_FLOOR_THICKNESS, rowlen)
    floor:SetActive(true)
    if floorDeco then
        floorDeco:SetActive(true)
    end
end

-- 重置入口出口
function MazeEntraceAndExitReset()
    entrace.LocalPosition =
        Vector3(1, 0, -ENTRANCE) * CELL_POS_OFFSET + CELL_LEFT_UP_POS +
        Vector3.Up * (MAZE_FLOOR_THICKNESS + WALL_HEIGHT) * .5
    exit.LocalPosition =
        Vector3(NUM_COLS, 0, -EXIT) * CELL_POS_OFFSET + CELL_LEFT_UP_POS +
        Vector3.Up * (MAZE_FLOOR_THICKNESS + WALL_HEIGHT) * .5
    entrace:SetActive(true)
    exit:SetActive(true)
end

-- 重置角落
function MazeConrnerReset()
    local calPos = function(r, c)
        cornerFlag.LocalPosition =
            Vector3(c, 0, -r) * CELL_POS_OFFSET + CELL_LEFT_UP_POS +
            Vector3.Up * (MAZE_FLOOR_THICKNESS + WALL_HEIGHT) * .5
        return cornerFlag.Position
    end
    corners[1] = calPos(1, 1)
    corners[2] = calPos(1, NUM_COLS)
    corners[3] = calPos(NUM_ROWS, 1)
    corners[4] = calPos(NUM_ROWS, NUM_COLS)
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
function MazeObjsReset()
    DespawnWalls()
    DespawnPillars()
    DespawnCheckers()
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
    -- M[ENTRANCE][1][LEFT] = 1
    -- M[EXIT][NUM_COLS][RIGHT] = 1
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
                --* 1：路，0：墙
                if
                    cell[dir] == 0 and
                        (dir == LEFT or dir == UP or (dir == RIGHT and col == NUM_COLS) or
                            (dir == DOWN and row == NUM_ROWS))
                 then
                    pos = Vector3(col, 0, -row) * CELL_POS_OFFSET + WALL_DICT[dir].pos + WALL_OFFSET
                    rot = WALL_DICT[dir].rot
                    objWall = SpawnWall(pos, rot)
                end
            end
        end
    end
end

-- 迷宫柱子生成
function PillarsGen()
    if string.isnilorempty(PILLAR_ARCH) then
        return
    end

    -- 柱子位置偏移量
    local cell, pos, rot = nil, nil, EulerDegree(0, 0, 0)
    local rd = false -- 用于判定右下角是否有柱子
    for row = 1, NUM_ROWS do
        for col = 1, NUM_COLS do
            cell = M[row][col]
            --* Vector3(1, 0, 1) = Vector2(右, 上)
            --* 1：路，0：墙

            -- 左上角
            if row == 1 and col == 1 then
                pos = Vector3(col, 0, -row) * CELL_POS_OFFSET + CELL_LEFT_UP_POS + Vector3(-1, 0, 1) * WALL_POS_OFFSET
                objPillar = SpawnPillar(pos, rot)
            end
            -- 右上角
            if (row == 1 and cell[RIGHT] == 0) or (row == NUM_ROWS and col == EXIT) then
                pos = Vector3(col, 0, -row) * CELL_POS_OFFSET + CELL_LEFT_UP_POS + Vector3(1, 0, 1) * WALL_POS_OFFSET
                objPillar = SpawnPillar(pos, rot)
            end
            -- 左下角
            if col == 1 and (cell[DOWN] == 0 or row == ENTRANCE) then
                pos = Vector3(col, 0, -row) * CELL_POS_OFFSET + CELL_LEFT_UP_POS + Vector3(-1, 0, -1) * WALL_POS_OFFSET
                objPillar = SpawnPillar(pos, rot)
            end
            -- 右下角
            rd =
                (row == NUM_ROWS and col == NUM_COLS) or -- 右下边界
                (col == NUM_COLS and cell[DOWN] == 0) or -- 右边界
                (row == NUM_ROWS and cell[RIGHT] == 0) -- 下边界
            if not rd and row < NUM_ROWS and col < NUM_COLS then -- 中心区域：6种情况
                rd =
                    (cell[DOWN] == 0 and cell[RIGHT] == 0) or -- 柱子左上为墙
                    (cell[DOWN] == 0 and M[row + 1][col][RIGHT] == 0) or -- 柱子左下为墙
                    (cell[RIGHT] == 0 and M[row][col + 1][DOWN] == 0) or -- 柱子右上为墙
                    (M[row + 1][col][RIGHT] == 0 and M[row][col + 1][DOWN] == 0) or -- 柱子右下为墙
                    (cell[RIGHT] ~= M[row + 1][col][RIGHT]) or -- 柱子上下有只有一根
                    (cell[DOWN] ~= M[row][col + 1][DOWN]) -- 柱子左右只有一根
            end
            if rd then
                pos = Vector3(col, 0, -row) * CELL_POS_OFFSET + CELL_LEFT_UP_POS + Vector3(1, 0, -1) * WALL_POS_OFFSET
                objPillar = SpawnPillar(pos, rot)
            end
        end
    end
end

-- 迷宫积分点生成
function MazeCheckersGen()
    local objChecker, node, r, c
    local pos, rot = nil, EulerDegree(0, 0, 0)
    local step = math.ceil(#path / TOTAL_CHECKER)
    for i = 1, #path, step do
        node = path[i]
        r, c = node[1], node[2]
        pos = Vector3(c, 0, -r) * CELL_POS_OFFSET + CELL_LEFT_UP_POS + Vector3.Up * WALL_HEIGHT * .5
        objChecker = SpawnChecker(pos, rot)
    end
end

-- 金币随机生成
function CoinGen()
    local cell, pos, row, col
    local serial = {}
    for row = 1, NUM_ROWS do
        for col = 1, NUM_COLS do
            table.insert(serial, {row, col})
        end
    end
    table.shuffle(serial)
    for i = 1, #serial do --#serial
        row = serial[i][1]
        col = serial[i][2]
        cell = M[row][col]
        pos =
            MAZE_CENTER_POS + CELL_LEFT_UP_POS + Vector3(col, 0, -row) * CELL_POS_OFFSET +
            Vector3.Up * WALL_HEIGHT * 1.3
        NetUtil.Fire_S('SpawnCoinEvent', 'N', pos, COIN_VAL, TOTAL_TIME)
        if i % 3 == 0 then
            wait()
        end
    end
end

-- 迷宫显示
function MazeShow()
    print('[Maze] MazeShow')
    WALL_SPACE:SetActive(true)
    PILLAR_SPACE:SetActive(true)
    CHECKER_SPACE:SetActive(true)
    floor:SetActive(true)
end

-- 迷宫隐藏
function MazeHide()
    print('[Maze] MazeHide')
    WALL_SPACE:SetActive(false)
    PILLAR_SPACE:SetActive(false)
    CHECKER_SPACE:SetActive(false)
    floor:SetActive(false)
    if floorDeco then
        floorDeco:SetActive(false)
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

    for i = #path, idx, -1 do
        table.remove(path, i)
    end
end

--! 玩家相关

-- 玩家开始迷宫
function PlayerStartMaze(_player)
    print('[Maze] PlayerStartMaze')
    -- NetUtil.Fire_C('InsertInfoEvent', _player, '在规定时间内找到迷宫的出口', 5, true)
    playerData = {}
    playerData.player = _player
    playerData.checker = 0
    playerData.score = 0
    playerData.time = 0
    -- NetUtil.Fire_C(
    --     'ClientMazeEvent',
    --     playerData.player,
    --     Const.MazeEventEnum.JOIN,
    --     entrace.Position,
    --     floor.Right,
    --     TOTAL_TIME,
    --     PRE_WAIT_TIME
    -- )
    timer = TimeUtil.SetTimeout(PlayerQuitMaze, TOTAL_TIME + PRE_WAIT_TIME + POST_WAIT_TIME)
    startTime = now()
end

-- 玩家抵达终点
function PlayerReachExit(_hitObj)
    if GlobalFunc.CheckHitObjIsPlayer(_hitObj) and CheckPlayerExists() and playerData.player == _hitObj then
        print('[Maze] PlayerReachExit')
        MazeHide()
        playerData.checker = TOTAL_CHECKER
        GetResult()
        NetUtil.Fire_C(
            'ClientMazeEvent',
            playerData.player,
            Const.MazeEventEnum.FINISH,
            playerData.score,
            playerData.time
        )
        ---发奖励的临时代码
        NetUtil.Fire_C('UpdateCoinEvent', playerData.player, 20)
        NetUtil.Fire_C('GetItemEvent', playerData.player, 5017)
        playerData = nil
    end
    TimeUtil.ClearTimeout(timer)
end

-- 玩家中途离开或者时间用完
function PlayerQuitMaze()
    print('[Maze] PlayerQuitMaze')
    MazeHide()
    GetResult()
    if CheckPlayerExists() then
        -- NetUtil.Fire_C(
        --     'ClientMazeEvent',
        --     playerData.player,
        --     Const.MazeEventEnum.QUIT,
        --     playerData.score,
        --     playerData.time
        -- )
        playerData = nil
    end
    TimeUtil.ClearTimeout(timer)
end

-- 检查玩家是否在线，防止玩家在迷宫的时候中途退出游戏
function CheckPlayerExists()
    if playerData and playerData.player then
        return true
    else
        PlayerDisconnected()
        return false
    end
end

-- 玩家离线
function PlayerDisconnected()
    playerData = nil
    MazeHide()
    TimeUtil.ClearTimeout(timer)
end

-- 玩家触碰积分点
function PlayerHitChecker(_hitObj, _checkObj)
    if GlobalFunc.CheckHitObjIsPlayer(_hitObj) and CheckPlayerExists() and playerData.player == _hitObj then
        playerData.checker = playerData.checker + 1
        print('[Maze] PlayerHitChecker()', playerData.checker)
        DespawnChecker(_checkObj)
    end
end

-- 得到玩家结果
function GetResult()
    if playerData and playerData.player then
        -- TODO: 最终得分计算，以下为临时
        playerData.time = math.min(TOTAL_TIME, now() - startTime)
        playerData.score = playerData.checker
    end
end

--! Event handlers 事件处理

-- 进入小游戏事件
-- @param _player 玩家
-- @param _gameId 游戏ID
function Maze:EnterMiniGameEventHandler(_player, _gameId)
    if _player and _gameId == Const.GameEnum.MAZE and not playerData then
        print('[Maze] EnterMiniGameEventHandler', _player, _gameId)
        if not wallPoolDone or not pillarPoolDone or not checkerPoolDone then
            -- TODO: 反馈给NPC对话，说明此原因
            print('[Maze] EnterMiniGameEventHandler 迷宫初始化未完成，请等待')
        elseif playerData then
            -- TODO: 反馈给NPC对话，说明此原因
            print('[Maze] EnterMiniGameEventHandler 有玩家正在进行游戏，请等待')
        else
            PlayerStartMaze(_player)
            MazeReset()
            MazeShow()
            for _, player in pairs(world:FindPlayers()) do
                table.shuffle(corners)
                NetUtil.Fire_C(
                    'ShowNoticeInfoEvent',
                    player,
                    LanguageUtil.GetText(Config.GuiText.InfoGui_5.Txt),
                    10,
                    corners[1]
                )
            end
        end
    end
end

-- 离开小游戏事件
-- @param _player 玩家
-- @param _gameId 游戏ID
function Maze:ExitMiniGameEventHandler(_player, _gameId)
    if _player and _gameId == Const.GameEnum.MAZE then
        print('[Maze] ExitMiniGameEventHandler', _player, _gameId)
        PlayerQuitMaze()
    end
end

--! Aux 辅助功能

-- 打印迷宫数据
PrintMazeData = debug and function()
        for row = 1, NUM_ROWS do
            for col = 1, NUM_COLS do
                print(table.dump(M[row][col]))
            end
            print('============================')
        end
    end or function()
    end

-- 打印寻路结果
PrintNodePath = debug and function()
        print('打印寻路结果')
        for k, n in pairs(path) do
            print(string.format('[%02d] %s (%s, %s) %s', k, WALL_DICT[n[3]].symbol, n[1], n[2], WALL_DICT[n[4]].symbol))
        end
    end or function()
    end

-- 在迷宫上生成路径
GenNodePath =
    debug and
    function()
        -- 删除路径点
        local point
        for i = #pathNodes, 1, -1 do
            point = pathNodes[i]
            if point and not point:IsNull() then
                point:Destroy()
                table.remove(pathNodes, i)
            end
            if i % 5 == 0 then
                wait()
            end
        end
        -- 生成路径点
        local r, c, name
        for k, n in pairs(path) do
            r, c = n[1], n[2]
            name = string.format('Path_Node_%04d', k)
            point = world:CreateObject('Sphere', name, floor)
            point.Size = Vector3.One * 0.1
            point.Block = false
            point.Color = Color(0x00, 0xFF, 0xFF, 0xFF)
            point.LocalPosition =
                Vector3(c, 0, -r) * CELL_POS_OFFSET + CELL_LEFT_UP_POS +
                Vector3.Up * (MAZE_FLOOR_THICKNESS + WALL_HEIGHT) * .5
            table.insert(pathNodes, point)
            point.Block = false
            wait()
        end
    end or
    function()
    end

return Maze

--! TEST ONLY below
--* 测试迷宫生成
--[[
    -- 进入迷宫
    NetUtil.Fire_S('EnterMiniGameEvent', localPlayer, Const.GameEnum.MAZE)
    -- 金币生成3秒
    NetUtil.Fire_S('SpawnCoinEvent','N', Vector3(-61.4809, -7, -44.5831), 100, 3)
]]
