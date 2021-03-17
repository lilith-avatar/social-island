--- 玩家动作状态
-- @module  PlayerActState
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
local PlayerActState = class("PlayerActState", StateBase)

function PlayerActState:OnEnter()
    StateBase.OnEnter(self)
    FsmMgr.playerActFsm:ResetTrigger()
end

---监听静止
function PlayerActState:IdleMonitor(_nextStateTypeName)
    _nextStateTypeName = _nextStateTypeName or ""
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if dir.Magnitude > 0 then
        if PlayerCam:IsFreeMode() then
            localPlayer:FaceToDir(dir, 4 * math.pi)
        end
        localPlayer:MoveTowards(Vector2(dir.x, dir.z))
    else
        FsmMgr.playerActFsm:Switch(_nextStateTypeName .. "Idle")
    end
end

---监听移动
function PlayerActState:MoveMonitor(_nextStateTypeName)
    _nextStateTypeName = _nextStateTypeName or ""
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if dir.Magnitude > 0 then
        FsmMgr.playerActFsm:Switch(_nextStateTypeName .. "Walk")
    end
end

---监听奔跑
function PlayerActState:RunMonitor(_nextStateTypeName)
    _nextStateTypeName = _nextStateTypeName or ""
    if PlayerCtrl.finalDir.Magnitude >= 0.6 then
        FsmMgr.playerActFsm:Switch(_nextStateTypeName .. "Run")
    end
end

---监听行走
function PlayerActState:WalkMonitor(_nextStateTypeName)
    _nextStateTypeName = _nextStateTypeName or ""
    if PlayerCtrl.finalDir.Magnitude < 0.6 then
        FsmMgr.playerActFsm:Switch(_nextStateTypeName .. "Walk")
    end
end

---监听跳跃
function PlayerActState:JumpMonitor(_nextStateTypeName)
    _nextStateTypeName = _nextStateTypeName or ""
    if FsmMgr.playerActFsm.stateTrigger.Jump and localPlayer.IsOnGround then
        FsmMgr.playerActFsm:Switch(_nextStateTypeName .. "Jump")
    end
end

---监听着地
function PlayerActState:OnGroundMonitor(_nextStateTypeName)
    _nextStateTypeName = _nextStateTypeName or ""
    if localPlayer.IsOnGround then
        FsmMgr.playerActFsm:Switch(_nextStateTypeName .. "Idle")
    end
end

return PlayerActState
