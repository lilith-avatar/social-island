--- NPC管理
--- @module NPC manager
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang, Lin
local NpcMgr, this = ModuleUtil.New('NpcMgr', ClientBase)

local Config = Config
local NpcInfo = Config.NpcInfo
local NpcText = Config.NpcText
local bubbleShowTime = Config.GlobalSetting.NpcBubbleShowTime
local bubbleIntervalMin = Config.GlobalSetting.NpcBubbleInterval[1]
local bubbleIntervalMax = Config.GlobalSetting.NpcBubbleInterval[2]

local npcFolder
local npcs = {}

--! 初始化

--- 初始化
function NpcMgr:Init()
    print('[NpcMgr] Init()')
    assert(bubbleShowTime < bubbleIntervalMin, '[NpcMgr] NpcBubbleShowTime需要小于NpcBubbleIntervalTime，请检查GlobalSetting表')
    -- Cache
    ItemMgr = ItemMgr

    CreateNpcFolder()
    invoke(CreateNpcs)
end

--- 生成节点
function CreateNpcFolder()
    assert(localPlayer, '[NpcMgr] CreateNpcFolder, localPlayer不存在')
    if localPlayer.Local.Independent.NPC == nil then
        world:CreateObject('FolderObject', 'NPC', localPlayer.Local.Independent)
    end
    npcFolder = localPlayer.Local.Independent.NPC
end

--- 创建NPC
function CreateNpcs()
    for _, npcInfo in pairs(NpcInfo) do
        local npcObj =
            world:CreateInstance(npcInfo.Model, 'NPC_' .. npcInfo.ID, npcFolder, npcInfo.SpawnPos, npcInfo.SpawnRot)
        npcObj.Rotation = npcInfo.SpawnRot
        local id = world:CreateObject('IntValueObject', 'ID', npcObj)
        id.Value = npcInfo.ID
        -- 创建当前玩家
        local state = world:CreateObject('IntValueObject', 'NpcState', npcObj) -- 当前NPC面对的玩家
        state.Value = Const.NpcState.IDLE
        -- cache
        npcs[npcInfo.ID] = {
            obj = npcObj, -- Npc对象
            info = npcInfo -- NpcInfo表格数据
        }
        -- NPC名片SurfaceGUI
        CreateCardGui(npcObj, npcInfo)
        -- NPC气泡SurfaceGUI
        CreateBubbleGui(npcObj, npcInfo)
        -- 事件绑定
        BindNpcEvents(npcObj, npcInfo)
        -- NPC空闲动作
        InitNpcIdleAction(npcObj, npcInfo)
        -- NPC气泡开启
        InitNpcBubble(npcInfo.ID)
        -- 刷新NPC任务符号
        invoke(RefreshNpcTaskSign, .1)
        wait()
    end
end

-- 创建NPC名片
function CreateCardGui(_npcObj, _npcInfo)
    local gui = world:CreateInstance('NpcCardGui', 'CardGui', _npcObj)
    assert(not string.isnilorempty(_npcInfo.Name), string.format('[NpcMgr] NPC的Name不能为空, NpcId = %s', _npcInfo.ID))
    gui.NameBarTxt1.Text = LanguageUtil.GetText(_npcInfo.Name)
    gui.NameBarTxt2.Text = LanguageUtil.GetText(_npcInfo.Name)
    if string.isnilorempty(_npcInfo.Title) then
        gui.TitleBarTxt1.Text = ''
        gui.TitleBarTxt2.Text = ''
    else
        gui.TitleBarTxt1.Text = LanguageUtil.GetText(_npcInfo.Title)
        gui.TitleBarTxt2.Text = LanguageUtil.GetText(_npcInfo.Title)
    end
    gui.LocalPosition = Vector3(0, 2, 0)
    gui.LocalRotation = EulerDegree(0, 0, 0)
    --TODO: 任务提示符，之后可能变成图片
    gui.TaskSignTxt.Visible = false
end

-- 创建NPC气泡
function CreateBubbleGui(_npcObj, _npcInfo)
    if not _npcInfo.BubbleId or #_npcInfo.BubbleId == 0 then
        return -- 没有气泡
    end
    local gui = world:CreateInstance('NpcBubbleGui', 'BubbleGui', _npcObj)
    gui.LocalPosition = Vector3(0, 1.5, 0)
    gui.LocalRotation = EulerDegree(0, 0, 0)
end

-- 事件绑定
function BindNpcEvents(_npcObj, _npcInfo)
    local npcObj, npcInfo = _npcObj, _npcInfo -- 用于闭包
    npcObj.CollisionArea.OnCollisionBegin:Connect(
        function(_hitObj)
            OnEnterNpc(_hitObj, npcInfo.ID)
        end
    )
    npcObj.CollisionArea.OnCollisionEnd:Connect(
        function(_hitObj)
            OnExitNpc(_hitObj, npcInfo.ID)
        end
    )
end

-- NPC空闲动作
function InitNpcIdleAction(_npcObj, _npcInfo)
    if not _npcInfo.Anim or #_npcInfo.Anim == 0 then
        return
    end
    -- 绑定idle动画序列
    for i, anim in ipairs(_npcInfo.Anim) do
        local ani = _npcObj.Avatar:AddAnimationEvent(anim, 1)
        local idx = i ~= #_npcInfo.Anim and i + 1 or 1
        ani:Connect(
            function()
                PlayNpcAnim(_npcObj, _npcInfo, idx)
            end
        )
    end
    -- 绑定EndTalkAnim动画完成后的Idle动画
    local ani = _npcObj.Avatar:AddAnimationEvent(_npcInfo.EndTalkAnim, 1)
    ani:Connect(
        function()
            NpcFaceReset(_npcInfo.ID)
            PlayNpcAnim(_npcObj, _npcInfo, 1)
        end
    )
    -- 随机延时开始播放动画
    TimeUtil.SetTimeout(
        function()
            PlayNpcAnim(_npcObj, _npcInfo, 1)
        end,
        math.random() * 5
    )
end

-- 播放NPC动画
function PlayNpcAnim(_npcObj, _npcInfo, _animIdx)
    _npcObj.Avatar:PlayAnimation(_npcInfo.Anim[_animIdx], 9, 1, 0.1, true, false, 1)
end

-- NPC气泡开启
function InitNpcBubble(_npcId)
    TimeUtil.SetInterval(
        function()
            BubbleShow(_npcId)
        end,
        math.random(bubbleIntervalMin, bubbleIntervalMax)
    )
end

-- 显示气泡
function BubbleShow(_npcId)
    local npcObj = npcs[_npcId].obj
    local gui = npcObj.BubbleGui
    if npcObj.NpcState.Value == Const.NpcState.TALKING then
        BubbleHide(_npcId)
        return
    end
    --npcObj.Avatar:PlayAnimation('SocialComeHere', 9, 1, 0.1, true, false, 1)
    gui.BubbleTxt.Text = PickARandomBubble(npcs[_npcId].info)
    gui.Visible = true
    TimeUtil.SetTimeout(
        function()
            BubbleHide(_npcId)
        end,
        bubbleShowTime
    )
end

-- 隐藏气泡
function BubbleHide(_npcId)
    local gui = npcs[_npcId].obj.BubbleGui
    gui.Visible = false
end

-- 随机获取气泡文字
function PickARandomBubble(_npcInfo)
    if not _npcInfo.BubbleId or #_npcInfo.BubbleId == 0 then
        return
    end
    local idx = math.random(1, #_npcInfo.BubbleId)
    local bubbleId = _npcInfo.BubbleId[idx]
    local bubble = NpcText[bubbleId].Text
    assert(bubbleId and bubble, string.format('[NpcMgr] NPC: %s, 不存在BubbleId: %s', _npcInfo.ID, bubbleId))
    return LanguageUtil.GetText(bubble)
end

-- 玩家进入NPC碰撞盒
function OnEnterNpc(_hitObj, _npcId)
    if _hitObj == localPlayer then
        local npc = npcs[_npcId]
        if npc.obj.NpcState.Value == Const.NpcState.IDLE then
            npc.obj.NpcState.Value = Const.NpcState.SEE_PLAYER
            NetUtil.Fire_C('TouchNpcEvent', localPlayer, _npcId, npc.obj)
            npc.obj.Avatar:PlayAnimation(npc.info.WelcomeAnim, 9, 1, 0.1, true, false, 1)
            NpcFaceToPlayer(_npcId)
        end
    end
end

-- 玩家离开NPC碰撞盒
function OnExitNpc(_hitObj, _npcId)
    if _hitObj == localPlayer then
        local npc = npcs[_npcId]
        NetUtil.Fire_C('TouchNpcEvent', _hitObj, nil, nil)
        npc.obj.NpcState.Value = Const.NpcState.IDLE
        npc.obj.Avatar:PlayAnimation(npc.info.EndTalkAnim, 9, 1, 0.1, true, false, 1)
    end
end

-- 使NPC面向玩家
function NpcFaceToPlayer(_npcId)
    local npcObj = npcs[_npcId].obj
    local dir = localPlayer.Position - npcObj.Position
    npcObj.Forward = Vector3(dir.x, 0, dir.z)
end

-- 使NPC回复方向
function NpcFaceReset(_npcId)
    npcs[_npcId].obj.Rotation = npcs[_npcId].info.SpawnRot
end

-- 刷新NPC头上的任务符号
-- 此方法推荐等待0.1秒后调用，
-- invoke(RefreshNpcTaskSign, .1)
function RefreshNpcTaskSign()
    for _, npc in pairs(npcs) do
        --TODO: 任务提示符，之后可能变成图片
        npc.obj.CardGui.TaskSignTxt.Visible = (ItemMgr:GetTaskItem(npc.info.ID) > 0)
    end
end

--! Update

function NpcMgr:Update(_dt)
    for _, npc in pairs(npcs) do
        if npc.obj.NpcState.Value == Const.NpcState.SEE_PLAYER or npc.obj.NpcState.Value == Const.NpcState.TALKING then
            NpcFaceToPlayer(npc.info.ID)
        end
    end
end

--! Event handlers 事件处理

-- 玩家开始与NPC对话
function NpcMgr:TalkToNpcEventHandler(_npcId)
    assert(_npcId, string.format('[NpcMgr] TalkToNpcEvent, 事件参数有误, player = %s, npcId = %s', localPlayer, _npcId))
    assert(npcs[_npcId], string.format('[NpcMgr] TalkToNpcEvent, 不存在对应的NPC, npcId = %s', _npcId))
    local npc = npcs[_npcId]
    npc.obj.NpcState.Value = Const.NpcState.TALKING
    npc.obj.Avatar:PlayAnimation(npc.info.TalkAnim, 9, 1, 0.1, true, false, 1)
    BubbleHide(_npcId)
end

-- 玩家主动离开NPC
function NpcMgr:LeaveNpcEventHandler(_npcId)
    assert(_npcId, '[NpcMgr] LeaveNpcEvent, 事件参数有误')
    assert(npcs[_npcId], '[NpcMgr] LeaveNpcEvent, 不存在对应的NPC, npcId = ' .. _npcId)
    local npc = npcs[_npcId]
    if npc.obj.NpcState.Value == Const.NpcState.TALKING then
        npc.obj.NpcState.Value = Const.NpcState.IDLE
        npc.obj.Avatar:PlayAnimation(npc.info.EndTalkAnim, 9, 1, 0.1, true, false, 1)
    end
end

--获得道具
function NpcMgr:GetItemEventHandler(_id)
    invoke(RefreshNpcTaskSign, .1)
end

--移除道具
function NpcMgr:RemoveItemEventHandler(_id)
    invoke(RefreshNpcTaskSign, .1)
end

return NpcMgr
