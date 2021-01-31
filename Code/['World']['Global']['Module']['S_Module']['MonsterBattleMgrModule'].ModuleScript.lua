-- @module  MonsterBattle
-- @copyright Lilith Games, Avatar Team
-- @author Lin
local MonsterBattleMgr, this = ModuleUtil.New('MonsterBattleMgr', ServerBase)
local DataSheet = DataStore:GetSheet('MonsterData')
local AUTOSAVE_TIME = 20
local AUTOSAVE_CHANGE = false
local saveTimeDown = 0
local SKILL_TIME = 3 --战斗的倒计时时间

---初始化函数
function MonsterBattleMgr:Init()
    print('[MonsterBattleMgr] init()')
    this.allPlayerData = {}
    world.OnPlayerRemoved:Connect(
        function(player)
            this:DisconnectSave()
        end
    )
end

---Update函数
function MonsterBattleMgr:Update(dt)
	saveTimeDown = saveTimeDown + dt
	if saveTimeDown > AUTOSAVE_TIME and AUTOSAVE_CHANGE then
		this:DisconnectSave()
		saveTimeDown = 0
		AUTOSAVE_CHANGE = false
	end
end

--保存长期数据
function MonsterBattleMgr:SaveMDataEventHandler(_userId, _playerData)
    this.allPlayerData[_userId] = _playerData
	AUTOSAVE_CHANGE = true
end

function MonsterBattleMgr:DisconnectSave()
    print('[MonsterBattleMgr] DisconnectSave() 长期存储保存保存')
    for k, v in pairs(this.allPlayerData) do
        --print(table.dump(v))
        DataSheet:SetValue(
            k,
            v,
            function(value, errCode)
                if errCode then
                    print('[MonsterBattleMgr] DisconnectSave() errCode =', errCode)
                end
            end
        )
    end
end

--读取长期数据
function MonsterBattleMgr:LoadMDataEventHandler(_userId)
    DataSheet:GetValue(
        _userId,
        function(value, errCode)
            if errCode then
                print('[MonsterBattleMgr] LoadMDataEventHandler() errCode =', errCode)
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
            NetUtil.Broadcast('LoadMDataBackEvent', _userId, _playerData)
        end
    )
end
--战斗开始  todo:处理PVP时PVE的发送状态
function MonsterBattleMgr:StartBattleEventHandler(_isNpc, _playerA, _playerB)
    if _isNpc then
        NetUtil.Fire_C('ReadyBattleEvent', _playerB, _playerA)
    end
    wait(1)
	BattleRoute(_isNpc, _playerA, _playerB)
end

function BattleRoute(_isNpc, _playerA, _playerB)
	invoke(function()
	local _time = SKILL_TIME
	local _breakFlag = false
	local _result = 0
	local _attack = -100
	local _attack2 = -100
	local _newRound = true
    while not _breakFlag do
		if _newRound then
			NetUtil.Fire_C('MBattleEvent', _playerB, Const.MonsterEnum.NEWROUND)--告诉客户端开始了新的回合
			_newRound = false
        end
		NetUtil.Fire_C('MBattleEvent', _playerB, Const.MonsterEnum.SKILLTIME, _time)--客户端同步倒计时
        wait(1)
        _time = _time - 1
        if _time == -1 then --当倒计时结束时
            NetUtil.Fire_C('MBattleEvent', _playerB, Const.MonsterEnum.SHOWSKILL)
            wait(2)
            _result = _playerA.BattleVal.Value - _playerB.BattleVal.Value
            if _result == 0 then
                print('[MonsterBattleMgr] 平局')
				_attack = GetRandomAttack(_playerA.AttackVal.Value)
                NetUtil.Fire_C('MBattleEvent', _playerB, Const.MonsterEnum.BEHIT, _attack, _playerA)
				_attack2 = GetRandomAttack(_playerB.AttackVal.Value)
                if _isNpc then
                    NetUtil.Fire_C('MBattleEvent', _playerB, Const.MonsterEnum.NPCBEHIT, _attack2, _playerB)
                end
            elseif _result == -1 or _result == 2 then
                _attack = GetRandomAttack(_playerA.AttackVal.Value)
                NetUtil.Fire_C('MBattleEvent', _playerB, Const.MonsterEnum.BEHIT, _attack, _playerA)
            else
                _attack = GetRandomAttack(_playerB.AttackVal.Value)
                if _isNpc then
                    NetUtil.Fire_C('MBattleEvent', _playerB, Const.MonsterEnum.NPCBEHIT, _attack, _playerB)
                end
            end
				
			wait(1)
			_breakFlag = false
            if _playerB.HealthVal.Value <= 0 then
               print('[MonsterBattleMgr] B输')
               NetUtil.Fire_C('MBattleEvent', _playerB, Const.MonsterEnum.OVER, false)
               _breakFlag = true
            end
            if _playerA.HealthVal.Value <= 0 then
               print('[MonsterBattleMgr] A输')
               NetUtil.Fire_C('MBattleEvent', _playerB, Const.MonsterEnum.OVER, true)
               _breakFlag = true
            end
			
            _time = SKILL_TIME
			_newRound = true
        end
    end
	end)
end

function GetRandomAttack(_num)
	return math.modf(_num - math.randomFloat(0, _num*(1/3)))
end

--在指定位置创建一个宠物
function MonsterBattleMgr:SpawnMonsterInPos(_pos)
	if world.NPCMonster == nil then
        world:CreateObject('FolderObject', 'NPCMonster', world)
    end
	local _collision = world:CreateObject('Sphere','MonsterRange',world.NPCMonster)
	_collision.Size = Vector3.One*3
	_collision.Color = Color(255,255,255,50)
	_collision.Block = false
	_collision.Position = localPlayer.Position + localPlayer.Forward * 5
	this:CreateMonster(_collision, nil)
end


-- 创建NPC的宠物
function MonsterBattleMgr:CreateMonster(_npcObj, _npcInfo)
    world:CreateObject('IntValueObject', 'HealthVal', _npcObj)
    world:CreateObject('IntValueObject', 'AttackVal', _npcObj)
    world:CreateObject('IntValueObject', 'BattleVal', _npcObj)
    local monsterVal = world:CreateObject('ObjRefValueObject', 'MonsterVal', _npcObj)
    local monsterObj = nil
	if _npcInfo then
		monsterObj = world:CreateInstance(_npcInfo.PetModel, 'Pet_' .. _npcInfo.ID, monsterFolder)
		monsterObj.Position = _npcObj.Position - _npcObj.Forward * 2
	else
		monsterObj = world:CreateInstance('Monster', 'Pet', monsterFolder)
		monsterObj.Position = _npcObj.Position
	end
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

return MonsterBattleMgr
