--- 玩家默认UI
--- @module Player Default GUI
--- @copyright Lilith Games, Avatar Team
local GuiMaze, this = ModuleUtil.New('GuiMaze', ClientBase)

-- 获取本地玩家
local player
-- 迷宫中的相机
local camMaze

-- Const
local MAZE_CHARACTER_WIDTH = 0.1
local AVATAR_HEIGHT = 0.1
local AVATAR_HEAD_SIZE = 0.1
local WALK_SPEED = .7
local JUMP_UP_VELOCITY = 0

-- 缓存玩家进入迷宫前的参数
local origin = {}

-- Update
local inMaze = false

-- Time
local startTime, totalTime, now = 0, 0, Timer.GetTime
local hour, minute, second, milliseconds = 0, 0, 0, 0

function GuiMaze:Init()
    print('[GuiMaze] Init()')
    -- 获取本地玩家
    player = localPlayer
    camMaze = localPlayer.Local.Independent.MazeCam
    self:InitGui()
end

function GuiMaze:InitGui()
    -- GUI root
    guiRoot = localPlayer.Local
    -- GUI info
    infoGui = guiRoot.MazeGui
    timerTxt = infoGui.TimerTxt
end

-- 进入迷宫
function EnterMaze(_enterPos, _playerDir, _totalTime, _waitTime)
    print('[GuiMaze] EnterMaze')
    -- cache player info
    origin.pos = player.Position
    NetUtil.Fire_C('GetBuffEvent', localPlayer, 24, -1)
    player.Position = _enterPos
    player.Forward = _playerDir
    NetUtil.Fire_C('SetCurCamEvent', localPlayer, camMaze)

    invoke(
        function()
            -- GUI
            EnableMazeGui()
            -- time
            totalTime = _totalTime
            startTime = now()

            -- start updating
            inMaze = true
        end,
        _waitTime
    )
end

-- 完成迷宫
function FinishMaze(_score, _time)
    print('[GuiMaze] FinishMaze')
    QuitMaze(_score, _time)
end

-- 中途退出迷宫
function QuitMaze(_score, _time)
    print('[GuiMaze] QuitMaze')
    -- stop updating
    inMaze = false
    -- resume player info
    player.Position = origin.pos
    NetUtil.Fire_C('RemoveBuffEvent', localPlayer, 24)

    NetUtil.Fire_C('SetCurCamEvent', localPlayer, origin.camera)

    -- GUI
    DisableMazeGui()
    print(string.format('[GuiMaze] 迷宫结束, 用时: %s, 分数: %s', _time, _score))
end

--! GUI

-- 开启迷宫GUI模式
function EnableMazeGui()
    -- GUI info
    infoGui:SetActive(true)
    timerTxt:SetActive(true)
    timerTxt.Text = FormatTimeBySec(totalTime)
end

-- 关闭迷宫GUI模式
function DisableMazeGui()
    -- GUI info
    infoGui:SetActive(false)
    timerTxt:SetActive(false)
    timerTxt.Text = FormatTimeBySec(totalTime)
end

-- 时间格式工具:秒
function FormatTimeBySec(_seconds)
    hour, minute, second, millisecond = 0, 0, 0, 0
    hour = math.floor(_seconds / 3600)
    minute = math.floor((_seconds - hour * 3600) / 60)
    secound = math.floor(_seconds - hour * 3600 - minute * 60)
    millisecond = math.floor((_seconds - math.floor(_seconds)) * 100) -- 显示两位
    return string.format('%02d:%02d:%02d:%02d', hour, minute, secound, millisecond)
end

--! 更新
function GuiMaze:Update(_dt)
    if not inMaze then
        return
    end
    timerTxt.Text = FormatTimeBySec(math.max(totalTime - (now() - startTime), 0))
end

--! Event handlers 事件处理

function GuiMaze:ClientMazeEventHandler(_eventEnum, ...)
    local args = {...}
    if _eventEnum == Const.MazeEventEnum.JOIN and #args > 0 then
        print(table.dump(args))
        local enterPos = args[1]
        local playerDir = args[2]
        local totalTime = args[3]
        local waitTime = args[4]
        EnterMaze(enterPos, playerDir, totalTime, waitTime)
    elseif _eventEnum == Const.MazeEventEnum.FINISH and #args > 1 then
        print(table.dump(args))
        local score = args[1]
        local usedTime = args[2]
        FinishMaze(score, usedTime)
    elseif _eventEnum == Const.MazeEventEnum.QUIT and #args > 1 then
        local score = args[1]
        local usedTime = args[2]
        QuitMaze(score, usedTime)
    end
end

return GuiMaze
