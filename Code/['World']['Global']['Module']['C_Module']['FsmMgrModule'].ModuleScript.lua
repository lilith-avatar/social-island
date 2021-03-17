--- 角色动作状态机模块
--- @module Fsm Mgr, client-side
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local FsmMgr, this = ModuleUtil.New("FsmMgr", ClientBase)

--- 变量声明

-- 玩家动作状态枚举
local playerActStateEnum = {
    IDLE = "Idle",
    WALK = "Walk",
    RUN = "Run",
    JUMP = "Jump",
    FLY = "Fly",
    SWIMIDLE = "SwimIdle",
    SWIMMING = "Swimming",
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
    -- 玩家动作状态机
    this.playerActFsm = PlayerActFsm:new()

    this.playerActFsm:ConnectStateFunc(Config.PlayerActState, Module.Fsm_Module.PlayerActFsm.State)
    this.playerActFsm:SetDefaultState(playerActStateEnum.IDLE)
end

--- 节点事件绑定
function FsmMgr:EventBind()
end

--- 状态机改变触发器
function FsmMgr:FsmTriggerEventHandler(_state)
    this.playerActFsm:ContactTrigger(_state)
    print(_state)
end

function FsmMgr:Update(dt)
    this.playerActFsm:Update(dt)
    --print(this.playerActFsm.curState.stateName)
    --print(this.playerActFsm.stateTrigger.BowAttack)
end

return FsmMgr
