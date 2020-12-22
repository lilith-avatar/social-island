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

return GuiMaze
