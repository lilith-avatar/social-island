---@module SceneTime
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
---? How To Use
---? 客户端： SycnTimeCEventHandler(number clock)
---? 服务端： SycnTimeSEventHandler(number clock)
---? 其他的读表即可
local SceneTime, this = ModuleUtil.New("SceneTime", ServerBase)
local ModeEnum = {
    Instant = 'Instant', -- 每个小时更改一次 
    RealTime = 'RealTime' -- 随时间实时更改（大概？）
}

local TimeMode = ModeEnum.Instant --!可更改

---初始化函数
function SceneTime:Init()
    this:DataInit()
    this:NodeDef()
end

function SceneTime:DataInit()
    this.timer = 0
    this.clock = 0 -- 当前游戏内时间
    this.timeSpeed = 5 -- 几秒1个小时
end

function SceneTime:NodeDef()
    this.sky = world.Sky
end

---同步天空盒与表的数据
function SceneTime:SycnSkyData()
    this[TimeMode..'SycnSkyData'](self)
end

function SceneTime:InstantSycnSkyData()
end

function SceneTime:RealTimeSycnSkyData()
end

---Update函数
function SceneTime:Update(dt)
    this.timer = this.timer + dt
    if this.timer >= this.timeSpeed then
        this.timer = 0
        this.clock = this.clock + 1
        if this.clock > 23 then
            this.clock = 0
        end
        NetUtil.Broadcast("SycnTimeCEvent", this.clock)
        NetUtil.Fire_S("SycnTimeSEvent", this.clock)
        this:SycnSkyData()
    end
end

---@param _clock number
function SceneTime:SycnSkyDataSEventHandler(_clock)
    print(string.format("当前时间 %s 点", math.floor(_clock))) --! 上线删除
end

return SceneTime
