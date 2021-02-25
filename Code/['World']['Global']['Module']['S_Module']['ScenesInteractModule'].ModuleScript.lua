--- 场景交互模块
--- @module ScenesInteract Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local ScenesInteract, this = ModuleUtil.New("ScenesInteract", ServerBase)

--- 变量声明
--交互物体
local interactOBJ = {}

--弹跳物体
local bounceOBJ = {}

--望远镜
local telescopeOBJ = {}

--座位
local seatOBJ = {}

--正在交互的ID
local curInteractID = {}

--- 初始化
function ScenesInteract:Init()
    print("[ScenesInteract] Init()")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function ScenesInteract:NodeRef()
    for k, v in pairs(Config.ScenesInteract) do
        interactOBJ[k] = {
            obj = world.ScenesInteract[v.Path],
            itemID = v.ItemID,
            isGet = v.IsGet,
            useCount = v.UseCount
        }
    end
    for k, v in pairs(world.BounceInteract:GetChildren()) do
        bounceOBJ[v.Name] = {
            obj = v,
            originScale = v.Scale,
            tweener1 = nil,
            tweener2 = nil,
            tweener3 = nil,
            isbouncing = false
        }
    end
    for k, v in pairs(world.TelescopeInteract:GetChildren()) do
        telescopeOBJ[v.Name] = {
            obj = v,
            isUsing = false
        }
    end
    for k, v in pairs(world.SeatInteract:GetChildren()) do
        seatOBJ[v.Name] = {
            obj = v,
            player = nil
        }
    end
end

--- 数据变量初始化
function ScenesInteract:DataInit()
end

--- 节点事件绑定
function ScenesInteract:EventBind()
    for k, v in pairs(interactOBJ) do
        v.obj.OnCollisionBegin:Connect(
            function(_hitObject)
                if _hitObject.ClassName == "PlayerInstance" then
                    curInteractID[_hitObject.UserId] = k
                    NetUtil.Fire_C("OpenDynamicEvent", _hitObject, "Interact", 13)
                end
            end
        )
        v.obj.OnCollisionEnd:Connect(
            function(_hitObject)
                if _hitObject.ClassName == "PlayerInstance" then
                    print("v.obj.OnCollisionEnd")
                    curInteractID[_hitObject.UserId] = nil
                    NetUtil.Fire_C("ChangeMiniGameUIEvent", _hitObject)
                end
            end
        )
    end

    for k, v in pairs(bounceOBJ) do
        v.obj.OnCollisionBegin:Connect(
            function(_hitObject)
                print(_hitObject)
                if _hitObject.ClassName == "PlayerInstance" then
                    this:ElasticDeformation(v, _hitObject)
                end
            end
        )
    end

    for k, v in pairs(telescopeOBJ) do
        v.obj.OnCollisionBegin:Connect(
            function(_hitObject)
                if _hitObject.ClassName == "PlayerInstance" and v.isUsing == false then
                    v.isUsing = true
                    NetUtil.Fire_C("OpenDynamicEvent", _hitObject, "Interact", 14)
                end
            end
        )
        v.obj.OnCollisionEnd:Connect(
            function(_hitObject)
                if _hitObject.ClassName == "PlayerInstance" then
                    v.isUsing = false
                    NetUtil.Fire_C("ChangeMiniGameUIEvent", _hitObject)
                end
            end
        )
    end
    for k, v in pairs(seatOBJ) do
        v.obj.OnCollisionBegin:Connect(
            function(_hitObject)
                if _hitObject.ClassName == "PlayerInstance" and v.player == nil then
                    v.player = _hitObject
                    NetUtil.Fire_C("OpenDynamicEvent", _hitObject, "Interact", 15)
                end
            end
        )
        v.obj.OnCollisionEnd:Connect(
            function(_hitObject)
                if _hitObject.ClassName == "PlayerInstance" then
                    v.player = nil
                    NetUtil.Fire_C("ChangeMiniGameUIEvent", _hitObject)
                end
            end
        )
    end
end

--弹跳
function ScenesInteract:ElasticDeformation(_bounce, _player)
    if _bounce.isbouncing == false then
        _bounce.isbouncing = true
        _bounce.tweener1 =
            Tween:TweenProperty(_bounce.obj, {Scale = 0.8 * _bounce.originScale}, 0.1, Enum.EaseCurve.Linear)
        _bounce.tweener2 =
            Tween:TweenProperty(_bounce.obj, {Scale = 1.2 * _bounce.originScale}, 0.1, Enum.EaseCurve.Linear)
        _bounce.tweener3 = Tween:TweenProperty(_bounce.obj, {Scale = _bounce.originScale}, 0.2, Enum.EaseCurve.Linear)
        invoke(
            function()
                _bounce.tweener1:Play()
                wait(0.1)
                _player.LinearVelocity = Vector3(0, 20, 0)
                _bounce.tweener1:Destroy()
                _bounce.tweener2:Play()
                wait(0.1)
                _bounce.tweener3:Play()
                _bounce.tweener2:Destroy()
                wait(0.2)
                _bounce.isbouncing = false
                _bounce.tweener3:Destroy()
            end
        )
    end
end

function ScenesInteract:Update(dt)
end

function ScenesInteract:InteractSEventHandler(_player, _id)
    if _id == 13 then
        if curInteractID[_player.UserId] then
            if interactOBJ[curInteractID[_player.UserId]].useCount > 0 then
                if interactOBJ[curInteractID[_player.UserId]].isGet then
                    NetUtil.Fire_C("GetItemEvent", _player, interactOBJ[curInteractID[_player.UserId]].itemID)
                else
                    NetUtil.Fire_C("UseItemEvent", _player, interactOBJ[curInteractID[_player.UserId]].itemID)
                end
                interactOBJ[curInteractID[_player.UserId]].useCount =
                    interactOBJ[curInteractID[_player.UserId]].useCount - 1
                if interactOBJ[curInteractID[_player.UserId]].useCount == 0 then
                    interactOBJ[curInteractID[_player.UserId]].obj:SetActive(false)
                end
            else
                interactOBJ[curInteractID[_player.UserId]].obj:SetActive(false)
            end
        end
        NetUtil.Fire_C("ChangeMiniGameUIEvent", _player)
    end
    if _id == 15 then
        NetUtil.Fire_C("ChangeMiniGameUIEvent", _player, 15)
        for k, v in pairs(seatOBJ) do
            if v.player == _player then
                v.obj:Sit(v.player)
                v.player.Avatar:PlayAnimation("SitIdle", 2, 1, 0, true, true, 1)
            end
        end
    end
end

function ScenesInteract:LeaveInteractSEventHandler(_player, _id)
    if _id == 15 then
        for k, v in pairs(seatOBJ) do
            if v.player == _player then
                v.obj:Leave(v.player)
                v.player = nil
                PlayerCtrl:PlayerJump()
                NetUtil.Fire_C("ChangeMiniGameUIEvent", _player)
            end
        end
    end
end

return ScenesInteract
