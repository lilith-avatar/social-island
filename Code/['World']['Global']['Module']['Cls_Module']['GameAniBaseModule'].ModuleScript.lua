--- @module GameAniBase 服务端房间中的动画控制类
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local GameAniBase = class('GameAniBase')

---@param _room GameRoomBase 动画控制类归属的游戏房间
function GameAniBase:initialize(_room)
    self.ins_room = _room
    self.t_config = Config.PlayerAni[_room.num_id]
    self.arr_time = {}
    ---当前正在播放的动画 key-uid value-动画名称(没有则为nil)
    self.arr_aniPlaying = {}
end

function GameAniBase:Update(_dt)
    for i, v in pairs(self.arr_time) do
        self.arr_time[i] = v - _dt
        if self.arr_time[i] <= 0 then
            self.arr_time[i] = 5
            RandPlay(self, i)
        end
    end
end

---玩家入座后
function GameAniBase:Seat(_uid)
    local player = world:GetPlayerByUserId(_uid)
    if not player then
        return
    end
    ---设置此玩家的动画混合树
    player.Avatar:SetBlendSubtree(Enum.BodyPart.UpperBody, 15)
    self.arr_time[_uid] = 6
end

---玩家离开座位
function GameAniBase:LeaveSeat(_uid)
    self.arr_time[_uid] = nil
    local player = world:GetPlayerByUserId(_uid)
    if not player then
        return
    end
    player.Avatar:SetBlendSubtree(Enum.BodyPart.FullBody, 15)
    local playingAni = self.arr_aniPlaying[_uid]
    if playingAni then
        player.Avatar:StopAnimation(playingAni, 15)
    end
end

function GameAniBase:Play(_uid, _enum)
    local player = world:GetPlayerByUserId(_uid)
    if not player then
        return
    end
    if not self.t_config then
        return
    end
    local ani = ''
    if _enum == Const.GameAniEnum.Select then
        ani = self.t_config.Select
    elseif _enum == Const.GameAniEnum.Cancel then
        ani = self.t_config.CancelSelect
    elseif _enum == Const.GameAniEnum.InHand then
        ani = self.t_config.Hand
    elseif _enum == Const.GameAniEnum.OutHand then
        ani = self.t_config.OutHand
    end
    player.Avatar:PlayAnimation(ani, 15, 1, 0, true, false, 1)
    self.arr_time[_uid] = 6
end

function GameAniBase:Destroy()
    table.cleartable(self)
end

function GameAniBase:ChangeGame(_id)
    self.t_config = Config.PlayerAni[_id]
end

---从配置的动画中随机选择一个播放
function RandPlay(self, _uid)
    if self.t_config then
        local ani = table.readRandomValueInTable(self.t_config.Rand)
        local player = world:GetPlayerByUserId(_uid)
        if not player then
            return
        end
        if ani then
            player.Avatar:PlayAnimation(ani, 15, 1, 0, true, false, 1)
            self.arr_aniPlaying[_uid] = ani
        end
    end
end

return GameAniBase