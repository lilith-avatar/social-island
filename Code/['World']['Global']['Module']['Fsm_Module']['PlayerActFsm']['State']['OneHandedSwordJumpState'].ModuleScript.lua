local OneHandedSwordJump = class("OneHandedSwordJump", PlayerActState)

function OneHandedSwordJump:OnEnter()
    PlayerActState.OnEnter(self)
    localPlayer:Jump()
    localPlayer.Avatar:PlayAnimation("OneHandedSwordJump", 2, 1, 0, true, false, 1)
    --localPlayer.Avatar:PlayAnimation("OneHandedSwordJump", 3, 1, 0, true, false, 1)
end

function OneHandedSwordJump:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    FsmMgr.playerActFsm:TriggerMonitor({"Idle", "SwimIdle"})
    self:IdleMonitor()
end

function OneHandedSwordJump:IdleMonitor()
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if dir.Magnitude > 0 then
        if PlayerCam:IsFreeMode() then
            localPlayer:FaceToDir(dir, 4 * math.pi)
        end
        localPlayer:MoveTowards(Vector2(dir.x, dir.z).Normalized)
    else
        localPlayer:MoveTowards(Vector2.Zero)
    end
end

function OneHandedSwordJump:OneHandedSwordJumpOnLeaveFunc()
    PlayerActState.OnLeave(self)
end

return OneHandedSwordJump
