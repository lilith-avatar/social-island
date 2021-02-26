--- 打猎交互模块
--- @module Hunt Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local Hunt, this = ModuleUtil.New("Hunt", ServerBase)

--- 变量声明
-- 节点
local rootNode = world.MiniGames.Game_01_Hunt

-- 动物区域
local animalArea = {}

-- 动物数量上限
local animalAmountMax = 10

-- 动物活动范围
local animalMoveRange = {
    min = Vector3(-80, 0, -80),
    max = Vector3(80, 0, 80)
}

-- 动物运动状态枚举
local animalActState = {
    IDLE = 1,
    MOVE = 2,
    SCARED = 3,
    BACK = 4,
    DEADED = 5
}

--- 初始化
function Hunt:Init()
    print("Hunt:Init")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function Hunt:NodeRef()
end

--- 数据变量初始化
function Hunt:DataInit()
    this:InitAnimalArea()
    this:InitAnimalData()
end

--- 节点事件绑定
function Hunt:EventBind()
end

--- 节点事件绑定
function Hunt:EnterMiniGameEventHandler(_player, _gameId)
    if _gameId == 1 then
        print("进入狩猎")
    --NetUtil.Fire_C("FsmTriggerEvent", _player, "BowIdle")
    --NetUtil.Fire_C("SetMiniGameGuiEvent", _player, _gameId, true, true)
    end
end

--- 初始化动物区域
function Hunt:InitAnimalArea()
    for k, v in pairs(Config.AnimalArea) do
        animalArea[v.ID] = {
            pos = v.Pos,
            range = v.Range,
            amountMax = v.AmountMax,
            initAmount = v.InitAmount,
            animalData = {},
			SpawnPoint = v.SpawnPoint
        }
    end
end

--- 初始化动物数据
function Hunt:InitAnimalData()
    for areaID, area in pairs(animalArea) do
        local weightSum = 0
        for _, animalID in pairs(Config.AnimalArea[areaID].AnimalIDList) do
            weightSum = weightSum + Config.Animal[animalID].Weight
        end
        local animalAmount = 0
		local spawnPoint ={}
        for _, animalID in pairs(Config.AnimalArea[areaID].AnimalIDList) do
            for i = 1, math.floor(Config.Animal[animalID].Weight / Config.Animal[animalID].Weight) * area.initAmount do
				spawnPoint = area.SpawnPoint[math.random(1,#area.SpawnPoint)]
                this:InstanceAnimal(area.animalData, animalID, rootNode.Animal, area.pos, area.range, spawnPoint[1],spawnPoint[2])
                animalAmount = animalAmount + 1
            end
        end
        if animalAmount < area.amountMax then
            for i = 1, area.amountMax - animalAmount do
                local id = Config.AnimalArea[areaID].AnimalIDList[math.random(#Config.AnimalArea[areaID].AnimalIDList)]
				spawnPoint = area.SpawnPoint[math.random(1,#area.SpawnPoint)]
                this:InstanceAnimal(area.animalData, id, rootNode.Animal, area.pos, area.range, spawnPoint[1],spawnPoint[2])
            end
        end
    end
    this:AreaSpawnCtrl()
end

--- 实例化动物
function Hunt:InstanceAnimal(_animalData, _animalID, _parent, _pos, _range, _SpawnPos,_SpawnRot)
    local tempData = {
        obj = world:CreateInstance(
            Config.Animal[_animalID].ArchetypeName,
            Config.Animal[_animalID].ArchetypeName .. #_animalData + 1,
            _parent,
            _SpawnPos,
            _SpawnRot
        ),
        state = animalActState.IDLE,
        stateTime = 1,
        defMoveSpeed = Config.Animal[_animalID].DefMoveSpeed,
        scaredMoveSpeed = Config.Animal[_animalID].ScaredMoveSpeed,
        idleAnimationName = Config.Animal[_animalID].IdleAnimationName,
        idleAnimationDurRange = Config.Animal[_animalID].IdleAnimationDurRange,
        moveAnimationName = Config.Animal[_animalID].MoveAnimationName,
        moveAnimationDurRange = Config.Animal[_animalID].MoveAnimationDurRange,
        deadAnimationName = Config.Animal[_animalID].DeadAnimationName,
        closePlayer = nil,
        LVCtrlIntensity = Config.Animal[_animalID].LVCtrlIntensity,
        RotCtrlIntensity = Config.Animal[_animalID].RotCtrlIntensity,
        itemPoolID = Config.Animal[_animalID].ItemPoolID
    }

    tempData.obj.Col.OnCollisionBegin:Connect(
        function(_hitObject)
            if _hitObject and tempData.state ~= animalActState.DEADED then
                if _hitObject.IsHunt and _hitObject.IsHunt.Value == true then
                    --ItemPool:CreateItemObj(5006, _hitObject.Position)
                    NetUtil.Fire_C(
                        "GetItemFromPoolEvent",
                        world:GetPlayerByUserId(_hitObject.UserId.Value),
                        tempData.itemPoolID
                    )
                    _hitObject:Destroy()
                    this:ChangeAnimalState(tempData, animalActState.DEADED)
                    this:AreaSpawnCtrl()                  
                end
            end
        end
    )
    _animalData[#_animalData + 1] = tempData
end

--- 区域刷新管理
function Hunt:AreaSpawnCtrl()
    if this:CountAllAliveAnimal() < animalAmountMax then
        for k, v in pairs(animalArea) do
            if this:CountAreaAliveAnimal(v) < v.amountMax then
                this:ResetAreaAnimal(v, v.amountMax - this:CountAreaAliveAnimal(v))
            end
        end
    else
        for k, v in pairs(animalArea) do
            if this:CountAreaAliveAnimal(v) > v.amountMax then
                this:KillAreaAnimal(v, this:CountAreaAliveAnimal(v) - v.amountMax)
            end
        end
    end
end

--- 计算区域存活动物数量
function Hunt:CountAreaAliveAnimal(_animalArea)
    local num = 0
    for k, v in pairs(_animalArea.animalData) do
        if v.state ~= animalActState.DEADED then
            num = num + 1
        end
    end
    return num
end

--- 计算全场存活动物数量
function Hunt:CountAllAliveAnimal()
    local num = 0
    for k, v in pairs(animalArea) do
        num = num + this:CountAreaAliveAnimal(v)
    end
    return num
end

--- 杀死区域中一定数量动物
function Hunt:KillAreaAnimal(_animalArea, _num)
    local count = _num
    while count > 0 do
        for k, v in pairs(_animalArea.animalData) do
            if v.state ~= animalActState.DEADED and math.random(3) > 2 then
                this:ChangeAnimalState(v, animalActState.DEADED)
                count = count - 1
            end
        end
    end
end

--- 复活区域中一定数量动物
function Hunt:ResetAreaAnimal(_animalArea, _num)
    local count = _num
    while count > 0 do
        for k, v in pairs(_animalArea.animalData) do
            if count > 0 then
                if v.state == animalActState.DEADED and math.random(3) > 2 then
                    this:ChangeAnimalState(v, animalActState.IDLE)
                    count = count - 1
                end
            end
        end
    end
end

--- 动物运动状态改变
function Hunt:ChangeAnimalState(_animalData, _state, _linearVelocity)
    _animalData.state = _state
    if _animalData.state == animalActState.IDLE then
        _animalData.stateTime = math.random(_animalData.idleAnimationDurRange[1], _animalData.idleAnimationDurRange[2])
        _animalData.obj:SetActive(true)
        _animalData.obj.AnimatedMesh:PlayAnimation(
            _animalData.idleAnimationName[math.random(#_animalData.idleAnimationName)],
            2,
            1,
            0.1,
            true,
            true,
            1
        )
        _animalData.obj.LinearVelocityController.TargetLinearVelocity = Vector3.Zero
        _animalData.obj.LinearVelocityController.Intensity = 0
        _animalData.obj.RotationController.Intensity = 0
        _animalData.obj.LinearVelocity = Vector3.Zero
    elseif _animalData.state == animalActState.MOVE then
        _animalData.stateTime = math.random(_animalData.moveAnimationDurRange[1], _animalData.moveAnimationDurRange[2])
        _animalData.obj:SetActive(true)
        _animalData.obj.AnimatedMesh:PlayAnimation(
            _animalData.moveAnimationName[math.random(#_animalData.moveAnimationName)],
            2,
            1,
            0.1,
            true,
            true,
            1
        )
        _animalData.obj.LinearVelocityController.TargetLinearVelocity =
            _linearVelocity or
            Vector3(math.random(-10, 10), 1, math.random(-10, 10)).Normalized * _animalData.defMoveSpeed
        _animalData.obj.LinearVelocityController.Intensity = _animalData.LVCtrlIntensity
        _animalData.obj.RotationController.Intensity = _animalData.RotCtrlIntensity
        _animalData.obj.RotationController.Forward = _animalData.obj.LinearVelocityController.TargetLinearVelocity
        _animalData.obj.RotationController.TargetRotation =
            EulerDegree(0, _animalData.obj.RotationController.Rotation.y, 0)
    elseif _animalData.state == animalActState.SCARED then
        _animalData.stateTime = math.random(_animalData.moveAnimationDurRange[1], _animalData.moveAnimationDurRange[2])
        _animalData.obj.AnimatedMesh:PlayAnimation(
            _animalData.moveAnimationName[math.random(#_animalData.moveAnimationName)],
            2,
            1,
            0.1,
            true,
            true,
            _animalData.scaredMoveSpeed / _animalData.defMoveSpeed
        )
        local dir = (_animalData.obj.Position - _animalData.closePlayer.Position)
        _animalData.obj.LinearVelocityController.TargetLinearVelocity =
            Vector3(dir.x, dir.y > 0 and dir.y or 0, dir.z).Normalized * _animalData.scaredMoveSpeed
        _animalData.obj.LinearVelocityController.Intensity = _animalData.LVCtrlIntensity
        _animalData.obj.RotationController.Intensity = _animalData.RotCtrlIntensity
        _animalData.obj.RotationController.Forward = _animalData.obj.LinearVelocityController.TargetLinearVelocity
        _animalData.obj.RotationController.TargetRotation =
            EulerDegree(0, _animalData.obj.RotationController.Rotation.y, 0)
    elseif _animalData.state == animalActState.BACK then
        _animalData.stateTime = math.random(_animalData.moveAnimationDurRange[1], _animalData.moveAnimationDurRange[2])
        _animalData.obj:SetActive(true)
        _animalData.obj.AnimatedMesh:PlayAnimation(
            _animalData.moveAnimationName[math.random(#_animalData.moveAnimationName)],
            2,
            1,
            0.1,
            true,
            true,
            1
        )
        _animalData.obj.LinearVelocityController.TargetLinearVelocity =
            _linearVelocity or
            Vector3(math.random(-10, 10), 1, math.random(-10, 10)).Normalized * _animalData.defMoveSpeed
        _animalData.obj.LinearVelocityController.Intensity = _animalData.LVCtrlIntensity
        _animalData.obj.RotationController.Intensity = _animalData.RotCtrlIntensity
        _animalData.obj.RotationController.Forward = _animalData.obj.LinearVelocityController.TargetLinearVelocity
        _animalData.obj.RotationController.TargetRotation =
            EulerDegree(0, _animalData.obj.RotationController.Rotation.y, 0)
    elseif _animalData.state == animalActState.DEADED then
        _animalData.obj.LinearVelocityController.TargetLinearVelocity = Vector3.Zero
        _animalData.obj.RotationController.Intensity = 0
        _animalData.obj.LinearVelocityController.Intensity = 0
        _animalData.obj.LinearVelocity = Vector3.Zero
        if #_animalData.deadAnimationName > 0 then
            _animalData.obj.AnimatedMesh:PlayAnimation(
                _animalData.deadAnimationName[math.random(#_animalData.deadAnimationName)],
                2,
                1,
                0.1,
                true,
                true,
                1
            )
        end
        invoke(
            function()
                _animalData.obj:SetActive(false)
            end,
            1
        )
    end
end

--- 动物惊吓
function Hunt:AnimalScared(_animalData)
    if _animalData.state ~= animalActState.DEADED and _animalData.state ~= animalActState.BACK then
        for k, v in pairs(world:FindPlayers()) do
            if (v.Position - _animalData.obj.Position).Magnitude < 6 then
                local dis = (v.Position - _animalData.obj.Position).Magnitude
                if _animalData.state == animalActState.SCARED then
                    if
                        dis < (_animalData.obj.Position - _animalData.closePlayer.Position).Magnitude or
                            _animalData.closePlayer == nil
                     then
                        _animalData.closePlayer = v
                        this:ChangeAnimalState(_animalData, animalActState.SCARED)
                    end
                else
                    _animalData.closePlayer = v
                    this:ChangeAnimalState(_animalData, animalActState.SCARED)
                end
            end
        end
    end
end

--- 动物范围限制
function Hunt:AnimalRangeLimit(_animalArea)
    for k, v in pairs(_animalArea.animalData) do
        if v.state ~= animalActState.DEADED and v.state ~= animalActState.BACK then
            if (v.obj.Position - _animalArea.pos).Magnitude > _animalArea.range then
                this:ChangeAnimalState(
                    v,
                    animalActState.BACK,
                    (_animalArea.pos - v.obj.Position).Normalized * v.defMoveSpeed
                )
            end
        end
    end
end

--- 动物运动
function Hunt:AnimalMove(dt)
    for k1, v1 in pairs(animalArea) do
        for k2, v2 in pairs(v1.animalData) do
            if v2.stateTime > 0 then
                v2.stateTime = v2.stateTime - dt
            elseif v2.state ~= animalActState.DEADED then
                this:ChangeAnimalState(v2, v2.state % 2 + 1)
            end
            this:AnimalScared(v2)
        end
        this:AnimalRangeLimit(v1)
    end
end

function Hunt:Update(dt)
    this:AnimalMove(dt)
end

return Hunt
