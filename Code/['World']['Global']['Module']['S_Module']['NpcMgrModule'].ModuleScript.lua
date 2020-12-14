--- NPC管理
--- @module NPC manager
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local NpcMgr, this = ModuleUtil.New('NpcMgr', ServerBase)

-- cache
local Config = Config
local NpcInfo = Config.NpcInfo
local npcFolder
local npcObjs = {}

--- 初始化
function NpcMgr:Init()
    CreateNpcFolder()
    SpawnNpcs()
    print(table.dump(npcObjs))
end

--- 生成节点：world.NPC
function CreateNpcFolder()
    if world.NPC == nil then
        world:CreateObject('FolderObject', 'NPC', world)
    end
    npcFolder = world.NPC
end

--- 创建NPC
function SpawnNpcs()
    for _, npc in pairs(NpcInfo) do
        local npcObj = world:CreateInstance(npc.Model, npc.Name, npcFolder, npc.SpawnPos, npc.SpawnRot)
        local npcInfo = npc
        npcObj.CollisionArea.OnCollisionBegin:Connect(
            function(_hitObj)
                if not _hitObj or _hitObj.ClassName ~= 'PlayerInstance' or _hitObj.Name == npcObj.Name then
                    return
                end
                print(npcObj.Name)
                NetUtil.Fire_C('TouchNpcEvent', _hitObj, npcInfo.ID)
            end
        )
        npcObj.CollisionArea.OnCollisionEnd:Connect(
            function(_hitObj)
                if not _hitObj or _hitObj.ClassName ~= 'PlayerInstance' or _hitObj.Name == npcObj.Name then
                    return
                end
                NetUtil.Fire_C('TouchNpcEvent', _hitObj, nil)
            end
        )
    end
    table.insert(npcObjs, npcObj)
end

return NpcMgr
