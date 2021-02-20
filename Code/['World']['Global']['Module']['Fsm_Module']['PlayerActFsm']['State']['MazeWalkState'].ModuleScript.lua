local MazeWalkState = class("MazeWalkState", PlayerActState)

function MazeWalkState:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:PlayAnimation("WalkingFront", 2, 1, 0.1, true, true, 1)
end

function MazeWalkState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle"})
    self:IdleMonitor("Maze")
    self:RunMonitor("Maze")
end

function MazeWalkState:OnLeave()
    PlayerActState.OnLeave(self)
end

return MazeWalkState
