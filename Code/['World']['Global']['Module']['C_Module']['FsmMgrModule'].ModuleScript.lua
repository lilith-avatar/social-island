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
    IDLE = 1,
    WALK = 2,
    FLY = 3,
    SWIM = 4,
    SOCIAL = 5
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
end

--- 节点事件绑定
function FsmMgr:EventBind()
end

return FsmMgr
