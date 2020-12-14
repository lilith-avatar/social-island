--- NPC管理
--- @module NPC manager
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local NpcMgr, this = ModuleUtil.New('NpcMgr', ServerBase)

-- cache
local Config = Config
local npcFolder

--- 初始化
function NpcMgr:Init()
    CreateNpcFolder()
    SpawnNpcs()
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
    for _, npc in pairs(Config.NpcInfo) do
        world:CreateInstance(npc.Model, npc.Name, npcFolder, npc.SpawnPos, npc.SpawnRot)
    end
end

return NpcMgr
