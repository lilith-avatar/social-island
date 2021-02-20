local MazeRunState = class("MazeRunState", PlayerActState)

function MazeRunState:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer.Avatar:PlayAnimation("RunFront", 2, 1, 0.1, true, true, 1)
end

function MazeRunState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle"})
    self:IdleMonitor("Maze")
    self:WalkMonitor("Maze")
end
function MazeRunState:OnLeave()
    PlayerActState.OnLeave(self)
end

return MazeRunState
