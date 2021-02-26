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

--篝火
local bonfireOBJ = {}

--草
local grassOBJ = {}

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
            useCount = v.UseCount,
            resetTime = v.ResetTime,
            resetCD = 0
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
    for k, v in pairs(world.SeatInteract:GetChildren()) do
        seatOBJ[v.Name] = v
    end
    for k, v in pairs(world.BonfireInteract:GetChildren()) do
        bonfireOBJ[v.Name] = v
    end
    for k, v in pairs(world.GrassInteract:GetChildren()) do
        table.insert(grassOBJ, v)
    end
end

--- 数据变量初始化
function ScenesInteract:DataInit()
end

--- 节点事件绑定
function ScenesInteract:EventBind()
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
                _bounce.obj.BounceInteractUID.Value = ""
                _bounce.tweener3:Destroy()
            end
        )
    end
end

--草动
function ScenesInteract:GrassInter(_object)
    local swayTweenerl = this:GrassSwayTween(_object, 20, 0.15)
    local swayTweener2 = this:GrassSwayTween(_object, -30, 0.3)
    local swayTweener3 = this:GrassSwayTween(_object, 0, 0.15)
    swayTweenerl.OnComplete:Connect(
        function()
            swayTweener2:Play()
            swayTweenerl:Destroy()
        end
    )
    swayTweener2.OnComplete:Connect(
        function()
            swayTweener3:Play()
            swayTweener2:Destroy()
        end
    )
    swayTweener3.OnComplete:Connect(
        function()
            swayTweener3:Destroy()
        end
    )

    swayTweenerl:Play()
end

function ScenesInteract:GrassSwayTween(_obj, _property, _duration)
    return Tween:TweenProperty(
        _obj,
        {Rotation = EulerDegree(_obj.Rotation.x, _obj.Rotation.y, _obj.Rotation.z + _property)},
        _duration,
        Enum.EaseCurve.Linear
    )
end

function ScenesInteract:InteractSEventHandler(_player, _id)
    if _id == 13 then
        for k, v in pairs(interactOBJ) do
            if v.obj.ScenesInteractUID.Value == _player.UserId then
                if v.useCount > 0 then
                    if v.isGet then
                        NetUtil.Fire_C("GetItemEvent", _player, v.itemID)
                    else
                        NetUtil.Fire_C("UseItemEvent", _player, v.itemID)
                    end
                    v.useCount = v.useCount - 1
                    if v.useCount == 0 then
                        v.obj:SetActive(false)
                    end
                else
                    v.obj:SetActive(false)
                end
            end
        end
        NetUtil.Fire_C("ChangeMiniGameUIEvent", _player)
    end
    if _id == 15 then
        NetUtil.Fire_C("ChangeMiniGameUIEvent", _player, 15)
        for k, v in pairs(seatOBJ) do
            if v.SeatInteractUID.Value == _player.UserId then
                v:Sit(_player)
                _player.Avatar:PlayAnimation("SitIdle", 2, 1, 0, true, true, 1)
            end
        end
    end
    if _id == 16 then
        for k, v in pairs(bonfireOBJ) do
            if v.BonfireInteractUID.Value == _player.UserId then
                if v.On.ActiveSelf then
                    v.On:SetActive(false)
                    v.Off:SetActive(true)
                else
                    v.On:SetActive(true)
                    v.Off:SetActive(false)
                end
            end
        end
        NetUtil.Fire_C("ChangeMiniGameUIEvent", _player)
        NetUtil.Fire_C("OpenDynamicEvent", _player, "Interact", 16)
    end
    if _id == 17 then
        for k, v in pairs(bounceOBJ) do
            if v.obj.BounceInteractUID.Value == _player.UserId then
                this:ElasticDeformation(v, _player)
            end
        end
    end
    if _id == 18 then
        for k, v in pairs(grassOBJ) do
            if v.GrassInteractUID.Value == _player.UserId then
                this:GrassInter(v)
            end
        end
    end
end

function ScenesInteract:LeaveInteractSEventHandler(_player, _id)
    if _id == 15 then
        for k, v in pairs(seatOBJ) do
            if v.SeatInteractUID.Value == _player.UserId then
                v:Leave(_player)
                NetUtil.Fire_C("FsmTriggerEvent", _player, "Jump")
                NetUtil.Fire_C("ChangeMiniGameUIEvent", _player)
            end
        end
    end
end

--重置交互物体
function ScenesInteract:ResetSIOBJ(dt)
    for k, v in pairs(interactOBJ) do
        if v.useCount == 0 and v.resetTime > 0 then
            if v.resetCD < v.resetTime then
                v.resetCD = v.resetCD + dt
            else
                v.resetCD = 0
                v.useCount = world.ScenesInteract[v.itemID].UseCount
                v.obj:SetActive(true)
            end
        end
    end
end

function ScenesInteract:Update(dt)
    this:ResetSIOBJ(dt)
end

return ScenesInteract
