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

--- 初始化
function NpcMgr:Init()
    print('[NpcMgr] Init()')
    assert(bubbleShowTime < bubbleIntervalMin, '[NpcMgr] NpcBubbleShowTime需要小于NpcBubbleIntervalTime，请检查GlobalSetting表')
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
        local id = world:CreateObject('IntValueObject', 'ID', npcObj)
        id.Value = npcInfo.ID
        -- 创建当前玩家
        world:CreateObject('ObjRefValueObject', 'CurrPlayer', npcObj) -- 当前NPC面对的玩家

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
        -- 生成宠物
        -- if npcInfo.PetBattleSwitch then
        --     MonsterBattleMgr:CreateMonster(npcObj, npcInfo)
        -- end
    end
end

-- 创建NPC名片
function CreateCardGui(_npcObj, _npcInfo)
    local gui = world:CreateInstance('NpcCardGui', 'CardGui', _npcObj)
    gui.NameBarTxt1.Text = LanguageUtil.GetText(_npcInfo.Name)
    gui.NameBarTxt2.Text = LanguageUtil.GetText(_npcInfo.Name)
    gui.TitleBarTxt1.Text = LanguageUtil.GetText(_npcInfo.Title)
    gui.TitleBarTxt2.Text = LanguageUtil.GetText(_npcInfo.Title)
    gui.LocalPosition = Vector3(0, 2, 0)
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

-- 创建NPC气泡
function CreateBubbleGui(_npcObj, _npcInfo)
    if not _npcInfo.BubbleId or #_npcInfo.BubbleId == 0 then
        return -- 没有气泡
    end
    local gui = world:CreateInstance('NpcBubbleGui', 'BubbleGui', _npcObj)
    gui.LocalPosition = Vector3(0, 1.5, 0)
    gui.LocalRotation = EulerDegree(0, 0, 0)
end

-- NPC空闲动作
function InitNpcIdleAction(_npcObj, _npcInfo)
    TimeUtil.SetInterval(
        function()
            PickARandomeIdle(_npcInfo.ID)
        end,
        math.random(bubbleIntervalMin, bubbleIntervalMax)
    )
end

-- 执行一个随机空闲动作
function PickARandomeIdle(_npcId)
    if npcs[_npcId].obj.CurrPlayer.Value then
        return
    end

    local isBubble = math.random(1, 2) == 1
    if isBubble then
        BubbleShow(_npcId)
    else
        local npcObj = npcs[_npcId].obj
        local npcInfo = npcs[_npcId].info
        local idx = math.random(1, #npcInfo.Anim)
        npcObj.Avatar:PlayAnimation(npcInfo.Anim[idx], 9, 1, 0.1, true, false, 1)
    end
end

-- 显示气泡
function BubbleShow(_npcId)
    local npcObj = npcs[_npcId].obj
    local gui = npcObj.BubbleGui
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
        local npcObj = npcs[_npcId].obj
        if not npcObj.CurrPlayer.Value then
            NetUtil.Fire_C('TouchNpcEvent', _hitObj, _npcId, npcObj)
            npcObj.CurrPlayer.Value = _hitObj
        end
    end
end

-- 玩家离开NPC碰撞盒
function OnExitNpc(_hitObj, _npcId)
    if _hitObj == localPlayer then
        NetUtil.Fire_C('TouchNpcEvent', _hitObj, nil, nil)
    end
end

-- 使NPC面向玩家
function NpcFaceToPlayer(_npcObj)
    local ry = Vector3.Angle(Vector3.Forward, localPlayer.Position - _npcObj.Position)
    if localPlayer.Position.x - _npcObj.Position.x >= 0 then
        _npcObj.Rotation = EulerDegree(0, ry, 0)
    else
        _npcObj.Rotation = EulerDegree(0, 360 - ry, 0)
    end
end

return NpcMgr
