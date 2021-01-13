---  Buff模块：
-- @module  BuffMgr
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module BuffMgr

local BuffMgr, this = ModuleUtil.New("BuffMgr", ClientBase)

local BuffDataList = {}

local defPlayerData = {
    AvatarHeadSize_Overlay = 1,
    AvatarWidth_Overlay = 1,
    AvatarHeight_Overlay = 1,
    HeadEffect_Overlay = {},
    BodyEffect_Overlay = {},
    FootEffect_Overlay = {},
    WalkSpeed_Overlay = 6,
    JumpUpVelocity_Overlay = 8,
    GravityScale_Overlay = 2
}

function BuffMgr:Init()
    print("BuffMgr:Init")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function BuffMgr:NodeRef()
end

--数据变量声明
function BuffMgr:DataInit()
    this:GetBuffEventHandler(1, 10)
end

--节点事件绑定
function BuffMgr:EventBind()
end

--获得Buff
function BuffMgr:GetBuffEventHandler(_buffID, _dur)
    if BuffDataList[_buffID] then
        BuffDataList[_buffID].curTime = _dur
    else
        BuffDataList[_buffID] = {
            curTime = _dur
        }
        this:RemoveCoverBuff(Config.Buff[_buffID].BuffCoverIDList)
    end
    local coverPlayerData = {}
    for k, v in pairs(Config.Buff[_buffID]) do
        if string.find(tostring(k), "_Cover") then ---覆盖
            coverPlayerData[k] = v
        end
    end
    --发送覆盖数据和叠加数据
    print(table.dump(coverPlayerData))
    print(table.dump(this:GetAllBuffData()))
end

--移除Buff
function BuffMgr:RemoveBuffEventHandler(_buffID)
    if BuffDataList[_buffID] then
        BuffDataList[_buffID] = nil
    end
    this:GetAllBuffData()
    --发送叠加数据
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
    local overlayPlayerData = {}
    for buffID, buffData in pairs(BuffDataList) do
        for k, v in pairs(Config.Buff[buffID]) do
            if string.find(tostring(k), "_Overlay") then ---叠加
                if overlayPlayerData[k] then ---已存在数据
                    if type(overlayPlayerData[k]) == "table" then ---表类型
                        table.insert(overlayPlayerData[k], v)
                    elseif type(overlayPlayerData[k]) == "number" then ---数值类型
                        overlayPlayerData[k] = overlayPlayerData[k] * v
                    end
                else ---不存在数据
                    if type(defPlayerData[k]) == "table" then ---表类型
                        overlayPlayerData[k] = {}
                        table.insert(overlayPlayerData[k], v)
                        --print(table.dump(overlayPlayerData[k]))
                    elseif type(defPlayerData[k]) == "number" then ---数值类型
                        overlayPlayerData[k] = defPlayerData[k]
                    end
                end
            end
        end
    end
    return overlayPlayerData
end

--按时间消退Buff
function BuffMgr:FadeBuffByTime(dt)
    for k, v in pairs(BuffDataList) do
        if v.curTime > 0 then
            v.curTime = v.curTime - dt
        else
            BuffDataList[k] = nil
        end
    end
end

function BuffMgr:Update(dt, tt)
    this:FadeBuffByTime(dt)
end

return BuffMgr
