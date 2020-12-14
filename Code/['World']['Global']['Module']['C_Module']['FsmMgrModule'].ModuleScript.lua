--- 角色动作状态机模块
--- @module Fsm Mgr, client-side
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local FsmMgr, this = ModuleUtil.New('FsmMgr', ClientBase)

--- 变量声明
-- 玩家动作状态机
local playerActFsm = FsmBase:new()

-- 玩家动作状态枚举
local playerActStateEnum = {
    IDLE = 'Idle',
    WALK = 'Walk',
    RUN = 'Run',
    JUMP = 'Jump',
    FLY = 'Fly',
    SWIM = 'Swim',
    SOCIAL = 'Social'
}

--- 初始化
function FsmMgr:Init()
    print('FsmMgr:Init')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function FsmMgr:NodeRef()
end

--- 数据变量初始化
function FsmMgr:DataInit()
    playerActFsm:ConnectStateFunc(Config.PlayerActState, self)
    playerActFsm:SetDefaultState(playerActStateEnum.IDLE)

    this.jumpTrigger = false
end

--- 节点事件绑定
function FsmMgr:EventBind()
end

--- 重置触发器
function FsmMgr:ResetTrigger()
    this.jumpTrigger = false
end

--- 跳跃触发器
function FsmMgr:RepelledTrigger()
    if playerActFsm.curState.stateName ~= playerActStateEnum.JUMP then
        this.jumpTrigger = true
    end
end

function FsmMgr:IdleStateOnEnterFunc()
    this:ResetTrigger()
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation('Idle', 2, 1, 0.1, true, true, 1)
end

function FsmMgr:WalkStateOnEnterFunc()
    this:ResetTrigger()
    localPlayer.Avatar:PlayAnimation('WalkingFront', 2, 1, 0.1, true, true, 1)
end
function FsmMgr:RunStateOnEnterFunc()
    this:ResetTrigger()
    localPlayer.Avatar:PlayAnimation('RunFront', 2, 1, 0.1, true, true, 1)
end

function FsmMgr:JumpStateOnEnterFunc()
    this:ResetTrigger()
    localPlayer:Jump()
    localPlayer.Avatar:PlayAnimation('Jump', 2, 1, 0.1, true, false, 1)
end

function FsmMgr:IdleStateOnUpdateFunc(dt)
    do ---检测移动键输入
        local dir = GuiControl.finalDir
        dir.y = 0
        if dir.Magnitude > 0 then
            playerActFsm:Switch(playerActStateEnum.WALK)
        end
    end
    do ---检测跳跃键输入
        if this.jumpTrigger and localPlayer.IsOnGround then
            playerActFsm:Switch(playerActStateEnum.JUMP)
        end
    end
end

function FsmMgr:WalkStateOnUpdateFunc(dt)
    do ---检测移动键输入
        local dir = GuiControl.finalDir
        dir.y = 0
        if dir.Magnitude > 0 then
            if GuiControl:IsFreeMode() then
                localPlayer:FaceToDir(dir, 4 * math.pi)
            end
            localPlayer:MoveTowards(Vector2(dir.x, dir.z).Normalized)
        else
            playerActFsm:Switch(playerActStateEnum.IDLE)
        end
    end
    do ---是否达到奔跑速度
        if localPlayer.LinearVelocity.Magnitude >= localPlayer.WalkSpeed then
            playerActFsm:Switch(playerActStateEnum.RUN)
        end
    end
    do ---检测跳跃键输入
        if this.jumpTrigger and localPlayer.IsOnGround then
            playerActFsm:Switch(playerActStateEnum.JUMP)
        end
    end
end

function FsmMgr:RunStateOnUpdateFunc(dt)
    do ---检测移动键输入
        local dir = GuiControl.finalDir
        dir.y = 0
        if dir.Magnitude > 0 then
            if GuiControl:IsFreeMode() then
                localPlayer:FaceToDir(dir, 4 * math.pi)
            end
            localPlayer:MoveTowards(Vector2(dir.x, dir.z).Normalized)
        else
            playerActFsm:Switch(playerActStateEnum.IDLE)
        end
    end
    do ---是否达到行走速度
        if localPlayer.LinearVelocity.Magnitude < localPlayer.WalkSpeed then
            playerActFsm:Switch(playerActStateEnum.WALK)
        end
    end
    do ---检测跳跃键输入
        if this.jumpTrigger and localPlayer.IsOnGround then
            playerActFsm:Switch(playerActStateEnum.JUMP)
        end
    end
end

function FsmMgr:JumpStateOnUpdateFunc(dt)
end

function FsmMgr:IdleStateOnLeaveFunc()
end

function FsmMgr:WalkStateOnLeaveFunc()
end

function FsmMgr:RunStateOnLeaveFunc()
end

function FsmMgr:JumpStateOnLeaveFunc()
end

function FsmMgr:Update(dt)
    playerActFsm:Update(dt)
end

return FsmMgr
