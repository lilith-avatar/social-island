---@module ChairMgr
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local ChairMgr, this = ModuleUtil.New("ChairMgr", ServerBase)
local dir = {
    forward = "Forward",
    left = "Left",
    right = "Right",
    back = "Back"
}

---初始化函数
function ChairMgr:Init()
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
        this.ChairList[v.Type][k] = {
            model = world:CreateInstance(
                v.Archetype,
                k,
                world.MiniGames.Game_10_Chair[v.Type .. "Chair"],
                v.Position,
                v.Rotation
            ),
            isSeat = false
        }
        this.ChairList[v.Type][k].model.CollisionArea.OnCollisionBegin:Connect(
            function(_hitObject)
                if _hitObject.ClassName == "PlayerInstance" and not this.chairSitter[k] and _hitObject then
                    NetUtil.Fire_C("ShowSitBtnEvent", _hitObject, v.Type, v.ID)
                end
            end
        )
        this.ChairList[v.Type][k].model.CollisionArea.OnCollisionEnd:Connect(
            function(_hitObject)
                if _hitObject.ClassName == "PlayerInstance" and not this.chairSitter[k] and _hitObject then
                    NetUtil.Fire_C("HideSitBtnEvent", _hitObject)
                end
            end
        )
    end
end

function ChairMgr:PlayerClickSitBtnEventHandler(_uid, _type, _chairId)
    local player = world:GetPlayerByUserId(_uid)
    --让玩家坐（发事件）
    this.ChairList[_type][_chairId].model.CollisionArea:SetActive(false)
    this.ChairList[_type][_chairId].model.Rotation = Config.ChairInfo[_chairId].Rotation
    this.ChairList[_type][_chairId].model.Seat:SetActive(true)
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

function ChairMgr:NormalShakeEventHandler(_chairId, _upOrDown)
    this.NormalShake[_upOrDown](this.ChairList.Normal[_chairId].model)
end

function ChairMgr:NormalShakeUp(_chair)
    local tweener = Tween:TweenProperty(_chair, {Rotation = EulerDegree(-20, 0, 0)}, 0.5, 1)
    tweener:Play()
    tweener:WaitForComplete()
end

function ChairMgr:NormalShakeDown(_chair)
    local tweener = Tween:TweenProperty(_chair, {Rotation = EulerDegree(14, 0, 0)}, 0.5, 1)
    tweener:Play()
    tweener:WaitForComplete()
end

function ChairMgr:PlayerLeaveChairEventHandler(_type, _chairId, _uid)
    if not _chairId then
        return
    end
    local player = world:GetPlayerByUserId(_uid)
    this.chairSitter[_chairId] = nil
    this.ChairList[_type][_chairId].model.CollisionArea:SetActive(true)
    this.ChairList[_type][_chairId].model.Seat:SetActive(false)
    player.Position = this.ChairList[_type][_chairId].model.LeavePosition.Position
    this.ChairList[_type][_chairId].model.LinearVelocity = Vector3.Zero
end

function ChairMgr:QteChairMoveEventHandler(_dir, _speed, _chairId)
    local chair = this.ChairList.QTE[_chairId].model
    chair.LinearVelocity = chair[dir[_dir]] * _speed
end

return ChairMgr
