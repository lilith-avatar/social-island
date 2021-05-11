--- 捕猎模块
--- @module Catch Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local Catch, this = ModuleUtil.New('Catch', ClientBase)

--声明变量
local prey = nil

--- 初始化
function Catch:Init()
    print('[Catch] Init()')
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

function Catch:CUseItemEventHandler(_id)
    if _id == 4001 or _id == 4002 or _id == 4003 then
        this:InstanceTrap(_id)
    end
end

--生成一个陷阱
function Catch:InstanceTrap(_ItemID)
    CloudLogUtil.UploadLog(
        'pet',
        'setTrapEvent',
        {trap_id = _ItemID, set_position = localPlayer.Position + localPlayer.Forward}
    )
    local archetTypeName = ''
    if _ItemID == 4001 then
        archetTypeName = 'Trap1'
    elseif _ItemID == 4002 then
        archetTypeName = 'Trap2'
    elseif _ItemID == 4003 then
        archetTypeName = 'Trap3'
    end
    SoundUtil.Play3DSE(localPlayer.Position, 42)
    local trap =
        world:CreateInstance(
        archetTypeName,
        'trap',
        world,
        localPlayer.Position + localPlayer.Forward,
        localPlayer.Rotation
    )
    trap.OnCollisionBegin:Connect(
        function(_hitObject)
            if _hitObject.Parent.AnimalID and _hitObject.Parent.AnimalCaughtEvent then
                this:TrapAnimal(trap.Rate.Value, trap, _hitObject.Parent, _ItemID)
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
function Catch:TrapAnimal(_rate, _trap, _animal, _id)
    if _animal.AnimalTrappedEvent then
        _animal.AnimalTrappedEvent:Fire(_rate)
        _trap.OnCollisionBegin:Clear()

        invoke(
            function()
                if _animal.AnimalState.Value == 6 then
                    CloudLogUtil.UploadLog(
                        'pet',
                        'catchSuccessEvent',
                        {trap_id = _id, animal_id = _animal.Name}
                    )
                    NetUtil.Fire_C(
                        'InsertInfoEvent',
                        localPlayer,
                        LanguageUtil.GetText(Config.GuiText.PetGui_1.Txt),
                        2,
                        false
                    )
                    SoundUtil.Play3DSE(_animal.Position, 43)
                    _trap:SetParentTo(_animal, Vector3(0, -0.5, 0), EulerDegree(0, 0, 0))
                    _trap.Open:SetActive(false)
                    _trap.Close:SetActive(true)
                else
                    CloudLogUtil.UploadLog(
                        'pet',
                        'catchFailEvent',
                        {trap_id = _id, animal_id = _animal.Name}
                    )
                    NetUtil.Fire_C(
                        'InsertInfoEvent',
                        localPlayer,
                        LanguageUtil.GetText(Config.GuiText.PetGui_2.Txt),
                        2,
                        false
                    )
                    local tweener = Tween:ShakeProperty(_trap, {'Rotation'}, 0.5, 5)
                    tweener:Play()
                    local effect =
                        world:CreateInstance(
                        'AnimalEscape',
                        'AnimalEscape',
                        _animal,
                        _animal.Position + Vector3(0, -0.5, 0)
                    )
                    wait(0.5)
                    tweener:Destroy()
                    SoundUtil.Play3DSE(_animal.Position, 44)
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
    NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer, 19)
    if prey then
        if prey.AnimalState.Value == 6 then
            this:Catch()
        elseif prey.AnimalState.Value == 5 then
            this:Search()
        else
            this:Touch()
        end
    else
        NetUtil.Fire_C('InsertInfoEvent', localPlayer, LanguageUtil.GetText(Config.GuiText.PetGui_3.Txt), 2, false)
        NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
    end
end

--捕捉
function Catch:Catch()
    invoke(
        function()
            localPlayer.Avatar:PlayAnimation('PickUpLight', 2, 1, 0.1, true, false, 1)
            wait(.5)
            NetUtil.Fire_C('InsertInfoEvent', localPlayer, LanguageUtil.GetText(Config.GuiText.PetGui_4.Txt), 2, false)
            SoundUtil.Play2DSE(localPlayer.UserId, 13)
            NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
            Pet:OpenNamedPetUI(prey.AnimalID.Value)
            prey.AnimalCaughtEvent:Fire()
            local effect = world:CreateInstance('CaughtSuccess', 'CaughtSuccess', world, prey.Position)
            wait(1)
            effect:Destroy()
        end
    )
end

--肢解
function Catch:Search()
    invoke(
        function()
            localPlayer.Avatar:PlayAnimation('PickUpLight', 2, 1, 0.1, true, false, 1)
            wait(.5)
            NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
            NetUtil.Fire_C('GetItemFromPoolEvent', localPlayer, Config.Animal[prey.AnimalID.Value].ItemPoolID, 0)
            CloudLogUtil.UploadLog(
                'inter',
                'hunt_' .. prey.AnimalID.Value .. '_pickup',
                Config.Animal[prey.AnimalID.Value].ItemPoolID
            )
            --[[NetUtil.Fire_S(
                "SpawnCoinEvent",
                "P",
                prey.Position + Vector3(0, 1, 0),
                math.floor(self.config.IncomeFactor * Config.Animal[prey.AnimalID.Value].DropCoin)
            )]]
            prey.AnimalCaughtEvent:Fire()
            local effect = world:CreateInstance('CaughtSuccess', 'CaughtSuccess', world, prey.Position)
            wait(1)
            effect:Destroy()
        end
    )
end

--触摸
function Catch:Touch()
    NetUtil.Fire_C('InsertInfoEvent', localPlayer, LanguageUtil.GetText(Config.GuiText.PetGui_5.Txt), 2, false)
    NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
end

--更新捕捉互动UI
function Catch:UpdateCatchUI()
    if prey then
        if (prey.Position - localPlayer.Position).Magnitude > 3 then
            prey = nil
            NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
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

--- 玩家碰撞开始
function Catch:CInteractOnPlayerColBeginEventHandler(_obj, _id)
    if _id == 19 then
        Catch:TouchPrey(_obj, true)
        NetUtil.Fire_C('OpenDynamicEvent', localPlayer, 'Interact', 19)
    end
end

return Catch
