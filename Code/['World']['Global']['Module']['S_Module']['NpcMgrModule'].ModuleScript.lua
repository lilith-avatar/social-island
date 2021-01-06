--- NPC管理
--- @module NPC manager
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang, Lin
local NpcMgr, this = ModuleUtil.New("NpcMgr", ServerBase)

-- cache
local ServerUtil = ServerUtil
local Config = Config
local NpcInfo = Config.NpcInfo
local npcFolder
local npcObjs = {}

--- 初始化
function NpcMgr:Init()
    CreateNpcFolder()
    SpawnNpcs()
end

--- 生成节点：world.NPC
function CreateNpcFolder()
    if world.NPC == nil then
        world:CreateObject("FolderObject", "NPC", world)
    end
    npcFolder = world.NPC
end

--- 创建NPC
function SpawnNpcs()
    for _, npc in pairs(NpcInfo) do
        local npcObj = world:CreateInstance(npc.Model, npc.Name, npcFolder, npc.SpawnPos, npc.SpawnRot)
        local id = world:CreateObject("IntValueObject", "ID", npcObj)
        id.Value = npc.ID

        -- 生成宠物
        SpawnMonster(npcObj, npc)

        local npcInfo = npc -- 用于闭包
        npcObj.CollisionArea.OnCollisionBegin:Connect(
            function(_hitObj)
                if ServerUtil.CheckHitObjIsPlayer(_hitObj) then
                    NetUtil.Fire_C("TouchNpcEvent", _hitObj, npcInfo.ID, npcObj)
                end
            end
        )
        npcObj.CollisionArea.OnCollisionEnd:Connect(
            function(_hitObj)
                if ServerUtil.CheckHitObjIsPlayer(_hitObj) then
                    NetUtil.Fire_C("TouchNpcEvent", _hitObj, nil, nil)
                end
            end
        )
        table.insert(npcObjs, npcObj)
    end
end

-- 检查碰撞对象是否为NPC
function CheckHitObjIsPlayer(_hitObj)
    return _hitObj and _hitObj.ClassName == "PlayerInstance" and _hitObj.Avatar and
        _hitObj.Avatar.ClassName == "PlayerAvatarInstance"
end

-- 创建NPC的宠物
function SpawnMonster(_npcObj, _npcInfo)
    -- TODO: 这里是根据表判断这个NPC是否是可战斗的NPC
    if true then
        invoke(
            function()
                wait(1)
                local healthVal = world:CreateObject("IntValueObject", "HealthVal", _npcObj)
                local attackVal = world:CreateObject("IntValueObject", "AttackVal", _npcObj)
                local monsterVal = world:CreateObject("ObjRefValueObject", "MonsterVal", _npcObj)
                world:CreateObject("IntValueObject", "BattleVal", _npcObj)
                monsterVal.Value =
                    world:CreateInstance(
                    "Monster",
                    "Monster" .. _npcInfo.Name,
                    world,
                    _npcObj.Position - _npcObj.Forward * 2
                )
                MoveMonster(_npcObj, monsterVal.Value)
            end
        )
    end
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
