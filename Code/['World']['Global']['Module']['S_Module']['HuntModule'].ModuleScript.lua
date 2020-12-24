--- 打猎交互模块
--- @module Hunt Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local Hunt, this = ModuleUtil.New("Hunt", ServerBase)

--- 变量声明
-- 节点
local rootNode = world.MiniGames.Game_01_Hunt

-- 动物对象池
local animalObjPool = {}

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
    DEADED = 4
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
    for i = 1, 20, 1 do
        animalObjPool[i] = {
            obj = world:CreateInstance(
                "Animal_01",
                "Animal" .. i,
                rootNode.Animal,
                rootNode.Animal.Position + Vector3(math.random(-50, 50), 1, math.random(-50, 50)),
                EulerDegree(0, 0, 0)
            ),
            state = animalActState.IDLE,
            stateTime = 0,
            closePlayer = nil
        }
        animalObjPool[i].obj.Col.OnCollisionBegin:Connect(
            function(_hitObject)
                if _hitObject then
                    if _hitObject.Name == "Arrow" then
                        _hitObject:Destroy()
                        animalObjPool[i].stateTime = 10
                        this:ChangeAnimalState(animalObjPool[i], animalActState.DEADED)
                    end
                end
            end
        )
    end
end

--- 节点事件绑定
function Hunt:EventBind()
end

--- 节点事件绑定
function Hunt:EnterMiniGameEventHandler(_player, _gameId)
    if _gameId == 1 then
        NetUtil.Fire_C("FsmTriggerEvent", _player, "BowIdle")
        NetUtil.Fire_C("SetMiniGameGuiEvent", _player, _gameId, true, true)
    end
end

--- 动物运动状态改变
function Hunt:ChangeAnimalState(_animalObjPool, _state, _linearVelocity)
    _animalObjPool.state = _state
    if _animalObjPool.state == animalActState.IDLE then
        _animalObjPool.obj:SetActive(true)
        _animalObjPool.obj.LinearVelocityController.TargetLinearVelocity = Vector3.Zero
    elseif _animalObjPool.state == animalActState.MOVE then
        _animalObjPool.obj:SetActive(true)
        _animalObjPool.obj.LinearVelocityController.TargetLinearVelocity =
            _linearVelocity or Vector3(math.random(-30, 30), 0, math.random(-30, 30))
    elseif _animalObjPool.state == animalActState.SCARED then
        _animalObjPool.obj.LinearVelocityController.TargetLinearVelocity =
            (_animalObjPool.obj.Position - _animalObjPool.closePlayer.Position).Normalized * 80
    elseif _animalObjPool.state == animalActState.DEADED then
        _animalObjPool.obj.LinearVelocityController.TargetLinearVelocity = Vector3.Zero
        _animalObjPool.obj:SetActive(false)
    end
end

--- 动物惊吓
function Hunt:AnimalScared(_animalObjPool)
    if _animalObjPool.state ~= animalActState.DEADED then
        for k, v in pairs(world:FindPlayers()) do
            if (v.Position - _animalObjPool.obj.Position).Magnitude < 6 then
                local dis = (v.Position - _animalObjPool.obj.Position).Magnitude
                if _animalObjPool.state == animalActState.SCARED then
                    if
                        dis < (_animalObjPool.obj.Position - _animalObjPool.closePlayer.Position).Magnitude or
                            _animalObjPool.closePlayer == nil
                     then
                        _animalObjPool.closePlayer = v
                        this:ChangeAnimalState(_animalObjPool, animalActState.SCARED)
                    end
                else
                    _animalObjPool.closePlayer = v
                    this:ChangeAnimalState(_animalObjPool, animalActState.SCARED)
                end
            end
        end
    end
end

--- 动物范围限制
function Hunt:AnimalRangeLimit(_animalObjPool)
    if _animalObjPool.state ~= animalActState.DEADED then
        if
            _animalObjPool.obj.Position.x > rootNode.Animal.Position.x + animalMoveRange.max.x or
                _animalObjPool.obj.Position.x < rootNode.Animal.Position.x + animalMoveRange.min.x or
                _animalObjPool.obj.Position.z > rootNode.Animal.Position.z + animalMoveRange.max.z or
                _animalObjPool.obj.Position.z < rootNode.Animal.Position.z + animalMoveRange.min.z
         then
            this:ChangeAnimalState(
                _animalObjPool,
                animalActState.MOVE,
                (rootNode.Animal.Position - _animalObjPool.obj.Position).Normalized * math.random(10, 30)
            )
        end
    end
end

--- 动物运动
function Hunt:AnimalMove(dt)
    for k, v in pairs(animalObjPool) do
        if v.stateTime > 0 then
            v.stateTime = v.stateTime - dt
        else
            v.stateTime = math.random(5, 20)
            this:ChangeAnimalState(v, v.state % 2 + 1)
        end
        this:AnimalScared(v)
        this:AnimalRangeLimit(v)
    end
end

function Hunt:Update(dt)
    this:AnimalMove(dt)
end

return Hunt
