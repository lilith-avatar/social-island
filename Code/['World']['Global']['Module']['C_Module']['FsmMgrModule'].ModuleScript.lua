--- 角色动作状态机模块
--- @module Fsm Mgr, client-side
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local FsmMgr, this = ModuleUtil.New("FsmMgr", ClientBase)

--- 变量声明
-- 玩家动作状态机
local playerActFsm = FsmBase:new()

-- 玩家动作状态枚举
local playerActStateEnum = {
    IDLE = "Idle",
    WALK = "Walk",
    RUN = "Run",
    JUMP = "Jump",
    FLY = "Fly",
    SWIM = "Swim",
    SOCIAL = "Social",
    BOWIDLE = "BowIdle",
    BOWWALK = "BowWalk",
    BOWRUN = "BowRun",
    BOWJUMP = "BowJump",
    BOWATTACK = "BowAttack"
}

--- 初始化
function FsmMgr:Init()
    print("FsmMgr:Init")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function FsmMgr:NodeRef()
end

--- 数据变量初始化
function FsmMgr:DataInit()
    --将第2层的动作设为上半身动作
    localPlayer.Avatar:SetBlendSubtree(Enum.BodyPart.UpperBody, 2)
    --将第3层的动作设为下半身动作
    localPlayer.Avatar:SetBlendSubtree(Enum.BodyPart.LowerBody, 3)
    playerActFsm:ConnectStateFunc(Config.PlayerActState, self)
    playerActFsm:SetDefaultState(playerActStateEnum.IDLE)

    this.IdleTrigger = false
    this.JumpTrigger = false
    this.FlyTrigger = false
    this.BowIdleTrigger = false
    this.BowAttackTrigger = false
end

--- 节点事件绑定
function FsmMgr:EventBind()
end

--- 重置触发器
function FsmMgr:ResetTrigger()
    this.IdleTrigger = false
    this.JumpTrigger = false
    this.FlyTrigger = false
    this.BowIdleTrigger = false
    this.BowAttackTrigger = false
end

--- 状态机改变触发器
function FsmMgr:FsmTriggerEventHandler(_state)
    if playerActFsm.curState.stateName ~= _state then
        this[_state .. "Trigger"] = true
    end
end

function FsmMgr:IdleStateOnEnterFunc()
    this:ResetTrigger()
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("Idle", 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar:PlayAnimation("Idle", 3, 1, 0.1, true, true, 1)
end

function FsmMgr:WalkStateOnEnterFunc()
    this:ResetTrigger()
    localPlayer.Avatar:PlayAnimation("WalkingFront", 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar:PlayAnimation("WalkingFront", 3, 1, 0.1, true, true, 1)
end
function FsmMgr:RunStateOnEnterFunc()
    this:ResetTrigger()
    localPlayer.Avatar:PlayAnimation("RunFront", 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar:PlayAnimation("RunFront", 3, 1, 0.1, true, true, 1)
end

function FsmMgr:JumpStateOnEnterFunc()
    this:ResetTrigger()
    localPlayer:Jump()
    localPlayer.Avatar:PlayAnimation("Jump", 2, 1, 0.1, true, false, 1)
    localPlayer.Avatar:PlayAnimation("Jump", 3, 1, 0.1, true, false, 1)
end

function FsmMgr:FlyStateOnEnterFunc()
    this:ResetTrigger()
    PlayerCtrl:SetPlayerControllableEventHandler(false)
    localPlayer.Avatar:PlayAnimation("Flying", 2, 1, 0.1, true, true, 2)
    localPlayer.Avatar:PlayAnimation("Flying", 3, 1, 0.1, true, true, 2)
end

function FsmMgr:BowIdleStateOnEnterFunc()
    this:ResetTrigger()
    localPlayer.Avatar:PlayAnimation("BowChargeIdle", 2, 1, 0.1, true, true, 1)
    localPlayer.Avatar:PlayAnimation("BowChargeIdle", 3, 1, 0.1, true, true, 1)
end

function FsmMgr:BowWalkStateOnEnterFunc()
    this:ResetTrigger()
    localPlayer.Avatar:PlayAnimation("WalkingFront", 3, 1, 0.1, true, true, 1)
end

function FsmMgr:BowRunStateOnEnterFunc()
    this:ResetTrigger()
    local dir = PlayerCtrl.finalDir
    if Vector3.Angle(dir, localPlayer.Forward) < 60 then
        localPlayer.Avatar:PlayAnimation("RunFront", 3, 1, 0.1, true, true, 1)
    elseif Vector3.Angle(dir, localPlayer.Right) < 30 then
        localPlayer.Avatar:PlayAnimation("RunRight", 3, 1, 0.1, true, true, 1)
    elseif Vector3.Angle(dir, localPlayer.Left) < 30 then
        localPlayer.Avatar:PlayAnimation("RunLeft", 3, 1, 0.1, true, true, 1)
    else
        localPlayer.Avatar:PlayAnimation("RunBack", 3, 1, 0.1, true, true, 1)
    end

    --localPlayer.Avatar:PlayAnimation("RunFront", 3, 1, 0.1, true, true, 1)
end

function FsmMgr:BowJumpStateOnEnterFunc()
    this:ResetTrigger()
    localPlayer:Jump()
    localPlayer.Avatar:PlayAnimation("Jump", 3, 1, 0.1, true, false, 1)
end
function FsmMgr:BowAttackStateOnEnterFunc()
    this:ResetTrigger()
    localPlayer.Avatar:PlayAnimation("BowAttack", 2, 1, 0.1, true, false, 1)
    PlayerCtrl:PlayerArchery()
end

function FsmMgr:IdleStateOnUpdateFunc(dt)
    do ---检测移动键输入
        local dir = PlayerCtrl.finalDir
        dir.y = 0
        if dir.Magnitude > 0 then
            playerActFsm:Switch(playerActStateEnum.WALK)
        end
    end
    do ---检测跳跃键输入
        if this.JumpTrigger and localPlayer.IsOnGround then
            playerActFsm:Switch(playerActStateEnum.JUMP)
        end
    end
    do ---检测飞行
        if this.FlyTrigger then
            playerActFsm:Switch(playerActStateEnum.FLY)
        end
    end
    do ---检测装备弓箭
        if this.BowIdleTrigger then
            playerActFsm:Switch(playerActStateEnum.BOWIDLE)
        end
    end
end

function FsmMgr:WalkStateOnUpdateFunc(dt)
    do ---检测移动键输入
        local dir = PlayerCtrl.finalDir
        dir.y = 0
        if dir.Magnitude > 0 then
            if PlayerCam:IsFreeMode() then
                localPlayer:FaceToDir(dir, 4 * math.pi)
            end
            localPlayer:MoveTowards(Vector2(dir.x, dir.z).Normalized)
        else
            playerActFsm:Switch(playerActStateEnum.IDLE)
        end
    end
    do ---是否达到奔跑速度
        if localPlayer.LinearVelocity.Magnitude >= localPlayer.WalkSpeed * 0.99 then
            playerActFsm:Switch(playerActStateEnum.RUN)
        end
    end
    do ---检测跳跃键输入
        if this.JumpTrigger and localPlayer.IsOnGround then
            playerActFsm:Switch(playerActStateEnum.JUMP)
        end
    end
    do ---检测飞行
        if this.FlyTrigger then
            playerActFsm:Switch(playerActStateEnum.FLY)
        end
    end
    do ---检测装备弓箭
        if this.BowIdleTrigger then
            playerActFsm:Switch(playerActStateEnum.BOWIDLE)
        end
    end
end

function FsmMgr:RunStateOnUpdateFunc(dt)
    do ---检测移动键输入
        local dir = PlayerCtrl.finalDir
        dir.y = 0
        if dir.Magnitude > 0 then
            if PlayerCam:IsFreeMode() then
                localPlayer:FaceToDir(dir, 4 * math.pi)
            end
            localPlayer:MoveTowards(Vector2(dir.x, dir.z).Normalized)
        else
            playerActFsm:Switch(playerActStateEnum.IDLE)
        end
    end
    do ---是否达到行走速度
        if localPlayer.LinearVelocity.Magnitude < localPlayer.WalkSpeed * 0.99 then
            playerActFsm:Switch(playerActStateEnum.WALK)
        end
    end
    do ---检测跳跃键输入
        if this.JumpTrigger and localPlayer.IsOnGround then
            playerActFsm:Switch(playerActStateEnum.JUMP)
        end
    end
    do ---检测飞行
        if this.FlyTrigger then
            playerActFsm:Switch(playerActStateEnum.FLY)
        end
    end
    do ---检测装备弓箭
        if this.BowIdleTrigger then
            playerActFsm:Switch(playerActStateEnum.BOWIDLE)
        end
    end
end

function FsmMgr:FlyStateOnUpdateFunc(dt)
    do ---是否在地面
        if localPlayer.IsOnGround then
            playerActFsm:Switch(playerActStateEnum.IDLE)
        end
    end
end

function FsmMgr:JumpStateOnUpdateFunc(dt)
end

function FsmMgr:BowIdleStateOnUpdateFunc(dt)
    localPlayer:MoveTowards(Vector2.Zero)
    do ---检测移动键输入
        local dir = PlayerCtrl.finalDir
        dir.y = 0
        if dir.Magnitude > 0 then
            playerActFsm:Switch(playerActStateEnum.BOWWALK)
        end
    end
    do ---检测跳跃键输入
        if this.JumpTrigger and localPlayer.IsOnGround then
            playerActFsm:Switch(playerActStateEnum.BOWJUMP)
        end
    end
    do ---攻击检测
        if this.BowAttackTrigger then
            playerActFsm:Switch(playerActStateEnum.BOWATTACK)
        end
    end
    do ---检测默认状态
        if this.IdleTrigger then
            playerActFsm:Switch(playerActStateEnum.IDLE)
        end
    end
end

function FsmMgr:BowWalkStateOnUpdateFunc(dt)
    do ---检测移动键输入
        local dir = PlayerCtrl.finalDir
        dir.y = 0
        if dir.Magnitude > 0 then
            if PlayerCam:IsFreeMode() then
                localPlayer:FaceToDir(dir, 4 * math.pi)
            end

            localPlayer:MoveTowards(Vector2(dir.x, dir.z).Normalized)
        else
            playerActFsm:Switch(playerActStateEnum.BOWIDLE)
        end
    end
    do ---是否达到奔跑速度
        if localPlayer.LinearVelocity.Magnitude >= localPlayer.WalkSpeed * 0.99 then
            playerActFsm:Switch(playerActStateEnum.BOWRUN)
        end
    end
    do ---检测跳跃键输入
        if this.JumpTrigger and localPlayer.IsOnGround then
            playerActFsm:Switch(playerActStateEnum.BOWJUMP)
        end
    end
    do ---攻击检测
        if this.BowAttackTrigger then
            playerActFsm:Switch(playerActStateEnum.BOWATTACK)
        end
    end
    do ---检测默认状态
        if this.IdleTrigger then
            playerActFsm:Switch(playerActStateEnum.IDLE)
        end
    end
end

function FsmMgr:BowRunStateOnUpdateFunc(dt)
    do ---检测移动键输入
        local dir = PlayerCtrl.finalDir
        dir.y = 0
        if dir.Magnitude > 0 then
            if localPlayer.LinearVelocity.Magnitude > 0 and Vector3.Angle(dir, localPlayer.LinearVelocity) > 30 then
                if Vector3.Angle(dir, localPlayer.Forward) < 60 then
                    localPlayer.Avatar:PlayAnimation("RunFront", 3, 1, 0.1, true, true, 1)
                elseif Vector3.Angle(dir, localPlayer.Right) < 30 then
                    localPlayer.Avatar:PlayAnimation("RunRight", 3, 1, 0.1, true, true, 1)
                elseif Vector3.Angle(dir, localPlayer.Left) < 30 then
                    localPlayer.Avatar:PlayAnimation("RunLeft", 3, 1, 0.1, true, true, 1)
                else
                    localPlayer.Avatar:PlayAnimation("RunBack", 3, 1, 0.1, true, true, 1)
                end
            end
            localPlayer:MoveTowards(Vector2(dir.x, dir.z).Normalized)
        else
            playerActFsm:Switch(playerActStateEnum.BOWIDLE)
        end
    end
    do ---是否达到行走速度
        if localPlayer.LinearVelocity.Magnitude < localPlayer.WalkSpeed * 0.99 then
            playerActFsm:Switch(playerActStateEnum.BOWWALK)
        end
    end
    do ---检测跳跃键输入
        if this.JumpTrigger and localPlayer.IsOnGround then
            playerActFsm:Switch(playerActStateEnum.BOWJUMP)
        end
    end
    do ---攻击检测
        if this.BowAttackTrigger then
            playerActFsm:Switch(playerActStateEnum.BOWATTACK)
        end
    end
    do ---检测默认状态
        if this.IdleTrigger then
            playerActFsm:Switch(playerActStateEnum.IDLE)
        end
    end
end

function FsmMgr:BowJumpStateOnUpdateFunc(dt)
    do ---是否在地面
        if localPlayer.IsOnGround then
            playerActFsm:Switch(playerActStateEnum.BOWIDLE)
        end
    end
end

function FsmMgr:BowAttackStateOnUpdateFunc(dt)
end

function FsmMgr:IdleStateOnLeaveFunc()
end

function FsmMgr:WalkStateOnLeaveFunc()
end

function FsmMgr:RunStateOnLeaveFunc()
end

function FsmMgr:JumpStateOnLeaveFunc()
end

function FsmMgr:FlyStateOnLeaveFunc()
    localPlayer.Rotation = EulerDegree(0, localPlayer.Rotation.y, 0)
    PlayerCtrl:SetPlayerControllableEventHandler(true)
end

function FsmMgr:BowIdleStateOnLeaveFunc()
end

function FsmMgr:BowWalkStateOnLeaveFunc()
end

function FsmMgr:BowRunStateOnLeaveFunc()
end

function FsmMgr:BowJumpStateOnLeaveFunc()
end

function FsmMgr:BowAttackStateOnLeaveFunc()
end

function FsmMgr:Update(dt)
    playerActFsm:Update(dt)
    --print(playerActFsm.curState.stateName)
end

return FsmMgr
