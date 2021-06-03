--- @module GameGui
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local GameGui = ModuleUtil.New('GameGui', ClientBase)
local self = GameGui

--- 初始化
function GameGui:Init()
    self.m_roomUuid = ''
end

--- Update函数
--- @param _dt number delta time 每帧时间
function GameGui:Update(_dt, _tt)

end

--- FixUpdate函数
--- @param _dt number delta time 每帧时间
function GameGui:FixUpdate(_dt)
    Move(_dt)
end

---有移动
function Move(_dt)
    local dir = world.CurrentCamera.Forward
    dir.y = 0
    local rightDir = Vector3(0, 1, 0):Cross(dir)
    local delta = rightDir * self.m_joyStick.Horizontal + dir * self.m_joyStick.Vertical
    if delta.Magnitude ~= 0 then
        SelectedObjs:Move(delta * 3, _dt)
    end
end

---创建无限堆叠按钮点下
function CreateUnlimited()
    LocalRooms:TryCreateUnlimited()
end

---创建元素按钮点下
function CreateElementBtn()
    LocalRooms:TryCreateUnit()
end

---尝试进入房间按钮按下
function EnterRoomClick()
    LocalRooms:TryEnterRoom(self.m_roomUuid)
end

---旋转按钮按下,暂时按一下转60度
function RotateBtnClick()
    --SelectedObjs:Rotate_Y(60)
end

---删除按钮按下
function DeleteBtnClick()

end

--- 进入游戏
function GameBtnClick()
    LocalRooms:TrySwitchState(Const.GamingStateEnum.Gaming)
end

---取消选择按钮按下
function ChangeGameBtnClick()
    local gameId = self.m_changeGameBtn.GameId.Text
    gameId = tonumber(gameId)
    LocalRooms:TryChangeRoom(gameId)
end

--- 尝试观战
function WatchBtnClick()
    LocalRooms:TrySwitchState(Const.GamingStateEnum.Watching)
end

---形成牌堆按钮按下
function CreatStackBtnClick()
    LocalRooms:TryCreateStack()
end

---创建桌子按钮
function CreateRoom()
    LocalRooms:TryCreateRoom()
end

---离开桌子
function LeaveRoom()
    LocalRooms:TryLeaveRoom()
end

---上锁
function GameGui:LockBtnClick()
    LocalRooms:TryChangeLock(true)
end

---解锁
function GameGui:UnLockBtnClick()
    LocalRooms:TryChangeLock(false)
end

function GameGui:ChangeRoom(_id)
    LocalRooms:TryChangeRoom(_id)
end

--- 房间中玩家离开事件
---@param _room_uuid string 离开的房间UUID
---@param _uid string 离开的玩家UID
function GameGui:LeaveRoomEventHandler(_room_uuid, _uid)
    local room = LocalRooms:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
end

---玩家进入一个房间事件,进入房间后自动弹出选择座位界面
function GameGui:EnterRoomEventHandler(_uuid, _player)
	local room = LocalRooms:GetRoomByUuid(_uuid)
	if not room then
		return
	end
end

return GameGui