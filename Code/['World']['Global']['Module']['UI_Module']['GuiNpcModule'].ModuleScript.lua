--- 玩家与NPC交互的UI
--- @module Player Default GUI
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang, Lin
local GuiNpc, this = ModuleUtil.New('GuiNpc', ClientBase)

-- GUI
local controlGui, npcBtn
local npcGui, gameBtn, battleBtn, shopBtn, leaveBtn, dialogTxt

-- Cache
local Config = Config
local NpcText = Config.NpcText
local NpcInfo = Config.NpcInfo

-- Data
local currNpcId
local currNpcObj
local taskItemID = 0

--! 初始化

--- 初始化
function GuiNpc:Init()
    ----print('[GuiNpc] Init()')
    -- Cache
    ItemMgr = ItemMgr

    self:InitGui()
    self:InitData()
    self:InitResource()
    self:InitListener()
end

--- 初始化GUI结点
function GuiNpc:InitGui()
    -- NPC GUI
    npcGui = localPlayer.Local.NpcGui
    portraitImg = npcGui.PortraitImg
    gameBtn = npcGui.GameBtn
    gameBtn.GameTxt.Text = LanguageUtil.GetText(Config.GuiText.NpcGui_1.Txt)
    shopBtn = npcGui.ShopBtn
    shopBtn.ShopTxt.Text = LanguageUtil.GetText(Config.GuiText.NpcGui_3.Txt)
    leaveBtn = npcGui.LeaveBtn
    leaveBtn.LeaveTxt.Text = LanguageUtil.GetText(Config.GuiText.NpcGui_2.Txt)
    dialogTxt = npcGui.DialogBG.DialogTxt
    NameTxt = npcGui.DialogBG.NameTxt
end

--- 初始化表格
function GuiNpc:InitData()
    NpcInfo = table.deepcopy(Config.NpcInfo)
end

--- 预加载资源
function GuiNpc:InitResource()
    for _, npc in pairs(NpcInfo) do
        if npc.PortraitRes then
            npc.Portrait = ResourceManager.GetTexture('UI/NPCTalk/' .. npc.PortraitRes)
        -- ----print('[GuiNpc] InitResource()', npc.PortraitRes)
        end
    end
end

--- 绑定事件
function GuiNpc:InitListener()
    gameBtn.OnClick:Connect(EnterMiniGame)
    shopBtn.OnClick:Connect(EnterShop)
    leaveBtn.OnClick:Connect(BeyondNpc)
end

--! GUI 功能

--- 接触NPC
function FoundNpc(_npcId, _npcObj)
    if _npcId == nil then
        return
    end
    ----print('[GuiNpc] FoundNpc()', _npcId)
    NetUtil.Fire_C('OpenDynamicEvent', localPlayer, 'Interact', 12)
    currNpcId = _npcId
    currNpcObj = _npcObj
end

--- 离开NPC
function BeyondNpc()
    ----print('[GuiNpc] BeyondNpc()')
    NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
    if currNpcId then
        NetUtil.Fire_C('LeaveNpcEvent', localPlayer, currNpcId)
    end

    npcGui.Visible = false
    currNpcId = nil
    currNpcObj = nil
end

--- 打开NPC界面
function OpenNpcGui()
    if currNpcId == nil or NpcInfo[currNpcId] == nil then
        return
    end
	CloudLogUtil.UploadLog('pannel_actions', 'dialog_icon_' .. '12' .. '_click', {subinter_id = currNpcId})
    ----print('[GuiNpc] OpenNpcGui()')
    NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer, 12)
    NetUtil.Fire_C('TalkToNpcEvent', localPlayer, currNpcId)
    -- 音效
    SoundUtil.Play2DSE(localPlayer.UserId, 3)
    npcGui.Visible = true
    gameBtn.Visible = NpcInfo[currNpcId].GameId ~= nil
    shopBtn.Visible = NpcInfo[currNpcId].ShopId ~= nil

    local portrait = NpcInfo[currNpcId].Portrait
    portraitImg.Texture = portrait
    portraitImg.Visible = portrait ~= nil

    taskItemID = ItemMgr:GetTaskItem(currNpcId)
    NameTxt.Text = LanguageUtil.GetText(NpcInfo[currNpcId].Name)
    if taskItemID == 0 then
        dialogTxt.Text = PickARandomDialog()
    else
        CloudLogUtil.UploadLog('game_fte', 'talk_to_npc_' .. currNpcId)
        dialogTxt.Text = ItemMgr:GetNpcText(taskItemID)
        ItemMgr:RedeemTaskItemReward(taskItemID)
        taskItemID = 0
    end
end

--- 开始小游戏
function EnterMiniGame()
    if currNpcId == nil or NpcInfo[currNpcId] == nil or NpcInfo[currNpcId].GameId == nil then
        return
    end
	SoundUtil.Play2DSE(localPlayer.UserId, 5)
    local gameId = NpcInfo[currNpcId].GameId
    NetUtil.Fire_S('EnterMiniGameEvent', localPlayer, gameId)
    --! Test only
    ----print('[GuiNpc] EnterMiniGameEvent', localPlayer, gameId)
end

--- 打开商城
function EnterShop()
    ----print('[GuiNpc] EnterShop()')
    if currNpcId == nil or NpcInfo[currNpcId] == nil or NpcInfo[currNpcId].ShopId == nil then
        return
    end
	SoundUtil.Play2DSE(localPlayer.UserId, 5)
    -- TODO: 商店相关逻辑
    npcGui.Visible = false
    NetUtil.Fire_C('SwitchStoreUIEvent', localPlayer, 1, currNpcId)
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
        FoundNpc(_npcId, _npcObj)
    else
        BeyondNpc()
    end
end

function GuiNpc:InteractCEventHandler(_id)
    if _id == 12 then
        OpenNpcGui()
    end
end

return GuiNpc
