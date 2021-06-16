local TakeOutItemState = class('TakeOutItemState', PlayerActState)

function TakeOutItemState:InitData()
    self:AddAnyState(
        'ToTakeOutItemState',
        -1,
        function()
            return self.controller.triggers['TakeOutItemState']
        end
    )
end

function TakeOutItemState:OnEnter()
    PlayerActState.OnEnter(self)
    local animName = ItemMgr.itemInstance[Data.Player.curEquipmentID].baseData.TakeOutAniName
    local animDur = ItemMgr.itemInstance[Data.Player.curEquipmentID].baseData.TakeOutTime
    local nextState = ItemMgr.itemInstance[Data.Player.curEquipmentID].typeConfig.FsmMode

    PlayerAnimMgr:CreateSingleClipNode(animName, 1, self.stateName, 1)
    PlayerAnimMgr:Play(self.stateName, 0, 1, 0.2, 0.2, true, false, 1)
    SoundUtil.Play3DSE(localPlayer.Position, ItemMgr.itemInstance[Data.Player.curEquipmentID].baseData.TakeOutSoundID)

    self:AddTransition('ToNextState', self.controller.states[nextState], animDur)
end

function TakeOutItemState:OnUpdate(dt)
    PlayerActState.OnUpdate(self, dt)
end
function TakeOutItemState:OnLeave()
    PlayerActState.OnLeave(self)
    self.transitions = {}
end

return TakeOutItemState
