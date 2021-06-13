--- 角色动作状态机模块
--- @module Fsm Mgr, client-side
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local FsmMgr, this = ModuleUtil.New('FsmMgr', ClientBase)

--- 变量声明

--- 初始化
function FsmMgr:Init()
    --print('FsmMgr:Init')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function FsmMgr:NodeRef()
end

--- 数据变量初始化
function FsmMgr:DataInit()
    -- 玩家动作状态机控制器
    this.playerActCtrl = PlayerActController:new(localPlayer.StateMachine, Module.Fsm_Module.PlayerActFsm.State)
    this.playerActCtrl:SetDefState('IdleState')

    world.OnRenderStepped:Connect(
        function(dt)
            this.playerActCtrl:Update(dt)
        end
    )
end

--- 节点事件绑定
function FsmMgr:EventBind()
end

--- 状态机改变触发器
function FsmMgr:FsmTriggerEventHandler(_state)
    this.playerActCtrl:CallTrigger(_state)
end

function FsmMgr:Update(dt)
end

return FsmMgr
