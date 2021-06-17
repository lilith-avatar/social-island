---  Buff模块：
-- @module  BuffMgr
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module BuffMgr

local BuffMgr, this = ModuleUtil.New('BuffMgr', ClientBase)

local BuffDataList = {}

local buffDataTable = {}
local defPlayerData = {
    AvatarHeadSize = 1,
    AvatarWidth = 1,
    AvatarHeight = 1,
    HeadEffect = {},
    BodyEffect = {},
    HandEffect = {},
    FootEffect = {},
    EntiretyEffect = {},
    MaxWalkSpeed = 12,
    JumpUpVelocity = 8,
    CharacterGravityScale = 2,
    SkinID = 0,
    EnableEquipable = true
}

function BuffMgr:Init()
    --print('BuffMgr:Init')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function BuffMgr:NodeRef()
end

--数据变量声明
function BuffMgr:DataInit()
    --print(table.dump(Data.Player.attr))
    --[[invoke(
        function()
            this:GetBuffEventHandler(1, 10)
        end,
        6
    )]]
end

--节点事件绑定
function BuffMgr:EventBind()
end

--获得Buff
function BuffMgr:GetBuffEventHandler(_buffID, _dur)
    if _buffID ~= 0 then
        if Config.Buff[_buffID].NeedSound == true then
            SoundUtil.Play2DSE(localPlayer.UserId, 109)
        end

        if BuffDataList[_buffID] then
            BuffDataList[_buffID].curTime = _dur
        else
            BuffDataList[_buffID] = {
                curTime = _dur
            }

            this:RemoveCoverBuff(Config.Buff[_buffID].BuffCoverIDList)
        end
        buffDataTable = table.deepcopy(defPlayerData)
        for k, v in pairs(Config.Buff[_buffID]) do
            if string.find(tostring(k), '_Cover') and defPlayerData[string.gsub(k, '_Cover', '')] then ---覆盖
                buffDataTable[string.gsub(k, '_Cover', '')] = v
            ----print(string.gsub(k, "_Cover", ""))
            ----print(buffDataTable[string.gsub(k, "_Cover", "")])
            end
        end
        this:GetAllBuffData()
        PlayerCtrl:PlayerAttrUpdate()
    else
        return
    end
end

--移除Buff
function BuffMgr:RemoveBuffEventHandler(_buffID)
    if BuffDataList[_buffID] then
        BuffDataList[_buffID] = nil
        buffDataTable = table.deepcopy(defPlayerData)
        this:GetAllBuffData()
        PlayerCtrl:PlayerAttrUpdate()
    end
end

--清除所有Buff
function BuffMgr:BuffClear()
    BuffDataList = {}
    buffDataTable = table.deepcopy(defPlayerData)
    this:GetAllBuffData()
    PlayerCtrl:PlayerAttrUpdate()
end

--移除互斥Buff
function BuffMgr:RemoveCoverBuff(_buffIDList)
    for k, v in pairs(_buffIDList) do
        if BuffDataList[v] then
            BuffDataList[v] = nil
        end
    end
end

--获得所有Buff的效果数据
function BuffMgr:GetAllBuffData()
    for buffID, buffData in pairs(BuffDataList) do
        for k, v in pairs(Config.Buff[buffID]) do
            if string.find(tostring(k), '_Overlay') and defPlayerData[string.gsub(k, '_Overlay', '')] then ---叠加
                if type(Data.Player.attr[string.gsub(k, '_Overlay', '')]) == 'table' then ---表类型
                    ----print(v, buffID)
                    if v ~= '' then
                        table.insert(buffDataTable[string.gsub(k, '_Overlay', '')], v)
                    end
                elseif type(Data.Player.attr[string.gsub(k, '_Overlay', '')]) == 'number' then ---数值类型
                    buffDataTable[string.gsub(k, '_Overlay', '')] = buffDataTable[string.gsub(k, '_Overlay', '')] * v
                end
            end
        end
    end
    for k, v in pairs(buffDataTable) do
        Data.Player.attr[k] = v
    end
    print(table.dump(buffDataTable))
end

--按时间消退Buff
function BuffMgr:FadeBuffByTime(dt)
    for k, v in pairs(BuffDataList) do
        if v.curTime > 0 then
            v.curTime = v.curTime - dt
        elseif v.curTime > -1 then
            this:RemoveBuffEventHandler(k)
        --BuffDataList[k] = nil
        end
    end
end

function BuffMgr:Update(dt, tt)
    this:FadeBuffByTime(dt)
end

return BuffMgr
