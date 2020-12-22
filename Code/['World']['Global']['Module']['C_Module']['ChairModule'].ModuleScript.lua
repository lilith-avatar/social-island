---@module Chair
---@copyright Lilith Games, Avatar Team
---@author XXX, XXXX
local Chair, this = ModuleUtil.New("Chair", ClientBase)
local Dir = {"forward", "left", "back", "right"}

---初始化函数
function Chair:Init()
    Chair:DataInit()
end

function Chair:DataInit()
    this.chairFunc = {
        Normal = function(_chairId, _pos, _rot)
            this:NormalSit(_chairId, _pos, _rot)
        end,
        QTE = function(_chairId, _pos, _rot)
            this:QteSit(_chairId, _pos, _rot)
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
    this.chairType = nil
    this.qteTotalTime = 0
    this.keepTime = 0
    this.timer = 0
    this.startUpdate = false
    this.qteDuration = 0
    this.qteTimer = 0
end

function Chair:PlayerSit(_chairId, _pos, _rot)
    this.chair = _chairId
    localPlayer.Position, localPlayer.Rotation = _pos, _rot
    localPlayer.Avatar:PlayAnimation("SitIdle", 3, 1, 0, true, true, 1)
end

function Chair:PlayerLeaveSit()
    localPlayer.Avatar:StopAnimation("SitIdle", 3)
    this.startUpdate = false
end

function Chair:NormalSit(_chairId, _pos, _rot)
    this:PlayerSit(_chairId, _pos, _rot)
    this.chairType = "normal"
    this.startUpdate = true
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

function Chair:QteSit(_chairId, _pos, _rot)
    this:PlayerSit(_chairId, _pos, _rot)
    this.chairType = "QTE"
    this.startUpdate = true
    --ui控制
    ChairUIMgr:EnterQte()
end

function Chair:Update(_dt)
    if this.startUpdate then
        this.timer = this.timer + _dt
        if this.timer >= 1 then
            this.qteTotalTime = this.qteTotalTime + 1
            this.qteTimer = this.qteTimer + 1
            this.keepTime = this:ChangeKeepTimeByTotalTime(this.qteTotalTime).ButtonKeepTime
            this.qteDuration = this:ChangeKeepTimeByTotalTime(this.qteTotalTime).QteDuration
            ChairUIMgr:ShowQteButton(this.keepTime)
            if this.qteTimer >= this.qteDuration then
                --跟移动方向一样
                ChairUIMgr:GetQteForward(
                    Dir[math.random(1, 4)],
                    this:ChangeKeepTimeByTotalTime(this.qteTotalTime).BullSpeed
                )
                this.qteTimer = 0
            end
            this.timer = 0
        end
    end
end

function Chair:ChangeKeepTimeByTotalTime(_totalTime)
    for i = #Config.RideConfig, 1, -1 do
        if _totalTime >= Config.RideConfig[i].Time then
            return Config.RideConfig[i]
        end
    end
end

return Chair
