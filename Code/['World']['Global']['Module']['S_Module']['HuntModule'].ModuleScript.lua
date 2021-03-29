--- 打猎交互模块
--- @module Hunt Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local Hunt, this = ModuleUtil.New('Hunt', ServerBase)

--- 变量声明
-- 节点
local rootNode = world.MiniGames.Game_01_Hunt

-- 动物区域
local animalArea = {}

-- 动物数量上限
local animalAmountMax = 1

-- 动物运动状态枚举
local animalActState = {
    DISABLE = 0,
    IDLE = 1,
    WANDER = 2,
    SCARED = 3,
    BACK = 4,
    DEADED = 5,
    TRAPPED = 6
}

-- 进入状态触发
local EnterStateFunc = {}
-- 状态持续触发
local UpdateStateFunc = {}
-- 离开状态触发
local LeaveStateFunc = {}

--- 初始化
function Hunt:Init()
    print('Hunt:Init')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
    this:InitAnimalArea()
    this:InitAnimalData()
end

--- 节点引用
function Hunt:NodeRef()
    Navigation.SetWalkableRoots(world.Scenes.Terrain:GetChildren())
    --Navigation.SetObstacleRoots(world.Water:GetChildren())
    Navigation.SetObstacleRoots(table.MergeTables(world.Stone:GetChildren(), world.Tree:GetChildren()))
    Navigation.SetAgent(1, 0.1, 0.2, 30.0)
    Navigation.SetUpdateDelay(0)
end

--- 数据变量初始化
function Hunt:DataInit()
end

--- 节点事件绑定
function Hunt:EventBind()
    for k, v in pairs(animalActState) do
        LeaveStateFunc[v] = function(_animalData)
            _animalData.obj.IsStatic = false
            if _animalData.obj.AnimalDeadEvent then
                _animalData.obj.AnimalDeadEvent:SetActive(false)
            end
            if _animalData.obj.AnimalCaughtEvent then
                _animalData.obj.AnimalCaughtEvent:SetActive(false)
            end
            if _animalData.obj.AnimalTrappedEvent then
                _animalData.obj.AnimalTrappedEvent:SetActive(false)
            end
            this['LeaveState' .. v](self, _animalData)
        end
        EnterStateFunc[v] = function(_animalData)
            if _animalData.state ~= v or _animalData.state == animalActState.SCARED then
                LeaveStateFunc[v](_animalData)
                _animalData.obj.AnimalState.Value = v
                _animalData.state = v
                this['EnterState' .. v](self, _animalData)
            end
        end
        UpdateStateFunc[v] = function(_animalData, dt)
            if _animalData.stateTime > 0 and type(dt) == 'number' then
                _animalData.stateTime = _animalData.stateTime - dt
            end
            this['UpdateState' .. v](self, _animalData)
        end
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
        local spawnPoint = {}
        for _, animalID in pairs(Config.AnimalArea[areaID].AnimalIDList) do
            for i = 1, math.ceil(Config.Animal[animalID].Weight / weightSum * area.initAmount) do
                spawnPoint = area.SpawnPoint[math.random(1, #area.SpawnPoint)]
                this:InstanceAnimal(
                    area.animalData,
                    animalID,
                    rootNode.Animal,
                    area.pos,
                    area.range,
                    spawnPoint[1],
                    spawnPoint[2]
                )
                animalAmount = animalAmount + 1
            end
        end
        if animalAmount < area.amountMax then
            for i = 1, area.amountMax - animalAmount do
                local id = Config.AnimalArea[areaID].AnimalIDList[math.random(#Config.AnimalArea[areaID].AnimalIDList)]
                spawnPoint = area.SpawnPoint[math.random(1, #area.SpawnPoint)]
                this:InstanceAnimal(
                    area.animalData,
                    id,
                    rootNode.Animal,
                    area.pos,
                    area.range,
                    spawnPoint[1],
                    spawnPoint[2]
                )
            end
        end
    end
    this:AreaSpawnCtrl()
end

--- 实例化动物
function Hunt:InstanceAnimal(_animalData, _animalID, _parent, _areaCenterPos, _areaRange, _SpawnPos, _SpawnRot)
    local tempData = {
        obj = world:CreateInstance(
            Config.Animal[_animalID].ArchetypeName,
            Config.Animal[_animalID].ArchetypeName .. #_animalData + 1,
            _parent,
            _SpawnPos,
            _SpawnRot
        ),
        areaCenterPos = _areaCenterPos,
        areaRange = _areaRange,
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
        caughtRate = Config.Animal[_animalID].CaughtRate,
        hitAEID = Config.Animal[_animalID].HitAEID,
        deadAEID = Config.Animal[_animalID].DeadAEID,
        moveTable = {},
        moveStep = 1
    }
    tempData.obj.AnimalID.Value = _animalID
    this:GetMoveTable(tempData)

    if tempData.obj.AnimalDeadEvent then
        tempData.obj.AnimalDeadEvent:Connect(
            function()
                EnterStateFunc[animalActState.DEADED](tempData)
                SoundUtil.Play3DSE(tempData.obj.Position, tempData.hitAEID)
                SoundUtil.Play3DSE(tempData.obj.Position, tempData.deadAEID)
            end
        )
    end

    if tempData.obj.AnimalCaughtEvent then
        tempData.obj.AnimalCaughtEvent:Connect(
            function()
                tempData.obj:SetActive(false)
                EnterStateFunc[animalActState.DISABLE](tempData)
                if tempData.obj.trap then
                    tempData.obj.trap:Destroy()
                end
            end
        )
    end

    if tempData.obj.AnimalTrappedEvent then
        tempData.obj.AnimalTrappedEvent:Connect(
            function(_rate)
                local num = math.random(1000)
                if num < 1000 * (tempData.caughtRate + _rate) then
                    EnterStateFunc[animalActState.TRAPPED](tempData)
                    SoundUtil.Play3DSE(tempData.obj.Position, tempData.hitAEID)
                end
            end
        )
    end

    _animalData[#_animalData + 1] = tempData
end

--- 区域刷新管理
function Hunt:AreaSpawnCtrl()
    if this:CountAllAliveAnimal() < animalAmountMax then
        for k, v in pairs(animalArea) do
            if this:CountAreaAliveAnimal(v) < v.amountMax then
                this:ActiveAreaAnimal(v, v.amountMax - this:CountAreaAliveAnimal(v))
            end
        end
    else
        for k, v in pairs(animalArea) do
            if this:CountAreaAliveAnimal(v) > v.amountMax then
                this:DeActiveAreaAnimal(v, this:CountAreaAliveAnimal(v) - v.amountMax)
            end
        end
    end
end

--- 计算区域存活动物数量
function Hunt:CountAreaAliveAnimal(_animalArea)
    local num = 0
    for k, v in pairs(_animalArea.animalData) do
        if v.state ~= animalActState.DISABLE then
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

--- 关闭区域中一定数量动物
function Hunt:DeActiveAreaAnimal(_animalArea, _num)
    local count = _num
    for k, v in pairs(_animalArea.animalData) do
        local randomNum = math.random(3)
        if
            v.state == animalActState.IDLE or v.state == animalActState.WANDER or v.state == animalActState.SCARED or
                v.state == animalActState.BACK and randomNum > 2
         then
            EnterStateFunc[animalActState.DISABLE](v)
            count = count - 1
        end
        if count == 0 then
            break
        end
    end
end

--- 打开区域中一定数量动物
function Hunt:ActiveAreaAnimal(_animalArea, _num)
    local count = _num
    for k, v in pairs(_animalArea.animalData) do
        if count > 0 then
            local randomNum = math.random(3)
            if v.state == animalActState.DISABLE and randomNum > 2 then
                EnterStateFunc[animalActState.IDLE](v)
                count = count - 1
            end
        end
        if count == 0 then
            break
        end
    end
end

-- 获取移动点
function Hunt:GetMoveTable(_animalData, _dir)
    _animalData.moveStep = 1
    if _dir then
        _animalData.moveTable =
            _animalData.obj:GetWaypoints(
            _animalData.obj.Position,
            _animalData.obj.Position + _dir.Normalized * _animalData.areaRange * 0.5 +
                Vector3(
                    math.random(-1 * math.floor(_animalData.areaRange), math.floor(_animalData.areaRange)),
                    0,
                    math.random(-1 * math.floor(_animalData.areaRange), math.floor(_animalData.areaRange))
                ) *
                    0.5,
            0.1,
            1,
            10
        )
    else
        _animalData.moveTable =
            _animalData.obj:GetWaypoints(
            _animalData.obj.Position,
            _animalData.areaCenterPos +
                Vector3(
                    math.random(-1 * math.floor(_animalData.areaRange), math.floor(_animalData.areaRange)),
                    0,
                    math.random(-1 * math.floor(_animalData.areaRange), math.floor(_animalData.areaRange))
                ),
            0.1,
            1,
            10
        )
    end
end

-- 进入状态触发
do
    --DISABLE
    function Hunt:EnterState0(_animalData)
        _animalData.stateTime = -1
        _animalData.obj:SetActive(false)
        _animalData.obj:MoveTowards(Vector2.Zero)
        this:AreaSpawnCtrl()
    end
    --IDLE
    function Hunt:EnterState1(_animalData)
        if _animalData.obj.AnimalDeadEvent then
            _animalData.obj.AnimalDeadEvent:SetActive(true)
        end
        if _animalData.obj.AnimalCaughtEvent then
            _animalData.obj.AnimalCaughtEvent:SetActive(true)
        end
        if _animalData.obj.AnimalTrappedEvent then
            _animalData.obj.AnimalTrappedEvent:SetActive(true)
        end
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
        _animalData.obj:MoveTowards(Vector2.Zero)
    end
    --WANDER
    function Hunt:EnterState2(_animalData)
        if _animalData.obj.AnimalDeadEvent then
            _animalData.obj.AnimalDeadEvent:SetActive(true)
        end
        if _animalData.obj.AnimalCaughtEvent then
            _animalData.obj.AnimalCaughtEvent:SetActive(true)
        end
        if _animalData.obj.AnimalTrappedEvent then
            _animalData.obj.AnimalTrappedEvent:SetActive(true)
        end
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
        _animalData.obj.WalkSpeed = _animalData.defMoveSpeed
        this:GetMoveTable(_animalData)
        --this:ActiveMovePid(_animalData)
    end
    --SCARED
    function Hunt:EnterState3(_animalData)
        if _animalData.obj.AnimalDeadEvent then
            _animalData.obj.AnimalDeadEvent:SetActive(true)
        end
        if _animalData.obj.AnimalCaughtEvent then
            _animalData.obj.AnimalCaughtEvent:SetActive(true)
        end
        if _animalData.obj.AnimalTrappedEvent then
            _animalData.obj.AnimalTrappedEvent:SetActive(true)
        end
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
        _animalData.obj.WalkSpeed = _animalData.scaredMoveSpeed
        this:GetMoveTable(_animalData, dir)
        --this:ActiveMovePid(_animalData)
    end
    --BACK
    function Hunt:EnterState4(_animalData)
        if _animalData.obj.AnimalDeadEvent then
            _animalData.obj.AnimalDeadEvent:SetActive(true)
        end
        if _animalData.obj.AnimalCaughtEvent then
            _animalData.obj.AnimalCaughtEvent:SetActive(true)
        end
        if _animalData.obj.AnimalTrappedEvent then
            _animalData.obj.AnimalTrappedEvent:SetActive(true)
        end
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

        local dir = (_animalData.areaCenterPos - _animalData.obj.Position)
        _animalData.obj.WalkSpeed = _animalData.defMoveSpeed
        this:GetMoveTable(_animalData, dir)
        --this:ActiveMovePid(_animalData)
    end
    --DEADED
    function Hunt:EnterState5(_animalData)
        if _animalData.obj.AnimalCaughtEvent then
            _animalData.obj.AnimalCaughtEvent:SetActive(true)
        end
        _animalData.stateTime = 30
        _animalData.obj.BloodEffect:SetActive(true)
        if #_animalData.deadAnimationName > 0 then
            _animalData.obj.AnimatedMesh:PlayAnimation(
                _animalData.deadAnimationName[math.random(#_animalData.deadAnimationName)],
                2,
                1,
                0.1,
                true,
                false,
                1
            )
        end
        _animalData.obj:MoveTowards(Vector2.Zero)
        _animalData.obj.IsStatic = true
        invoke(
            function()
                _animalData.obj.BloodEffect:SetActive(false)
            end,
            1
        )
    end
    --TRAPPED
    function Hunt:EnterState6(_animalData)
        if _animalData.obj.AnimalCaughtEvent then
            _animalData.obj.AnimalCaughtEvent:SetActive(true)
        end
        _animalData.stateTime = 30
        _animalData.obj.BloodEffect:SetActive(true)
        _animalData.obj.AnimatedMesh:PlayAnimation(_animalData.idleAnimationName[1], 2, 1, 0.1, true, true, 1)
        _animalData.obj:MoveTowards(Vector2.Zero)
        _animalData.obj.IsStatic = true
    end
end

-- 开启移动pid
function Hunt:ActiveMovePid(_animalData)
    _animalData.obj.LinearVelocityController.Intensity = _animalData.LVCtrlIntensity
    _animalData.obj.RotationController.Intensity = _animalData.RotCtrlIntensity
    --[[_animalData.obj.LinearVelocityController.TargetLinearVelocity = _targetLinearVelocity
    _animalData.obj.RotationController.Forward = _animalData.obj.LinearVelocityController.TargetLinearVelocity
    _animalData.obj.RotationController.TargetRotation = EulerDegree(0, _animalData.obj.RotationController.Rotation.y, 0)
    _animalData.obj.LinearVelocityController.TargetLinearVelocity = _targetLinearVelocity]]
end

-- 关闭移动pid
function Hunt:DeActiveMovePid(_animalData)
    _animalData.obj.LinearVelocityController.TargetLinearVelocity = Vector3.Zero
    _animalData.obj.LinearVelocityController.Intensity = 0
    _animalData.obj.RotationController.Intensity = 0
    _animalData.obj.LinearVelocity = Vector3.Zero
end

-- 状态持续触发
do
    --DISABLE
    function Hunt:UpdateState0(_animalData)
    end
    --IDLE
    function Hunt:UpdateState1(_animalData)
        if _animalData.stateTime <= 0 then
            EnterStateFunc[animalActState.WANDER](_animalData)
        end
        _animalData.obj:MoveTowards(Vector2.Zero)
        this:AnimalScared(_animalData)
    end
    --WANDER
    function Hunt:UpdateState2(_animalData)
        if _animalData.stateTime <= 0 then
            EnterStateFunc[animalActState.IDLE](_animalData)
        end
        this:AnimalMove(_animalData)
        this:AnimalScared(_animalData)
        this:AnimalRangeLimit(_animalData)
    end
    --SCARED
    function Hunt:UpdateState3(_animalData)
        if _animalData.stateTime <= 0 then
            EnterStateFunc[animalActState.IDLE](_animalData)
        end
        this:AnimalMove(_animalData)
        this:AnimalScared(_animalData)
        this:AnimalRangeLimit(_animalData)
    end
    --BACK
    function Hunt:UpdateState4(_animalData)
        if _animalData.stateTime <= 0 then
            EnterStateFunc[animalActState.IDLE](_animalData)
        end
        this:AnimalMove(_animalData)
    end
    --DEADED
    function Hunt:UpdateState5(_animalData)
        if _animalData.stateTime <= 0 then
            EnterStateFunc[animalActState.DISABLE](_animalData)
        end
        _animalData.obj:MoveTowards(Vector2.Zero)
    end
    --TRAPPED
    function Hunt:UpdateState6(_animalData)
        if _animalData.stateTime <= 0 then
            EnterStateFunc[animalActState.DISABLE](_animalData)
        end
        _animalData.obj:MoveTowards(Vector2.Zero)
    end
end

--- 动物运动
function Hunt:AnimalMove(_animalData)
    if _animalData.moveTable then
        if _animalData.moveStep < #_animalData.moveTable then
            local dir = (_animalData.moveTable[_animalData.moveStep + 1].Position - _animalData.obj.Position).Normalized
            dir.y = 0
            _animalData.obj:FaceToDir(dir, 2 * math.pi)
            _animalData.obj:MoveTowards(Vector2(dir.x, dir.z))
            if (_animalData.obj.Position - _animalData.moveTable[_animalData.moveStep + 1].Position).Magnitude < 0.5 then
                _animalData.moveStep = _animalData.moveStep + 1
            end
        else
            _animalData.obj:MoveTowards(Vector2.Zero)
            EnterStateFunc[animalActState.IDLE](_animalData)
        end
    else
        _animalData.obj:MoveTowards(Vector2.Zero)
        EnterStateFunc[animalActState.IDLE](_animalData)
    end
end

--- 动物惊吓
function Hunt:AnimalScared(_animalData)
    for k, v in pairs(world:FindPlayers()) do
        if (v.Position - _animalData.obj.Position).Magnitude < 6 then
            local dis = (v.Position - _animalData.obj.Position).Magnitude
            if _animalData.state == animalActState.SCARED then
                if
                    dis < (_animalData.obj.Position - _animalData.closePlayer.Position).Magnitude or
                        _animalData.closePlayer == nil
                 then
                    _animalData.closePlayer = v
                    EnterStateFunc[animalActState.SCARED](_animalData)
                end
            else
                _animalData.closePlayer = v
                EnterStateFunc[animalActState.SCARED](_animalData)
            end
        end
    end
end

--- 动物范围限制
function Hunt:AnimalRangeLimit(_animalData)
    if (_animalData.obj.Position - _animalData.areaCenterPos).Magnitude > _animalData.areaRange then
        EnterStateFunc[animalActState.BACK](_animalData)
    end
end

-- 离开状态触发
do
    --DISABLE
    function Hunt:LeaveState0(_animalData)
    end
    --IDLE
    function Hunt:LeaveState1(_animalData)
    end
    --WANDER
    function Hunt:LeaveState2(_animalData)
    end
    --SCARED
    function Hunt:LeaveState3(_animalData)
    end
    --BACK
    function Hunt:LeaveState4(_animalData)
    end
    --DEADED
    function Hunt:LeaveState5(_animalData)
    end
    --TRAPPED
    function Hunt:LeaveState6(_animalData)
    end
end

--- 动物运动
function Hunt:AnimalUpdate(dt)
    for k1, v1 in pairs(animalArea) do
        for k2, v2 in pairs(v1.animalData) do
            UpdateStateFunc[v2.state](v2, dt)
        end
    end
end

function Hunt:Update(dt)
    this:AnimalUpdate(dt)
end

return Hunt
