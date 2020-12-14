--- 玩家与NPC交互的UI
--- @module Player Default GUI
--- @copyright Lilith Games, Avatar Team
local GuiNpc, this = ModuleUtil.New('GuiNpc', ClientBase)

-- GUI
local controlGui, npcBtn

-- Resource Const
local RES_NPC_IMG = 'UI/Icon_Do'
local RES_NPC_PRESS_IMG = 'UI/Icon_Do_A'

-- Resourc
local resNpcBtn, resNpcBtnPressed

-- cache
local Config = Config
local NpcInfo = Config.NpcInfo

function GuiNpc:Init()
    self:InitGui()
    self:InitResource()
end

function GuiNpc:InitGui()
    controlGui = localPlayer.Local.ControlGui
    npcBtn = controlGui.NpcBtn
end

function GuiNpc:InitResource()
    resNpcBtn = ResourceManager.GetTexture(RES_NPC_IMG)
    resNpcBtnPressed = ResourceManager.GetTexture(RES_NPC_PRESS_IMG)
end

function GuiNpc:TouchNpcEventHandler(_npcId)
    -- print(table.dump(NpcInfo[_npcId]))
    if _npcId ~= nil then
        npcBtn.Image = resNpcBtn
        npcBtn.PressedImage = resNpcBtnPressed
    end
    npcBtn.Visible = _npcId ~= nil
end

return GuiNpc
