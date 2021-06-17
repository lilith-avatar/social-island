local BounceState = class('BounceState', PlayerActState)

function BounceState:initialize(_controller, _stateName)
    PlayerActState.initialize(self, _controller, _stateName)
    PlayerAnimMgr:CreateSingleClipNode('anim_man_doublejump_01', 1, _stateName, 1)
    PlayerAnimMgr:CreateSingleClipNode('anim_woman_doublejump_01', 1, _stateName, 2)
end

local isLandMonitor = false
function BounceState:InitData()
    self:AddAnyState(
        'ToBounceState',
        -1,
        function()
            return self.controller.triggers['BounceState']
        end
    )
    self:AddTransition(
        'ToFallState',
        self.controller.states['FallState'],
        -1,
        function()
            return self.controller.triggers['FallState']
        end
    )
    self:AddTransition(
        'ToBowFallState',
        self.controller.states['BowFallState'],
        -1,
        function()
            return self.controller.triggers['BowFallState']
        end
    )
    self:AddTransition(
        'ToLandState',
        self.controller.states['LandState'],
        -1,
        function()
            return self.controller.triggers['LandState']
        end
    )
    self:AddTransition(
        'ToBowLandState',
        self.controller.states['BowLandState'],
        -1,
        function()
            return self.controller.triggers['BowLandState']
        end
    )
end

function BounceState:OnEnter()
    PlayerActState.OnEnter(self)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.1, 0.1, true, false, 1)
    localPlayer:LaunchCharacter(localPlayer.Up * 20, false, false)
    isLandMonitor = false
    invoke(
        function()
            isLandMonitor = true
        end,
        0.1
    )
end

function BounceState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
    if not self:FloorMonitor(0.5) and localPlayer.Velocity.y < 0.5 then
        if Data.Player.curEquipmentID == 0 then
            self.controller:CallTrigger('FallState')
        elseif ItemMgr.itemInstance[Data.Player.curEquipmentID].baseData.Type == 2 then
            self.controller:CallTrigger('BowFallState')
        end
        localPlayer.Avatar:StopBlendSpaceNode(1)
    end
    if self:FloorMonitor(0.5) and isLandMonitor then
        if Data.Player.curEquipmentID == 0 then
            self.controller:CallTrigger('LandState')
        elseif ItemMgr.itemInstance[Data.Player.curEquipmentID].baseData.Type == 2 then
            self.controller:CallTrigger('BowLandState')
            localPlayer.Avatar:StopBlendSpaceNode(1)
        end
    end
    self:Move()
end

function BounceState:OnLeave()
    PlayerActState.OnLeave(self)
end

return BounceState
