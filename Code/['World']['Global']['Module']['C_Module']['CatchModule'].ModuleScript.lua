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

--接触猎物
function Catch:TouchPrey(_animal, _isTouch)
    if _isTouch then
        prey = _animal
    else
        prey = nil
    end
end

--捕捉动物
function Catch:CatchAnimal(_weaponID)
    if _weaponID == 0 then
        NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer, 19)
        localPlayer.Avatar:PlayAnimation("PickUpLight", 2, 1, 0.1, true, false, 1)
        invoke(
            function()
                this:IsCatch()
            end,
            0.5
        )
    else
    end
end

--判断是否捕捉
function Catch:IsCatch()
    local num = math.random(1000)
    if prey then
        if num < 1000 * Config.Animal[prey.AnimalID.Value].CaughtRate then
            NetUtil.Fire_C("InsertInfoEvent", localPlayer, "捕捉猎物成功", 2, false)
            NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
            prey.AnimalCaughtEvent:Fire()
            local effect = world:CreateInstance("CaughtSuccess", "CaughtSuccess", world, prey.Col.Position)
            invoke(
                function()
                    effect:Destroy()
                end,
                1
            )
        else
            NetUtil.Fire_C("InsertInfoEvent", localPlayer, "猎物挣脱了", 2, false)
            NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
            local effect = world:CreateInstance("CaughtFailed", "CaughtFailed", world, prey.Col.Position)
            invoke(
                function()
                    effect:Destroy()
                end,
                1
            )
        end
    else
        NetUtil.Fire_C("InsertInfoEvent", localPlayer, "猎物太远捕捉失败", 2, false)
        NetUtil.Fire_C("ChangeMiniGameUIEvent", localPlayer)
    end
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
        this:CatchAnimal(0)
    end
end

function Catch:Update(dt)
    this:UpdateCatchUI()
end

return Catch
