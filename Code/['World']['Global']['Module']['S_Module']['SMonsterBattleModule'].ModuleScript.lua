-- @module  MonsterBattle
-- @copyright Lilith Games, Avatar Team
-- @author Lin
local SMonsterBattle,this = ModuleUtil.New('SMonsterBattle',ServerBase)
local DataSheet = DataStore:GetSheet('MonsterData')

---初始化函数
function SMonsterBattle:Init()
end

---Update函数
function SMonsterBattle:Update()
end

--保存长期数据
function SMonsterBattle:SaveMDataEventHandler(_userId,_playerData)
	DataSheet:SetValue(_userId,_playerData,function(value,errCode)
		if errCode then
			print(errCode)
		end
	end)
end
--读取长期数据
function SMonsterBattle:LoadMDataEventHandler(_userId)
	DataSheet:GetValue(_userId,
	function(value,errCode)
		if errCode then
			print(errCode)
		end
		--print(table.dump(value))
		local _playerData = {}
		if value == nil then
			_playerData.showMonster = {}
			_playerData.monsterLis = {}
			_playerData.flowerLis = {} --种花需要的长期数据
		else
			_playerData = value
		end
		NetUtil.Broadcast("LoadMDataBackEvent", _userId, _playerData)
	end)
end
--战斗准备
function SMonsterBattle:BattleReady()
	
end
--战斗开始  todo:处理PVP时PVE的发送状态
function SMonsterBattle:StartBattleEventHandler(_isNpc,_playerA,_playerB)
	if _isNpc then
		NetUtil.Fire_C("ReadyBattleEvent",_playerB,_playerA)
	end
	wait(1)
	local _skillTime = 3
	invoke(function()
		local _time = _skillTime
		while true do
			if _time == _skillTime then
				NetUtil.Fire_C("MBattleEvent",_playerB,'NewRound')
			end
			NetUtil.Fire_C("MBattleEvent",_playerB,'SkllTime',_time)
			wait(1)
			_time = _time - 1
			if _time == -1 then
				NetUtil.Fire_C("MBattleEvent",_playerB,'ShowSkill')
				wait(2)
				local _result = _playerA.BattleVal.Value - _playerB.BattleVal.Value
				if _result == 0 then
					print('平局')
					NetUtil.Fire_C("MBattleEvent",_playerB,'ShowSkill')
					--[[
					for i = 1,50,1 do
						wait(0.1)
					end
					--]]
				elseif _result == -1 or _result == 2 then
					local _attack = math.random(1,_playerA.AttackVal.Value)
					NetUtil.Fire_C("MBattleEvent",_playerB,'BeHit',_attack,_playerA)
				else
					local _attack = math.random(1,_playerB.AttackVal.Value)
					if _isNpc then
						NetUtil.Fire_C("MBattleEvent",_playerB,'NPCBeHit',_attack,_playerB)
					end
					--NetUtil.Fire_C("MBattleEvent",_playerB,'BeHit',_attack)
				end
				wait(1)
				if(_playerB.HealthVal.Value <=0) then 
					print("B输")
					NetUtil.Fire_C("MBattleEvent",_playerB,'Over',false)
					break
				end
				if(_playerA.HealthVal.Value <=0) then
					print("A输")
					NetUtil.Fire_C("MBattleEvent",_playerB,'Over',true)
					break
				end
				_time = _skillTime
			end
		end
	end)
end
return SMonsterBattle