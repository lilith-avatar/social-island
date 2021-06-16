local BowJumpBeginState = class('BowJumpBeginState', PlayerActState)

function BowJumpBeginState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_man_jump_begin_01', 1, _stateName, 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_woman_jump_begin_01', 1, _stateName, 2)
    PlayerAnimMgr:CreateSingleClipNode('BowEquipIdle', 1, _stateName .. 'UpperBody')
end

function BowJumpBeginState:InitData()
    self:AddTransition(
        'ToIdleState',
        self.controller.states['IdleState'],
        -1,
        function()
            return self.controller.triggers['IdleState']
        end
    )
    self:AddTransition('ToBowJumpRiseState', self.controller.states['BowJumpRiseState'], 0.1)
end

function BowJumpBeginState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0, 0, true, false, 0.6)
    PlayerAnimMgr:Play(self.stateName .. 'UpperBody', 1, 1, 0, 0, true, true, 1)
end

function BowJumpBeginState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    self:Move()
end

---移动
function BowJumpBeginState:Move()
    local dir = PlayerCtrl.finalDir
    dir.y = 0
    if dir.Magnitude > 0 then
        localPlayer:AddMovementInput(dir, 0.5)
    end
end

function BowJumpBeginState:OnLeave()
    PlayerActState.OnLeave(self)
    localPlayer:Jump()
end

return BowJumpBeginState
