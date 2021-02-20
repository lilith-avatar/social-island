local MazeIdleState = class("MazeIdleState", PlayerActState)

function MazeIdleState:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:MoveTowards(Vector2.Zero)
    localPlayer.Avatar:PlayAnimation("Idle", 2, 1, 0.1, true, true, 1)
end

function MazeIdleState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle"})
    self:MoveMonitor("Maze")
end

function MazeIdleState:OnLeave()
    PlayerActState.OnLeave(self)
end

return MazeIdleState
