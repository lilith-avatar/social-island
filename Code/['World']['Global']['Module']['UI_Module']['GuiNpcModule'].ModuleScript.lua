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
local NpcText = Config.NpcText
local NpcInfo

-- Data
local currNpcId
local currNpcObj
local taskItemID = 0

--! 初始化

--- 初始化
function GuiNpc:Init()
    print('[GuiNpc] Init()')
    self:InitGui()
    self:InitData()
    self:InitResource()
    self:InitListener()
end

--- 初始化GUI结点
function GuiNpc:InitGui()
    -- Monster GUI
    monsterGui = localPlayer.Local.MonsterGUI
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
        -- print('[GuiNpc] InitResource()', npc.PortraitRes)
        end
    end
end

--- 绑定事件
function GuiNpc:InitListener()
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
    NetUtil.Fire_C('OpenDynamicEvent', localPlayer, 'Interact', Config.Interact.NPC.ID)
    NetUtil.Fire_S('TouchNpcEvent', localPlayer, _npcId)
    currNpcId = _npcId
    currNpcObj = _npcObj
end

--- 离开NPC
function LeaveNpc()
    print("[GuiNpc] LeaveNpc()", currNpcId)
    NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
    monsterGui.Visible = true
    npcGui.Visible = false
    if currNpcId then
        NetUtil.Fire_S('LeaveNpcEvent', localPlayer, currNpcId)
    end
    currNpcId = nil
    currNpcObj = nil
end

--- 打开NPC界面
function OpenNpcGui()
    if currNpcId == nil or NpcInfo[currNpcId] == nil then
        return
    end
    print("[GuiNpc] OpenNpcGui()")
    NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer, 12)
    NetUtil.Fire_S('StartTalkNpcEvent', localPlayer, currNpcId)
    --monsterGui.Visible = false
    npcGui.Visible = true

    local portrait = NpcInfo[currNpcId].Portrait
    portraitImg.Texture = portrait
    portraitImg.Visible = portrait ~= nil

    taskItemID = ItemMgr:GetTaskItem(currNpcId)
    if taskItemID == 0 then
        dialogTxt.Text = PickARandomDialog()
    else
        dialogTxt.Text = LanguageUtil.GetText(ItemMgr.itemInstance[taskItemID].config.NpcText)
        ItemMgr.itemInstance[taskItemID]:GetTaskReward()
        taskItemID = 0
    end

    --如果玩家没有携带宠物，则隐藏对战按钮
    battleBtn.Visible = localPlayer.MonsterVal.Value ~= nil
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
    -- TODO: 商店相关逻辑
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
    local dialogId = table.shuffle(NpcInfo[currNpcId].DialogId)[1]
    local dialog = NpcText[dialogId].Text
    assert(dialogId and dialog, string.format('[GuiNpc] NPC: %s, 不存在DialogId: %s', currNpcId, dialogId))
    return LanguageUtil.GetText(dialog)
end

--! Event handlers 事件处理

-- 进入或离开NPC碰撞区域
function GuiNpc:TouchNpcEventHandler(_npcId, _npcObj)
    if _npcId and _npcObj then
        TouchNpc(_npcId, _npcObj)
    else
        LeaveNpc()
    end
end

function GuiNpc:InteractCEventHandler(_id)
    if _id == 12 then
        OpenNpcGui()
    end
end

return GuiNpc
