--- NPC管理
--- @module NPC manager
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang, Lin
local NpcMgr, this = ModuleUtil.New('NpcMgr', ServerBase)

-- cache
local ServerUtil = ServerUtil
local Config = Config
local NpcInfo = Config.NpcInfo
local NpcText = Config.NpcText
local bubbleShowTime = Config.GlobalSetting.NpcBubbleShowTime
local bubbleIntervalTime = Config.GlobalSetting.NpcBubbleIntervalTime

local npcFolder, monsterFolder
local npcObjs = {}

--- 初始化
function NpcMgr:Init()
    print('[NpcMgr] Init()')
    assert(bubbleShowTime < bubbleIntervalTime, '[NpcMgr] NpcBubbleShowTime需要小于NpcBubbleIntervalTime，请检查GlobalSetting表')
    CreateNpcFolder()
    invoke(CreateNpcs)
end

--- 生成节点：world.NPC
function CreateNpcFolder()
    if world.NPC == nil then
        world:CreateObject('FolderObject', 'NPC', world)
    end
    npcFolder = world.NPC
    if world.NPCMonster == nil then
        world:CreateObject('FolderObject', 'NPCMonster', world)
    end
    monsterFolder = world.NPCMonster
end

--- 创建NPC
function CreateNpcs()
    for _, npc in pairs(NpcInfo) do
        local npcObj = world:CreateInstance(npc.Model, 'NPC_' .. npc.ID, npcFolder, npc.SpawnPos, npc.SpawnRot)
        local id = world:CreateObject('IntValueObject', 'ID', npcObj)
        id.Value = npc.ID
        table.insert(npcObjs, npcObj)
        -- NPC名片SurfaceGUI
        CreateCardGui(npcObj, npc)
        -- NPC气泡SurfaceGUI
        CreateBubbleGui(npcObj, npc)
        -- 事件绑定
        BindNpcEvents(npcObj, npc)
        -- 生成宠物
        CreateMonster(npcObj, npc)
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

-- 创建NPC气泡
function CreateBubbleGui(_npcObj, _npcInfo)
    if not _npcInfo.BubbleId or #_npcInfo.BubbleId == 0 then
        return -- 没有气泡
    end
    local gui = world:CreateInstance('NpcBubbleGui', 'BubbleGui', _npcObj)
    gui.LocalPosition = Vector3(0, 1.5, 0)
    gui.LocalRotation = EulerDegree(0, 0, 0)

    local npcInfo = _npcInfo
    TimeUtil.SetInterval(
        function()
            BubbleShow(gui, npcInfo)
        end,
        bubbleIntervalTime
    )
end

-- 显示气泡
function BubbleShow(_gui, _npcInfo)
    _gui.BubbleTxt.Text = PickARandomBubble(_npcInfo)
    _gui.Visible = true

    TimeUtil.SetTimeout(
        function()
            BubbleHide(_gui)
        end,
        bubbleShowTime
    )
end

-- 隐藏气泡
function BubbleHide(_gui)
    _gui.Visible = false
end

-- 随机获取气泡文字
function PickARandomBubble(_npcInfo)
    local bubbleId = table.shuffle(_npcInfo.BubbleId)[1]
    local bubble = NpcText[bubbleId].Text
    assert(bubbleId and bubble, string.format('[NpcMgr] NPC: %s, 不存在BubbleId: %s', _npcInfo.ID, bubbleId))
    return LanguageUtil.GetText(bubble)
end

-- 事件绑定
function BindNpcEvents(_npcObj, _npcInfo)
    local npcObj, npcInfo = _npcObj, _npcInfo -- 用于闭包
    npcObj.CollisionArea.OnCollisionBegin:Connect(
        function(_hitObj)
            if ServerUtil.CheckHitObjIsPlayer(_hitObj) then
                NetUtil.Fire_C('TouchNpcEvent', _hitObj, npcInfo.ID, npcObj)
            end
        end
    )
    npcObj.CollisionArea.OnCollisionEnd:Connect(
        function(_hitObj)
            if ServerUtil.CheckHitObjIsPlayer(_hitObj) then
                NetUtil.Fire_C('TouchNpcEvent', _hitObj, nil, nil)
            end
        end
    )
end

-- 创建NPC的宠物
function CreateMonster(_npcObj, _npcInfo)
    if not _npcInfo.PetBattleSwitch then
        return
    end
    world:CreateObject('IntValueObject', 'HealthVal', _npcObj)
    world:CreateObject('IntValueObject', 'AttackVal', _npcObj)
    world:CreateObject('IntValueObject', 'BattleVal', _npcObj)
    local monsterVal = world:CreateObject('ObjRefValueObject', 'MonsterVal', _npcObj)
    local monsterObj = world:CreateInstance(_npcInfo.PetModel, 'Pet_' .. _npcInfo.ID, monsterFolder)
    monsterObj.Position = _npcObj.Position - _npcObj.Forward * 2
    monsterObj.Forward = _npcObj.Forward
    monsterVal.Value = monsterObj
    MoveMonster(_npcObj, monsterVal.Value)
end

-- 移动宠物
function MoveMonster(_npcobj, _monster)
    invoke(
        function()
            local timeUp, timeDown = 3, 2

            -- 插入一个随机值，让NPC的宠物错落有致的移动
            wait(math.random() * timeUp)

            -- 宠物向上
            local twUp =
                Tween:TweenProperty(
                _monster.Cube,
                {
                    LocalPosition = Vector3(0, 2.5, 0)
                },
                timeUp,
                Enum.EaseCurve.SinOut
            )
            -- 宠物向下
            local twDown =
                Tween:TweenProperty(
                _monster.Cube,
                {
                    LocalPosition = Vector3(0, 2, 0)
                },
                timeDown,
                Enum.EaseCurve.BackOut
            )
            while _monster and _monster.Cube do
                twUp:Play()
                wait(timeUp + .5)
                twDown:Play()
                wait(timeDown)
            end
        end
    )
end

return NpcMgr
