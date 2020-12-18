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
end

function Chair:PlayerSit(_chairId, _pos, _rot)
    this.chair = _chairId
    localPlayer.Position, localPlayer.Rotation = _pos, _rot
    localPlayer.Avatar:PlayAnimation('SitIdle',3,1,0,false,true,1)
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

return Chair
