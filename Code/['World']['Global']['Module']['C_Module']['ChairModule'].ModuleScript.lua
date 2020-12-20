---@module Chair
---@copyright Lilith Games, Avatar Team
---@author XXX, XXXX
local Chair, this = ModuleUtil.New("Chair", ClientBase)

---初始化函数
function Chair:Init()
    Chair:DataInit()
end

function Chair:DataInit()
    this.chairFunc = {
        Normal = function(_chairId, _pos, _rot)
            this:NormalSit(_chairId, _pos, _rot)
        end,
        QTE = function(_chairId,_pos,_rot)
            this:QteSit(_chairId,_pos,_rot)
        end
    }
    this.chairShake = {
        Normal = {
            up = function()
                this:NormalShakeUp()
            end,
            down = function()
                this:NormalShakeDown()
            end
        }
    }
    this.chair = nil
    this.qteTotalTime = 0
    this.timer = 0
    this.startUpdate = false
end

function Chair:PlayerSit(_chairId, _pos, _rot)
    this.chair = _chairId
    localPlayer.Position, localPlayer.Rotation = _pos, _rot
    localPlayer.Avatar:PlayAnimation('SitIdle',3,1,0,true,true,1)
end

function Chair:PlayerLeaveSit()
    localPlayer.Avatar:StopAnimation('SitIdle',3)
end

function Chair:NormalSit(_chairId, _pos, _rot)
    this:PlayerSit(_chairId, _pos, _rot)
    --ui控制
    ChairUIMgr:EnterNormal()
end

function Chair:DestroyChair()
    this.chair.model:Destroy()
    --向服务器发送事件
end

function Chair:PlayerSitEventHandler(_type, _chairId, _pos, _rot)
    this.chairFunc[_type](_chairId, _pos, _rot)
end

function Chair:QteSit(_chairId,_pos,_rot)
    this:PlayerSit(_chairId, _pos, _rot)
    --ui控制
    ChairUIMgr:EnterQte()
end

function Chair:Update(_dt)
    if this.startUpdate then
        this.timer = this.timer + _dt
        if this.timer >= 1 then
            this.qteTotalTime = this.qteTotalTime + 1
        end
    end
end

return Chair
