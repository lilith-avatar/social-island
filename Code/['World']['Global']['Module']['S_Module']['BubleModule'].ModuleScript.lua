---@module Buble
---@copyright Lilith Games, Avatar Team
---@author XXX, XXXX
local Buble, this = ModuleUtil.New("Buble", ServerBase)

---初始化函数
function Buble:Init()
    this:DataInit()
    this:EventBind()
end

function Buble:DataInit()
    this.bubleGun = world.BubleGun
    this.bublePlayer = {}
end

function Buble:EventBind()
    for k, v in pairs(this.bubleGun:GetChildren()) do
        v.OnCollisionBegin:Connect(
            function(_hitObject)
                if _hitObject and _hitObject.ClassName == "PlayerInstance" and not this.bublePlayer[_hitObject.UserId] then
                    NetUtil.Fire_C("OpenDynamicEvent", _hitObject, "Interact", 24)
                end
            end
        )
        v.OnCollisionEnd:Connect(
            function(_hitObject)
                if _hitObject and _hitObject.ClassName == "PlayerInstance" and not this.bublePlayer[_hitObject.UserId] then
                    NetUtil.Fire_C("ChangeMiniGameUIEvent", _hitObject)
                end
            end
        )
    end
end

---Update函数
function Buble:Update()
end

function Buble:InteractSEventHandler(_player, _gameId)
    if _gameId == 24 then
        this.bublePlayer[_player.UserId] = true
    end
end

function Buble:LeaveInteractSEventHandler(_player,_gameId)
    if _gameId == 24 then
        this.bublePlayer[_player.UserId] = nil
    end
end

return Buble
