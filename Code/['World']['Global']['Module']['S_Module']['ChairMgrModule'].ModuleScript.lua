---@module ChairMgr
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local ChairMgr, this = ModuleUtil.New("ChairMgr", ServerBase)
local dir = {
    Forward = "Forward",
    Left = "Left",
    Right = "Right",
    Back = "Back"
}

local playerChair = {}

---初始化函数
function ChairMgr:Init()
    print("[ChairMgr] Init()")
    this:DataInit()
    this:ChairCreate()
end

function ChairMgr:DataInit()
    this.chairSitter = {}
    this.ChairList = {
        Normal = {},
        QTE = {}
    }
    this.NormalShake = {
        up = function(_chair)
            this:NormalShakeUp(_chair)
        end,
        down = function(_chair)
            this:NormalShakeDown(_chair)
        end
    }
end

function ChairMgr:ChairCreate()
    for k, v in pairs(Config.ChairInfo) do
        this.ChairList[v.Type][k] =
            ChairClass:new(
            v.Type,
            k,
            v.Archetype,
            world.MiniGames.Game_10_Chair[v.Type .. "Chair"],
            v.Position,
            v.Rotation
        )
        this.ChairList[v.Type][k].model.CollisionArea.OnCollisionBegin:Connect(
            function(_hitObject)
                if _hitObject.ClassName == "PlayerInstance" and not this.chairSitter[k] and _hitObject then
                    NetUtil.Fire_C("OpenDynamicEvent", _hitObject, "Interact", 10)
                    NetUtil.Fire_C("ShowSitBtnEvent", _hitObject, v.Type, v.ID)
                end
            end
        )
        this.ChairList[v.Type][k].model.CollisionArea.OnCollisionEnd:Connect(
            function(_hitObject)
                if _hitObject.ClassName == "PlayerInstance" and _hitObject then
                    NetUtil.Fire_C("ChangeMiniGameUIEvent", _hitObject)
                    playerChair[_hitObject.UserId] = nil
                end
            end
        )
    end
end

function ChairMgr:PlayerClickSitBtnEventHandler(_uid, _type, _chairId)
    local player = world:GetPlayerByUserId(_uid)
    --让玩家坐（发事件）
    this.ChairList[_type][_chairId]:Sit(player)
    player.Position = this.ChairList[_type][_chairId].model.Seat.Position
    NetUtil.Fire_C(
        "PlayerSitEvent",
        player,
        _type,
        _chairId,
        this.ChairList[_type][_chairId].model.Position,
        this.ChairList[_type][_chairId].model.Rotation
    )
    this.chairSitter[_chairId] = player
end

function ChairMgr:Update(dt)
    for k, v in pairs(this.ChairList.Normal) do
        v:NormalUpdate(dt)
    end
    for k, v in pairs(this.ChairList.QTE) do
        v:QteUpdate(dt)
    end
end

function ChairMgr:PlayerLeaveChairEventHandler(_type, _chairId, _uid)
    if not _chairId then
        return
    end
    local player = world:GetPlayerByUserId(_uid)
    this.chairSitter[_chairId] = nil
    this.ChairList[_type][_chairId]:Stand()
    player.Position = this.ChairList[_type][_chairId].model.LeavePosition.Position
end

function ChairMgr:NormalChairSpeedUpEventHandler(_chairId)
    this.ChairList.Normal[_chairId]:ChairSpeedUp()
end

function ChairMgr:QteChairMoveEventHandler(_dir, _speed, _chairId)
    this.ChairList.QTE[_chairId]:SetSpeed(_dir, _speed)
end

return ChairMgr
