--- 玩家与NPC交互的UI
--- @module Player Default GUI
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang, Lin
local GuiNpc, this = ModuleUtil.New('GuiNpc', ClientBase)

-- GUI
local controlGui, monsterGui, npcBtn
local npcGui, gameBtn, battleBtn, shopBtn, leaveBtn, dialogTxt

-- Cache
local Config = Config
local NpcInfo

-- Data
local currNpcId
local currNpcObj

--! 初始化

--- 初始化
function GuiNpc:Init()
    self:InitGui()
    self:InitData()
    self:InitResource()
    self:InitListener()
end

--- 初始化GUI结点
function GuiNpc:InitGui()
    -- Control GUI
    controlGui = localPlayer.Local.ControlGui
    -- Monster GUI
    monsterGui = localPlayer.Local.MonsterGUI
    -- NPC btn
    npcBtn = controlGui.NpcBtn
    -- NPC GUI
    npcGui = localPlayer.Local.NpcGui
    portraitImg = npcGui.PortraitImg
    gameBtn = npcGui.GameBtn
    battleBtn = npcGui.BattleBtn
    shopBtn = npcGui.ShopBtn
    leaveBtn = npcGui.LeaveBtn
    dialogTxt = npcGui.DialogTxt
end

--- 初始化表格
function GuiNpc:InitData()
    NpcInfo = table.deepcopy(Config.NpcInfo)
end

--- 预加载资源
function GuiNpc:InitResource()
    for _, npc in pairs(NpcInfo) do
        if npc.PortraitRes then
            npc.Portrait = ResourceManager.GetTexture('TestPortrait/' .. npc.PortraitRes)
            print(npc.PortraitRes)
        end
    end
end

--- 绑定事件
function GuiNpc:InitListener()
    npcBtn.OnClick:Connect(OpenNpcGui)
    npcBtn.OnClick:Connect(NpcFaceToPlayer)
    gameBtn.OnClick:Connect(EnterMiniGame)
    battleBtn.OnClick:Connect(StartMonsterBattle)
    shopBtn.OnClick:Connect(EnterShop)
    leaveBtn.OnClick:Connect(LeaveNpc)
end

--! GUI 功能

--- 接触NPC
function TouchNpc(_npcId, _npcObj)
    if _npcId == nil then
        return
    end
    print('[GuiNpc] TouchNpc()', _npcId)
    controlGui.Visible = true
    npcBtn.Visible = true
    npcGui.Visible = false
    currNpcId = _npcId
    currNpcObj = _npcObj
end

--- 离开NPC
function LeaveNpc()
    print('[GuiNpc] LeaveNpc()', currNpcId)
    controlGui.Visible = true
    monsterGui.Visible = true
    npcBtn.Visible = false
    npcGui.Visible = false
    currNpcId = nil
    currNpcObj = nil
end

--- 打开NPC界面
function OpenNpcGui()
    if currNpcId == nil or NpcInfo[currNpcId] == nil then
        return
    end
    print('[GuiNpc] OpenNpcGui()')
    controlGui.Visible = false
    monsterGui.Visible = false
    npcGui.Visible = true
    local portrait = NpcInfo[currNpcId].Portrait
    portraitImg.Texture = portrait
    portraitImg.Visible = portrait ~= nil
    dialogTxt.Text = PickARandomDialog()
end

-- 使NPC面向玩家
function NpcFaceToPlayer()
    local ry = Vector3.Angle(Vector3.Forward, localPlayer.Position - currNpcObj.Position)
    if localPlayer.Position.x - currNpcObj.Position.x >= 0 then
        currNpcObj.Rotation = EulerDegree(0, ry, 0)
    else
        currNpcObj.Rotation = EulerDegree(0, 360 - ry, 0)
    end
end

--- 开始小游戏
function EnterMiniGame()
    if currNpcId == nil or NpcInfo[currNpcId] == nil or NpcInfo[currNpcId].GameId == nil then
        return
    end

    local gameId = NpcInfo[currNpcId].GameId
    NetUtil.Fire_S('EnterMiniGameEvent', localPlayer, gameId)
    --! Test only
    print('[GuiNpc] EnterMiniGameEvent', localPlayer, gameId)
end

--- 打开商城
function EnterShop()
    print('[GuiNpc] EnterShop()')
end

--- 开始宠物战斗
function StartMonsterBattle()
    print('[GuiNpc] StartMonsterBattle()')
    NetUtil.Fire_S('StartBattleEvent', true, currNpcObj, localPlayer)
end

--- 随机选取一段对话
function PickARandomDialog()
    if not currNpcId or not currNpcObj then
        return
    end
    return table.shuffle(NpcInfo[currNpcId].DialogText)[1]
end

--! Event handlers 事件处理

function GuiNpc:TouchNpcEventHandler(_npcId, _npcObj)
    print('[GuiNpc] TouchNpcEventHandler', _npcId)
    if _npcId ~= nil then
        TouchNpc(_npcId, _npcObj)
    else
        LeaveNpc()
    end
end

return GuiNpc
