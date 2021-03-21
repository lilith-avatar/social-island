---@module SceneTime
---@copyright Lilith Games, Avatar Team
---@author XXX, XXXX
local SceneTime,this = ModuleUtil.New('SceneTime',ServerBase)

---初始化函数
function SceneTime:Init()
    this:DataInit()
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
        this:SycnSkyData()
        NetUtil.Broadcast('SycnTimeCEvent',this.clock)
        NetUtil.Fire_S('SycnTimeSEvent',this.clock)
    end
end

function SceneTime:SycnSkyDataSEventHandler(_clock)
    print(string.format('当前时间 %s 点', math.floor(_clock)))
end

return SceneTime