--- NPC管理
--- @module NPC manager
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang, Lin
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
		world:CreateObject('FolderObject', 'NPCMonster', world)
    end
    npcFolder = world.NPC
end

--- 创建NPC
function SpawnNpcs()
    for _, npc in pairs(NpcInfo) do
        local npcObj = world:CreateInstance(npc.Model, npc.Name, npcFolder, npc.SpawnPos, npc.SpawnRot)
        local npcInfo = npc
		if true then --这里是根据表判断这个NPC是否是可战斗的NPC
			invoke(function()
				wait(1)
				local _healthVal = world:CreateObject('IntValueObject','HealthVal',npcObj)
				local _attackVal = world:CreateObject('IntValueObject','AttackVal',npcObj)
				local _monsterVal = world:CreateObject('ObjRefValueObject','MonsterVal',npcObj)
				world:CreateObject('IntValueObject','BattleVal',npcObj)
				_monsterVal.Value = world:CreateInstance('Monster','Monster'..npc.Name,world.NPCMonster,npcObj.Position - npcObj.Forward*2)
				InitMonster(npcObj,_monsterVal.Value)
			end)
		end
        npcObj.CollisionArea.OnCollisionBegin:Connect(
            function(_hitObj)
                if not _hitObj or _hitObj.ClassName ~= 'PlayerInstance' or not _hitObj.Avatar or _hitObj.Avatar.ClassName ~= 'PlayerAvatarInstance' then
                    return
                end
                print(npcObj.Name, _hitObj)
                NetUtil.Fire_C('TouchNpcEvent', _hitObj, npcInfo.ID, npcObj)
            end
        )
        npcObj.CollisionArea.OnCollisionEnd:Connect(
            function(_hitObj)
                if not _hitObj or _hitObj.ClassName ~= 'PlayerInstance' or not _hitObj.Avatar or _hitObj.Avatar.ClassName ~= 'PlayerAvatarInstance' then
					return
                end
                NetUtil.Fire_C('TouchNpcEvent', _hitObj, nil, nil)
            end
        )
		table.insert(npcObjs, npcObj)
    end
end

function InitMonster(_npcobj,_monster)
	invoke(function() 
		local _moveTime = 2
		while true do
			if _monster and _monster.Cube then
				local Tweener = Tween:TweenProperty(_monster.Cube,{LocalPosition = Vector3(0,2.5,0)},_moveTime,Enum.EaseCurve.Linear)
				Tweener:Play()
				wait(_moveTime)
				Tweener = Tween:TweenProperty(_monster.Cube,{LocalPosition = Vector3(0,2,0)},_moveTime,Enum.EaseCurve.Linear)
				Tweener:Play()
				wait(_moveTime)
			end
		end
	end)
end

return NpcMgr