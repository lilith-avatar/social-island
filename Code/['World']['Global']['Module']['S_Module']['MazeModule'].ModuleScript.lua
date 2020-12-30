--- 迷宫游戏
--- @module Maze Module
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local Maze, this = ModuleUtil.New('Maze', ServerBase)

--! 打印事件日志, true:开启打印
local showLog, PrintMazeData, PrintNodePath, GenNodePath = true

--! 常量配置: 玩家相关

-- 游戏时长(秒)
local TOTAL_TIME = 30

--! 常量配置: Maze 迷宫相关

-- 迷宫尺寸
local NUM_ROWS, NUM_COLS = 15, 15

-- 迷宫Hierachy根节点
local MAZE_ROOT = world.MiniGames.Game_03_Maze

-- 迷宫中心位置
local MAZE_CENTER_POS = Vector3(103, -13.25, 14)
local MAZE_CENTER_ROT = EulerDegree(0, 0, 0)

-- 迷宫Cell里面的常量，包括方向和访问，用于M
local LEFT, UP, RIGHT, DOWN, VISITED = 1, 2, 3, 4, 5

-- 入口、出口位置，只能在左右两侧
local ENTRANCE = 1
local EXIT = NUM_ROWS

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
local CELL_SIDE = 1

-- 迷宫Cell位置偏移量
local CELL_POS_OFFSET = CELL_SIDE

-- 迷宫左上角的Cell中心位置
local CELL_LEFT_UP_POS = Vector3(-NUM_COLS - 1, 0, NUM_ROWS + 1) * CELL_SIDE * .5

--! 常量配置: Wall 墙体相关

-- 墙体的Archetype
local WALL_ARCH = 'Maze_Wall_Test'
local WALL_HEIGHT = 1 -- 对应Size.Y
local WALL_LENGTH = 2 -- 对应Size.X
local WALL_THICKNESS = 0.1 -- 对应Size.Z

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

--! 常量配置: Check Point 积分点相关

-- 积分点总数
local TOTAL_CHECKER = 20

-- 墙壁对象池Hierachy根节点
local CHECKER_SPACE
-- 墙壁对象池隐藏默认位置
local CHECKER_POOL_POS = Vector3.Down * 100

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
-- 积分点对象池，积分点对象池生成完毕
local checkerPool, checkerPoolDone = {}, false

--! 其他数据

-- 玩家数据
local playerData

-- 寻路节点
local path = {}
local pathNodes = {}

-- 计数器id
local timer

--! 初始化

-- 初始化
function Maze:Init()
    print('[Maze] Init()')
    InitMazeWallSpace()
    InitMazeCheckerSpace()
    InitMazeFloor()
    InitMazeEntranceAndExit()
    invoke(InitWallPool)
    invoke(InitCheckerPool)

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
end

-- 初始化迷宫入口出口
function InitMazeEntranceAndExit()
    entrace = world:CreateObject('Sphere', 'Entrance', floor)
    exit = world:CreateObject('Sphere', 'Exit', floor)
    entrace.Size = Vector3.One * 0.5
    exit.Size = Vector3.One * 0.5
    entrace.Block = false
    exit.Block = false
    entrace.Color = Color(0x00, 0xFF, 0x00, 0xFF)
    exit.Color = Color(0xFF, 0x00, 0x00, 0xFF)
    entrace:SetActive(false)
    exit:SetActive(false)
    exit.OnCollisionBegin:Connect(PlayerReachExit)
end

-- 初始化对象池 - 墙壁
function InitWallPool()
    if wallPoolDone then
        return
    end
    assert(WALL_SPACE and not WALL_SPACE:IsNull(), '[Maze] WALL_SPACE 为空')
    -- 总共需要多少面墙
    -- 外墙数 = NUM_ROWS * 2 + NUM_COLS * 2
    -- 内墙数 = (NUM_ROWS - 1) * (NUM_COLS - 1) * 2
    -- 出入口 = -2
    local wallNeeded = NUM_ROWS * 2 + NUM_COLS * 2 + (NUM_ROWS - 1) * (NUM_COLS - 1) * 2 - 2
    print('[Maze] InitWallPool() 需要墙数', wallNeeded)
    local rot = EulerDegree(0, 0, 0)
    local name
    for i = 1, wallNeeded do
        name = string.format('%s_%04d', WALL_ARCH, i)
        objWall = world:CreateInstance(WALL_ARCH, name, WALL_SPACE, WALL_POOL_POS, rot)
        wallPool[objWall] = true
        if i % 5 == 0 then
            wait()
        end
    end
    wallPoolDone = true
    print('[Maze] InitWallPool() done')
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
        objChecker.Size = Vector3.One * 0.3
        objChecker.Block = false
        objChecker.Color = Color(0x00, 0x00, 0xFF, 0x2F)
        objChecker.OnCollisionBegin:Connect(
            function(_hitObj)
                PlayerHitChecker(_hitObj, objChecker)
            end
        )
        checkerPool[objChecker] = true
        if i % 5 == 0 then
            wait()
        end
    end
    checkerPoolDone = true
    print('[Maze] InitWallPool() done')
end

--! 对象池生成和回收

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
    if not wallPoolDone or not checkerPoolDone then
        error('[Maze] 对象池初始化未完成，MazeReset() 不能执行')
        return
    end
    print('[Maze] MazeReset() 迷宫重置')
    -- reset
    MazeFloorReset()
    MazeEntraceAndExitReset()
    MazeDataReset()
    MazeObjsReset()
    -- data
    MazeDataGen()
    FindNodePath()
    -- print log
    PrintMazeData()
    PrintNodePath()
    -- gen objs
    MazeWallsGen()
    MazeCheckersGen()
    invoke(GenNodePath)
    -- show maze
    MazeShow()
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
        Vector3(1, 0, -ENTRANCE) * CELL_POS_OFFSET + CELL_LEFT_UP_POS +
        Vector3.Up * (MAZE_FLOOR_THICKNESS + WALL_HEIGHT) * .5
    exit.LocalPosition =
        Vector3(NUM_COLS, 0, -EXIT) * CELL_POS_OFFSET + CELL_LEFT_UP_POS +
        Vector3.Up * (MAZE_FLOOR_THICKNESS + WALL_HEIGHT) * .5
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
function MazeObjsReset()
    DespawnWalls()
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

-- 迷宫显示
function MazeShow()
    print('[Maze] MazeShow')
    WALL_SPACE:SetActive(true)
    floor:SetActive(true)
end

-- 迷宫隐藏
function MazeHide()
    print('[Maze] MazeHide')
    WALL_SPACE:SetActive(false)
    floor:SetActive(false)
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
    playerData = {}
    playerData.player = _player
    playerData.checker = 0
    playerData.score = 0
    playerData.time = 0
    NetUtil.Fire_C('ClientMazeEvent', playerData.player, Const.MazeEventEnum.JOIN, entrace.Position, TOTAL_TIME)
    timer = TimeUtil.SetTimeout(PlayerQuitMaze, TOTAL_TIME)
end

-- 玩家抵达终点
function PlayerReachExit(_hitObj)
    if ServerUtil.CheckHitObjIsPlayer(_hitObj) and CheckPlayerExists() and playerData.player == _hitObj then
        print('[Maze] PlayerReachExit')
        MazeHide()
        NetUtil.Fire_C(
            'ClientMazeEvent',
            playerData.player,
            Const.MazeEventEnum.FINISH,
            playerData.score,
            playerData.time
        )
        playerData = nil
    end
    TimeUtil.ClearTimeout(timer)
end

-- 玩家触碰积分点
function PlayerHitChecker(_hitObj, _checkObj)
    if ServerUtil.CheckHitObjIsPlayer(_hitObj) and CheckPlayerExists() and playerData.player == _hitObj then
        playerData.checker = playerData.checker + 1
        print('[Maze] PlayerHitChecker()', playerData.checker)
        DespawnChecker(_checkObj)
    end
end

-- 玩家中途离开或者时间用完
function PlayerQuitMaze()
    print('[Maze] PlayerQuitMaze')
    MazeHide()
    if CheckPlayerExists() then
        NetUtil.Fire_C(
            'ClientMazeEvent',
            playerData.player,
            Const.MazeEventEnum.QUIT,
            playerData.score,
            playerData.time
        )
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

-- 得到玩家结果
function GetResult()
    if playerData and playerData.player then
        -- TODO: 最终得分计算，以下为临时
        playerData.score = player.checker
    end
end

--! Event handlers 事件处理

-- 进入小游戏事件
-- @param _player 玩家
-- @param _gameId 游戏ID
function Maze:EnterMiniGameEventHandler(_player, _gameId)
    if _player and _gameId == Const.GameEnum.MAZE and not playerData then
        print('[Maze] EnterMiniGameEventHandler', _player, _gameId)
        if not wallPoolDone or not checkerPoolDone then
            -- TODO: 反馈给NPC对话，说明此原因
            print('[Maze] EnterMiniGameEventHandler 迷宫初始化未完成，请等待')
        elseif playerData then
            -- TODO: 反馈给NPC对话，说明此原因
            print('[Maze] EnterMiniGameEventHandler 有玩家正在进行游戏，请等待')
        else
            MazeReset()
            MazeShow()
            PlayerStartMaze(_player)
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

-- 在迷宫上生成路径
GenNodePath =
    showLog and
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
