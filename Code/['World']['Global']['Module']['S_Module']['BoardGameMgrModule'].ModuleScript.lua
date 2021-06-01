--- @module BoardGameMgr 服务端桌游总控模块
--- @copyright Lilith Games, Avatar Team
--- @author Sharif Ma
local BoardGameMgr = ModuleUtil.New('BoardGameMgr', ServerBase)

--- 初始化
function BoardGameMgr:Init()
    ---当前存在的游戏房间 key-roomUuid value-ins_room
    self.arr_rooms = {}
    ---当前的游戏房间数量
    self.num_roomNum = 0
    ---游戏桌子放置的世界文件夹
    self.folder_worldTable = world:CreateObject('FolderObject','WorldTables', world)
    ---桌子静态碰撞监测
    self.static_test = world:CreateInstance(Config.GlobalConfig.WorldTable, '预检测桌子', self.folder_worldTable, Vector3.One * 10000)
end

--- Update函数
--- @param _dt number delta time 每帧时间
function BoardGameMgr:Update(_dt, _tt)
    for i, v in pairs(self.arr_rooms) do
        v:Update(_dt)
    end
end

--- 玩家加入整个游戏,同步给玩家当前所有的游戏房间基础数据
function BoardGameMgr:OnPlayerJoinEventHandler(_player)
    SyncInfo(self, _player)
end

--- 玩家离开,通知游戏中的玩家离开桌子
function BoardGameMgr:OnPlayerLeaveEventHandler(_player)
    local room = self:GetPlayerRoom(_player)
    if room then
        room:TryLeave(_player)
    end
end

--- 玩家尝试创建一个房间
---@param _player PlayerInstance 尝试创建房间的玩家,创建成功后此玩家为房主
function BoardGameMgr:TryCreateRoomEventHandler(_player, _pos, _maxNum, _lock)
    if self:GetPlayerRoom(_player) then
        print('玩家已经在一个房间中了')
        return
    end
    if not _maxNum or _maxNum < Config.GlobalConfig.GameMinNum or _maxNum > Config.GlobalConfig.GameMaxNum then
        print('房间的最大人数不正确')
        return
    end
    if self.num_roomNum >= GlobalData.MaxRoomNum then
        print('游戏中房间数量已满,无法再次创建房间')
        return
    end
    ---进行预先的静态碰撞监测
    local hitResult = self.static_test:ContactStaticTest(_pos, EulerDegree(0, 0, 0), Vector3.One)
    for i, v in pairs(hitResult.HitObjectAll) do
        for _, room in pairs(self.arr_rooms) do
            if room.model_worldTable == v then
                ---静态碰撞监测到了当前位置存在其他的桌子,不允许创建
                print('当前位置已经有桌子了')
                return
            end
        end
    end
    local ins_room = GameRoomBase:new(self.folder_worldTable, _player, _pos, _maxNum, _lock)
    self.arr_rooms[ins_room.str_uuid] = ins_room
end

--- 房主同意某个玩家加入房间
function BoardGameMgr:AllowEnterEventHandler(_room_uuid, _owner, _requester, _index)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:AllowEnter(_owner, _requester, _index)
end

--- 玩家尝试进入一个房间
function BoardGameMgr:TryEnterRoomEventHandler(_player, _uuid)
    local room = self:GetRoomByUuid(_uuid)
    if not room then
        return
    end
    room:TryEnter(_player)
end

--- 玩家尝试离开一个房间
function BoardGameMgr:TryLeaveRoomEventHandler(_player, _uuid)
    local room = self:GetRoomByUuid(_uuid)
    if not room then
        return
    end
    room:TryLeave(_player)
end

---玩家尝试更改一个房间的游戏
function BoardGameMgr:TryChangeRoomEventHandler(_player, _uuid, _id)
    local room = self:GetRoomByUuid(_uuid)
    if not room then
        return
    end
    room:Change(_id, _player)
end

---玩家尝试更改房间上锁状态
function BoardGameMgr:TryChangeLockEventHandler(_room_uuid, _player, _lock)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:TryChangeLock(_player, _lock)
end

--- 玩家尝试更改游戏状态,若尝试更改为游戏状态,需要判定当前房间是否上锁
function BoardGameMgr:TryChangeStateEventHandler(_player, _uuid, _state, _index)
    local room = self:GetRoomByUuid(_uuid)
    if not room then
        return
    end
    room:SwitchState(_player, _state, _index)
end

--- 客户端尝试创建元素
function BoardGameMgr:TryCreateElementEventHandler(_uuid, _id, _pos)
    local room = self:GetRoomByUuid(_uuid)
    if not room then
        return
    end
    room:TryCreateElement(_id, _pos)
end

--- 客户端尝试删除元素
function BoardGameMgr:TryDestroyElementEventHandler(_room_uuid, _player, _uuid)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:TryDestroyElement(_uuid)
end

---客户端尝试创建堆叠,堆叠不可以是由别的玩家选中
---@param _type number 尝试创建那种类型对象的堆叠,不填则全部尝试
function BoardGameMgr:TryCreateStackEventHandler(_room_uuid, _player, _type)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:TryCreateStack(_player, _type)
end

---客户端尝试删除堆叠, 不删除堆叠里面的元素
function BoardGameMgr:TryDestroyStackEventHandler(_room_uuid, _uuid)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:TryDestroyStack(_uuid)
end

--- 物品选择事件
function BoardGameMgr:TrySelectUnitEventHandler(_room_uuid, _player, _uuid)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:TrySelect(_player, _uuid)
end

---物品取消选择事件
function BoardGameMgr:TryCancelElementEventHandler(_room_uuid, _player, _uuid, _pos)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:TryCancelSelect(_player, _uuid, _pos)
end

---堆叠选中事件
function BoardGameMgr:TrySelectStackEventHandler(_room_uuid, _player, _uuid, _isAll)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:TrySelectStack(_player, _uuid, _isAll)
end

---堆叠取消选中事件
function BoardGameMgr:TryCancelStackEventHandler(_room_uuid, _player, _uuid, _pos)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:TryCancelSelectStack(_player, _uuid, _pos)
end

---物品旋转和翻转
---@param _infoLst table key-uuid value-最新的角度
function BoardGameMgr:TryRotateElementEventHandler(_room_uuid, _player, _infoLst)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:TryRotateElement(_player, _infoLst)
end

---物品移动
function BoardGameMgr:TryMoveElementEventHandler(_room_uuid, _player, _infoLst)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:TryMoveElement(_player, _infoLst)
end

---堆叠移动
function BoardGameMgr:TryMoveStackEventHandler(_room_uuid, _player, _infoLst)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:TryMoveStack(_player, _infoLst)
end

---堆叠旋转
function BoardGameMgr:TryRotateStackEventHandler(_room_uuid, _uuid, _player, _infoLst)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:TryRotateStack(_player, _infoLst)
end

---堆叠中添加一个对象,目前插入对象只会在最下面
function BoardGameMgr:TryAddStackEventHandler(_room_uuid, _player, _stack_uuid, _unit_uuid)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:TryStackAdd(_player, _stack_uuid, _unit_uuid)
end

---吸附,选中的道具中指定类型的会先形成堆叠,若选中的对象已经被该玩家选中了,则执行打乱操作
function BoardGameMgr:TryAdsorbEventHandler(_room_uuid, _player, _uuid)
    local room = self:GetRoomByUuid(_room_uuid)
    if not room then
        return
    end
    room:TryAdsorb(_player, _uuid)
end

--- 根据UUID获取指定的房间
---@return GameRoomBase
function BoardGameMgr:GetRoomByUuid(_uuid)
    return self.arr_rooms[_uuid]
end

--- 获取一个玩家所在的游戏房间
---@return GameRoomBase 若在一个房间中,返回这个房间,不在则返回nil
function BoardGameMgr:GetPlayerRoom(_player)
    for i, v in pairs(self.arr_rooms) do
        if v:CheckPlayer(_player) then
            return v
        end
    end
end

---根据指定玩家获取其选中的对象
---@return table,table 选中的对象,选中的堆叠
function BoardGameMgr:GetSelected(_player)
    local units, stacks = {}, {}
    if not _player then
        return units, stacks
    end
    local room = self:GetPlayerRoom(_player)
    if not room then
        return
    end
    for i, v in pairs(room.arr_units) do
        if _player == v:GetOwner() and not v:GetStack() then
            units[i] = v
        end
    end
    for i, v in pairs(room.arr_stacks) do
        if _player == v:GetOwner() then
            stacks[i] = v
        end
    end
    return units, stacks
end

---根据指定玩家和类型获取选中的对象和堆叠
function BoardGameMgr:GetTypeSelected(_player, _type)
    local units, stacks = self:GetSelected(_player)
    for i, v in pairs(units) do
        if v:GetType() ~= _type then
            units[i] = nil
        end
    end
    for i, v in pairs(stacks) do
        if v:GetType() ~= _type then
            stacks[i] = nil
        end
    end
    return units, stacks
end

--- 玩家刚加入游戏时候,同步给玩家当前游戏中所有的房间基本信息
function SyncInfo(self, _player)
    local data = {}
    for i, v in pairs(self.arr_rooms) do
        local roomsInfo = {}
        roomsInfo.Uuid = v.str_uuid
        roomsInfo.Owner = v.player_owner
        roomsInfo.Position = v.vector3_pos
        roomsInfo.Watching = v.arr_watchingPlayers
        roomsInfo.Gaming = v.arr_gamingPlayers
        roomsInfo.Seats = {}
        for index, value in pairs(v.arr_seats) do
            roomsInfo.Seats[index] = value.Player and value.Player.UserId or -1
        end
        roomsInfo.Lock = v.bool_locked
        roomsInfo.GameId = v.num_id
        data[i] = roomsInfo
        NetUtil.Fire_C('EnterGameSyncEvent', _player, data)
    end
end

return BoardGameMgr