--- 捕猎模块
--- @module Catch Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local Catch, this = ModuleUtil.New("Catch", ClientBase)

--声明变量
local prey = nil

--- 初始化
function Catch:Init()
    print("[Catch] Init()")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function Catch:NodeRef()
end

--- 数据变量初始化
function Catch:DataInit()
end

--- 节点事件绑定
function Catch:EventBind()
end

function Catch:UseItemEventHandler(_id)
    if _id == 3025 or _id == 3026 or _id == 3027 then
        this:InstanceTrap(_id)
    end
end

--生成一个陷阱
function Catch:InstanceTrap(_ItemID)
    local archetTypeName = ""
    if _ItemID == 3025 then
        archetTypeName = "Trap1"
    elseif _ItemID == 3026 then
        archetTypeName = "Trap2"
    elseif _ItemID == 3027 then
        archetTypeName = "Trap3"
    end
    local trap = world:CreateInstance(archetTypeName, "trap", world, localPlayer.Position, localPlayer.Rotation)
    trap.OnCollisionBegin:Connect(
        function(_hitObject)
            if _hitObject.Parent.AnimalID and _hitObject.Parent.AnimalCaughtEvent then
                this:TrapAnimal(trap.Rate.Value, trap, _hitObject.Parent)
            end
        end
    )
end

--接触猎物
function Catch:TouchPrey(_animal, _isTouch)
    if _isTouch then
        prey = _animal
    else
        prey = nil
    end
end

--困住动物
function Catch:TrapAnimal(_rate, _trap, _animal)
    if _animal.AnimalTrappedEvent then
        _animal.AnimalTrappedEvent:Fire(_rate)
        _trap.OnCollisionBegin:Clear()

        invoke(
            function()
                if _animal.AnimalState.Value == 6 then
                    NetUtil.Fire_C("InsertInfoEvent", localPlayer, "你的陷阱成功困住了动物", 2, false)
                    NetUtil.Fire_C("PlayEffectEvent", localPlayer, 43)
                    _trap:SetParentTo(_animal, Vector3(0, -0.5, 0), EulerDegree(0, 0, 0))
                    _trap.Open:SetActive(false)
                    _trap.Close:SetActive(true)
                else
                    NetUtil.Fire_C("InsertInfoEvent", localPlayer, "动物挣脱了你的陷阱", 2, false)
                    local tweener = Tween:ShakeProperty(_trap, {"Rotation"}, 0.5, 5)
                    tweener:Play()
                    local effect =
                        world:CreateInstance(
                        "AnimalEscape",
                        "AnimalEscape",
                        _animal,
                        _animal.Position + Vector3(0, -0.5, 0)
                    )
                    _animal.LinearVelocityController.TargetLinearVelocity =
                        _animal.LinearVelocityController.TargetLinearVelocity + _animal.Forward * 5
                    wait(0.5)
                    tweener:Destroy()
                    NetUtil.Fire_C("PlayEffectEvent", localPlayer, 44)
                    _trap:Destroy()
                    wait(1)
                    effect:Destroy()
                end
            end,
            0.5
        )
    end
end

--与动物交互
function Catch:InteractAnimal()
    NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer, 19)
    if prey then
        if prey.AnimalState.Value == 6 then
            this:Catch()
        elseif prey.AnimalState.Value == 5 then
            this:Search()
        else
            this:Touch()
        end
    else
        NetUtil.Fire_C("InsertInfoEvent", localPlayer, "动物离你太远了", 2, false)
        NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
    end
end

--捕捉
function Catch:Catch()
    invoke(
        function()
            localPlayer.Avatar:PlayAnimation("PickUpLight", 2, 1, 0.1, true, false, 1)
            wait(.5)
            NetUtil.Fire_C("InsertInfoEvent", localPlayer, "捕捉动物成功", 2, false)
            NetUtil.Fire_C("PlayEffectEvent", localPlayer, 13)
            NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
            Pet:OpenNamedPetUI(prey.AnimalID.Value)
            prey.AnimalCaughtEvent:Fire()
            local effect = world:CreateInstance("CaughtSuccess", "CaughtSuccess", world, prey.Position)
            wait(1)
            effect:Destroy()
        end
    )
end

--肢解
function Catch:Search()
    invoke(
        function()
            localPlayer.Avatar:PlayAnimation("PickUpLight", 2, 1, 0.1, true, false, 1)
            wait(.5)
            NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
            NetUtil.Fire_C("GetItemFromPoolEvent", localPlayer, Config.Animal[prey.AnimalID.Value].ItemPoolID, 0)
            --[[NetUtil.Fire_S(
                "SpawnCoinEvent",
                "P",
                prey.Position + Vector3(0, 1, 0),
                math.floor(self.config.IncomeFactor * Config.Animal[prey.AnimalID.Value].DropCoin)
            )]]
            prey.AnimalCaughtEvent:Fire()
            local effect = world:CreateInstance("CaughtSuccess", "CaughtSuccess", world, prey.Position)
            wait(1)
            effect:Destroy()
        end
    )
end

--触摸
function Catch:Touch()
    NetUtil.Fire_C("InsertInfoEvent", localPlayer, "尝试用陷阱把动物困住再捕捉吧", 2, false)
    NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
end

--更新捕捉互动UI
function Catch:UpdateCatchUI()
    if prey then
        if (prey.Position - localPlayer.Position).Magnitude > 3 then
            prey = nil
            NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
        end
    end
end

function Catch:InteractCEventHandler(_id)
    if _id == 19 then
        this:InteractAnimal()
    end
end

function Catch:Update(dt)
    this:UpdateCatchUI()
end

return Catch
