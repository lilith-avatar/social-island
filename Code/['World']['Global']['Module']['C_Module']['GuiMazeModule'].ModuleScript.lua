--- 玩家默认UI
--- @module Player Default GUI
--- @copyright Lilith Games, Avatar Team
local GuiMaze, this = ModuleUtil.New('GuiMaze', ClientBase)

-- 获取本地玩家
local player

function GuiMaze:Init()
    print('[GuiMaze] Init()')
    -- 获取本地玩家
    player = localPlayer
end

function GuiMaze:ClientMazeEventHandler(_eventEnum, ...)
    local args = {...}
    if _eventEnum == Const.MazeEventEnum.JOIN and #args > 0 then
        print(table.dump(args))
        player.Position = args[1]
    end
end

return GuiMaze
