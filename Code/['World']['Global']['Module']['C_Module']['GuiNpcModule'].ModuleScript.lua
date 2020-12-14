--- 玩家与NPC交互的UI
--- @module Player Default GUI
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local GuiNpc, this = ModuleUtil.New('GuiNpc', ClientBase)

-- GUI
local controlGui, npcBtn
local npcGui, gameBtn, dialogBtn, shopBtn, leaveBtn

-- Cache
local Config = Config
local NpcInfo

-- Data
local currNpcId

function GuiNpc:Init()
    self:InitGui()
    self:InitData()
    self:InitResource()
    self:InitListener()
end

function GuiNpc:InitGui()
    -- Control GUI
    controlGui = localPlayer.Local.ControlGui
    npcBtn = controlGui.NpcBtn
    -- NPC GUI
    npcGui = localPlayer.Local.NpcGui
    portraitImg = npcGui.PortraitImg
    gameBtn = npcGui.GameBtn
    dialogBtn = npcGui.DialogBtn
    shopBtn = npcGui.ShopBtn
    leaveBtn = npcGui.LeaveBtn
end

function GuiNpc:InitData()
    NpcInfo = table.deepcopy(Config.NpcInfo)
end

function GuiNpc:InitResource()
    for _, npc in pairs(NpcInfo) do
        if npc.PortraitRes then
            npc.Portrait = ResourceManager.GetTexture('TestPortrait/' .. npc.PortraitRes)
            print(npc.PortraitRes)
        end
    end
end

function GuiNpc:InitListener()
    npcBtn.OnClick:Connect(OpenNpcGui)
    gameBtn.OnClick:Connect(EnterMiniGame)
    dialogBtn.OnClick:Connect(StartDialog)
    shopBtn.OnClick:Connect(EnterShop)
    leaveBtn.OnClick:Connect(LeaveNpc)
end

--- 接触NPC
function TouchNpc(_npcId)
    if _npcId == nil then
        return
    end
    print('[GuiNpc] TouchNpc()', _npcId)
    controlGui.Visible = true
    npcBtn.Visible = true
    npcGui.Visible = false
    currNpcId = _npcId
end

--- 打开NPC界面
function OpenNpcGui()
    if currNpcId == nil or NpcInfo[currNpcId] == nil then
        return
    end
    print('[GuiNpc] OpenNpcGui()')
    controlGui.Visible = false
    npcGui.Visible = true
    local portrait = NpcInfo[currNpcId].Portrait
    portraitImg.Texture = portrait
    portraitImg.Visible = portrait ~= nil
end

--- 离开NPC
function LeaveNpc()
    print('[GuiNpc] LeaveNpc()', currNpcId)
    controlGui.Visible = true
    npcBtn.Visible = false
    npcGui.Visible = false
    currNpcId = nil
end

--- 开始小游戏
function EnterMiniGame()
    if currNpcId == nil or NpcInfo[currNpcId] == nil or NpcInfo[currNpcId].GameId == nil then
        return
    end

    local gameId = NpcInfo[currNpcId].GameId
    NetUtil.Fire_S('EnterMiniGame', localPlayer, gameId)
    --! Test only
    print('[GuiNpc] EnterMiniGame', localPlayer, gameId)
end

--- 打开商城
function EnterShop()
    print('[GuiNpc] EnterShop()')
end

--- 开始对话
function StartDialog()
    print('[GuiNpc] StartDialog()')
end

function GuiNpc:TouchNpcEventHandler(_npcId)
    -- print(table.dump(NpcInfo[_npcId]))
    if _npcId ~= nil then
        TouchNpc(_npcId)
    else
        LeaveNpc()
    end
end

return GuiNpc
