---@module ChairMgr
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local ChairMgr, this = ModuleUtil.New("ChairMgr", ServerBase)

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
                if _hitObject.ClassName == "PlayerInstance" and not this.chairSitter[k] then
                    --让玩家坐（发事件）
                    this.ChairList[v.Type][k].model.CollisionArea:SetActive(false)
                    this.ChairList[v.Type][k].model.Rotation = v.Rotation
                    _hitObject.Position = this.ChairList[v.Type][k].model.Seat.Position
                    NetUtil.Fire_C("PlayerSitEvent", _hitObject, v.Type, v.ID, v.Position, v.Rotation)
                    this.chairSitter[k] = _hitObject
                end
            end
        )
    end
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
    player.Position = this.ChairList[_type][_chairId].model.LeavePosition.Position
end

function ChairMgr:QteChairMoveEventHandler(_dir, _speed)
    --this.ChairList.QTE
end

return ChairMgr
