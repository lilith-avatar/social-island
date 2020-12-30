--- 玩家默认UI
--- @module Player Default GUI
--- @copyright Lilith Games, Avatar Team
local GuiMaze, this = ModuleUtil.New('GuiMaze', ClientBase)

-- 获取本地玩家
local player

-- Const
local MAZE_CHARACTER_WIDTH = 0.5

-- 缓存玩家进入迷宫前的参数
local origin = {}

function GuiMaze:Init()
    print('[GuiMaze] Init()')
    -- 获取本地玩家
    player = localPlayer
end

-- 进入迷宫
function EnterMaze(_enterPos)
    print('[GuiMaze] EnterMaze')
    origin.pos = player.Position
    origin.charWidth = player.CharacterWidth
    player.Position = _enterPos
    player.CharacterWidth = MAZE_CHARACTER_WIDTH
end

-- 完成迷宫
function FinishMaze(_score, _time)
    print('[GuiMaze] FinishMaze')
    player.Position = origin.pos
    player.CharacterWidth = origin.charWidth
end

-- 中途退出迷宫
function QuitMaze()
    print('[GuiMaze] QuitMaze')
end

--! Event handlers 事件处理

function GuiMaze:ClientMazeEventHandler(_eventEnum, ...)
    local args = {...}
    if _eventEnum == Const.MazeEventEnum.JOIN and #args > 0 then
        print(table.dump(args))
        local enterPos = args[1]
        EnterMaze(enterPos)
    elseif _eventEnum == Const.MazeEventEnum.FINISH and #args > 1 then
        print(table.dump(args))
        local score = args[1]
        local time = args[2]
        FinishMaze(score, time)
    elseif _eventEnum == Const.MazeEventEnum.QUIT then
        QuitMaze()
    end
end

return GuiMaze
