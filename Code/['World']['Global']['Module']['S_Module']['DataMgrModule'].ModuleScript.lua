--- 服务器端玩家数据
--- @module Players Data Manager
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local DataMgr, this = ModuleUtil.New('DataMgr', ServerBase)

-- 玩家数据KV：uid -> {}
local allPlayersData = {}

-- 玩家数据定时保存时间间隔（秒）
local AUTO_SAVE_TIME = 60
-- 重新读取游戏数据时间间隔（秒）
local RELOAD_TIME = 1

-- Cache
local DataStore = DataStore

--! 初始化

function DataMgr:Init()
    print('[DataMgr] Init()')
    TimeUtil.SetInterval(SaveAllGameDataAsync, AUTO_SAVE_TIME)
end

--- 得到默认的玩家数据
function GetDefaultPlayerData(_uid)
    --TODO: 添加默认的玩家数据格式
    print('[DataMgr] 使用默认玩家数据 uid =', _uid)
    return {
        -- 玩家User Id
        uid = _uid,
        -- 玩家属性
        attribute = {},
        -- 背包
        bag = {},
        -- 小游戏相关
        mini = {},
        -- 统计数据
        stats = {}
    }
end

--! 数据同步

--- 将玩家数据同步到客户端
--- @param _userId string 玩家ID
function SyncDataToClient(_uid)
    local player = world:GetPlayerByUserId(_uid)
    local data = allPlayersData[_uid]
    assert(player, string.format('[DataMgr] 玩家不存在, uid = %s', _uid))
    assert(data, string.format('[DataMgr] 玩家数据不存在, uid = %s', _uid))
    if player and data then
        NetUtil.Fire_C('SyncDataEvent', player, data)
        return true
    end
    return false
end

--! 数据 getter setter

--- 获取指定玩家ID的数据的指定键值
--- 不输入键名则返回整个数据表，不存在则返回nil
--- @param _uid string 玩家ID
--- @param _key string 键名
function GetDataByUserId(_uid, _key)
    local data = allPlayersData[_uid]
    return (string.isnilorempty(_key)) and (data) or (data and data[_key])
end

--- 设定指定玩家ID的全部数据
--- @param _uid string 玩家ID
--- @param _value 修改的目标值
function SetAllDataByUserId(_uid, _value)
    local data = allPlayersData[_uid]
    assert(not string.isnilorempty(_uid), '[DataMgr] uid为空')
    assert(data and _value, string.format('[DataMgr] 玩家数据不存在 uid = %s', _uid))
    assert(data.uid == _uid, string.format('[DataMgr] uid校验不通过 uid = %s', _uid))
    table.merge(data, _value)
end

--- 设定指定玩家ID的数据的指定键值
--- @param _uid string 玩家ID
--- @param _key string 键名
--- @param _value 修改的目标值
function SetKvDataByUserId(_uid, _key, _value)
    local data = allPlayersData[_uid]
    assert(not string.isnilorempty(_uid), '[DataMgr] uid为空')
    assert(data and _value, string.format('[DataMgr] 玩家数据不存在, uid = %s', _uid))
    assert(data.uid == _uid, string.format('[DataMgr] uid校验不通过, uid = %s', _uid))
    assert(data[_key], string.format('[DataMgr] 玩家数据不存在key, uid = %s, key = %s', _uid, _key))
    if type(data[_key]) == 'table' then
        table.merge(data[_key], _value)
    else
        data[_key] = _value
    end
end

--! 数据长期存储

--- 下载玩家的游戏数据
--- @param _uid string 玩家ID
function LoadGameDataAsync(_uid)
    local sheet = DataStore:GetSheet('PlayerData')
    sheet:GetValue(
        _uid,
        function(_val, _msg)
            LoadGameDataAsyncCb(_val, _msg, _uid)
        end
    )
end

--- 下载玩家的游戏数据回调
--- @param _val table 数据
--- @param _msg int 消息码
--- @param _uid string 玩家ID
function LoadGameDataAsyncCb(_val, _msg, _uid)
    local player = world:GetPlayerByUserId(_uid)
    assert(player, string.format('[DataMgr] 玩家不存在, uid = %s', _uid))
    if _msg == 0 or _msg == 101 then
        print('[DataMgr] 获取玩家数据成功', player.Name)
        --若以前的数据为空，则让数据等于默认值
        local data = _val or GetDefaultPlayerData(_uid)
        assert(data.uid == _uid, string.format('[DataMgr] uid校验不通过, uid = %s', _uid))
        --若已在此服务器的数据总表存在，则更新数据
        if GetDataByUserId(_uid) then
            --若未在此服务器的数据总表存在，则加入总表
            SetAllDataByUserId(_uid, data)
        else
            allPlayersData[_uid] = data
        end

        --同步玩家数据到客户端
        SyncDataToClient(_uid)

        --成功下载玩家数据后，通知客户端可以正式开始游戏
        NetUtil.Fire_C('EndLoadDataEvent', player)
    else
        print(
            string.format(
                '[DataMgr] 获取玩家数据失败，%s秒后重试, uid = %s, player = %s, msg = %s',
                RELOAD_TIME,
                _uid,
                player.Name,
                _msg
            )
        )
        --若失败，则1秒后重新再读取一次
        invoke(
            function()
                LoadGameDataAsync(_uid)
            end,
            RELOAD_TIME
        )
    end
end

--- 上传玩家的游戏数据
--- @param _userId string 玩家ID
function SaveGameDataAsync(_uid)
    local sheet = DataStore:GetSheet('PlayerData')
    local newData = GetDataByUserId(_uid)

    assert(newData, string.format('[DataMgr] 玩家数据不存在, uid = %s', _uid))
    assert(newData.uid == _uid, string.format('[DataMgr] uid校验不通过, uid = %s', _uid))
    sheet:SetValue(
        _uid,
        newData,
        function(_val, _msg)
            SaveGameDataAsyncCb(_val, _msg, _uid)
        end
    )
end

--- 上传玩家的游戏数据回调
--- @param _val table 数据
--- @param _msg int 消息码
--- @param _uid string 玩家ID
function SaveGameDataAsyncCb(_val, _msg, _uid)
    if _msg == 0 then
        print('[DataMgr] 保存玩家数据成功', _uid)
    else
        print(string.format('[DataMgr] 保存玩家数据失败，%s秒后重试, uid = %s, msg = %s', RELOAD_TIME, _uid, _msg))
        --若失败，则1秒后重新再读取一次
        invoke(
            function()
                SaveGameDataAsync(_uid)
            end,
            RELOAD_TIME
        )
    end
end

--- 存储全部玩家数据
function SaveAllGameDataAsync()
    for uid, data in pairs(allPlayersData) do
        if data then
            SaveGameDataAsync(uid)
        end
    end
end

--! Event handlers

-- 玩家加入事件
function DataMgr:OnPlayerJoinEventHandler(_player)
    local uid = _player.UserId
    print(string.format('[DataMgr] OnPlayerJoinEvent 玩家加入 name = %s, uid = %s', _player.Name, uid))
    LoadGameDataAsync(uid)
end

-- 玩家离开事件
function DataMgr:OnPlayerLeaveEventHandler(_player)
    local uid = _player.UserId
    print(string.format('[DataMgr] OnPlayerLeaveEvent 玩家离开 name = %s, uid = %s', _player.Name, uid))
    SaveGameDataAsync(uid)
end

return DataMgr
