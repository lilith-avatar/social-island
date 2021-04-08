---@module SceneTime
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
---? How To Use
---? 客户端： SycnTimeCEventHandler(number clock)
---? 服务端： SycnTimeSEventHandler(number clock)
---? 其他的读表即可
local SceneTime, this = ModuleUtil.New("SceneTime", ServerBase)
local ModeEnum = {
    Instant = "Instant", -- 每个小时更改一次
    RealTime = "RealTime" -- 随时间实时更改（大概？）
}

local TimeMode = ModeEnum.RealTime --!可更改

---初始化函数
function SceneTime:Init()
    this:DataInit()
    this:NodeDef()
    invoke(
        function()
            this.startUpdate = true
        end,
        5
    )
end

function SceneTime:DataInit()
    this.timer = 0
    this.clock = 13 -- 当前游戏内时间
    this.timeSpeed = 12.5 -- 几秒1个小时
    this.tweener = nil
    this.startUpdate = false
end

function SceneTime:NodeDef()
    this.sky = world.Sky
end

---同步天空盒与表的数据
function SceneTime:SycnSkyData()
    this[TimeMode .. "SycnSkyData"](self)
end

function SceneTime:InstantSycnSkyData()
    local data, configData = {}, Config.TimeSkySetting[this.clock]
    if not configData then
        return
    end
    this.sky.ShowSun = configData.ShowSun
    this.sky.Style = configData.Style
    data = {
        Brightness = configData.Brightness,
        Latitude = configData.Latitude,
        SunAngular = configData.SunAngular,
        ShadowDistance = configData.ShadowDistance,
        ShadowIntensity = configData.ShadowIntensity,
        Ambient = configData.Ambient,
        SunColor = configData.SunColor,
        EquatorColor = configData.EquatorColor,
        GroundColor = configData.GroundColor,
        SunIntensity = configData.SunIntensity,
        SkyboxIntensity = configData.SkyboxIntensity,
        FogColor = configData.FogColor,
        FogStart = configData.FogStart,
        FogEnd = configData.FogEnd,
        FogColor = configData.FogColor,
        FogHeightFadeStart = configData.FogHeightFadeStart,
        FogHeightFadeEnd = configData.FogHeightFadeEnd
    }
    this.tweener = Tween:TweenProperty(this.sky, data, 3, 1)
    this.tweener:Play()
end

function SceneTime:RealTimeSycnSkyData()
    local data, configData = {}, this:GetNextClockData()
    if not configData then
        return
    end
    if Config.TimeSkySetting[this.clock].ChangeIntensity then
        this.sky.SkyboxIntensity = Config.TimeSkySetting[this.clock].ChangeIntensity
    end
    this.sky.Up = ResourceManager.GetTexture(Config.TimeSkySetting[this.clock].SkyUp)
    this.sky.Front = ResourceManager.GetTexture(Config.TimeSkySetting[this.clock].SkyFront)
    this.sky.Back = ResourceManager.GetTexture(Config.TimeSkySetting[this.clock].SkyBack)
    this.sky.Down = ResourceManager.GetTexture(Config.TimeSkySetting[this.clock].SkyDown)
    this.sky.Right = ResourceManager.GetTexture(Config.TimeSkySetting[this.clock].SkyRight)
    this.sky.Left = ResourceManager.GetTexture(Config.TimeSkySetting[this.clock].SkyLeft)
    this.sky.ShowSun = Config.TimeSkySetting[this.clock].ShowSun
    this.sky.Style = Config.TimeSkySetting[this.clock].Style
    data = {
        Brightness = configData.Brightness,
        Latitude = configData.Latitude,
        SunAngular = configData.SunAngular,
        ShadowDistance = configData.ShadowDistance,
        ShadowIntensity = configData.ShadowIntensity,
        Ambient = configData.Ambient,
        SunColor = configData.SunColor,
        EquatorColor = configData.EquatorColor,
        GroundColor = configData.GroundColor,
        SunIntensity = configData.SunIntensity,
        SkyboxIntensity = configData.SkyboxIntensity,
        FogColor = configData.FogColor,
        FogStart = configData.FogStart,
        FogEnd = configData.FogEnd,
        FogColor = configData.FogColor,
        FogHeightFadeStart = configData.FogHeightFadeStart,
        FogHeightFadeEnd = configData.FogHeightFadeEnd
    }
    this.tweener = Tween:TweenProperty(this.sky, data, this.timeSpeed * math.abs(configData.ClockTime - this.clock), 1)
    this.tweener:Play()
end

function SceneTime:GetNextClockData()
    local tmpTable = {}

    for k, v in pairs(Config.TimeSkySetting) do
        table.insert(tmpTable, v)
    end
    table.sort(
        tmpTable,
        function(t1, t2)
            return t1.ClockTime < t2.ClockTime
        end
    )
    for k, v in pairs(tmpTable) do
        if this.clock == v.ClockTime then
			--print(tmpTable[k + 1].ClockTime or Config.TimeSkySetting[6].ClockTime)
            return tmpTable[k + 1] or tmpTable[1]
        end
    end
	
    return nil
end

---Update函数
function SceneTime:Update(dt)
    if not this.startUpdate then
        return
    end
    this.timer = this.timer + dt
    if this.timer >= this.timeSpeed then
        this.timer = 0
        this.clock = this.clock + 1
        if this.clock > 23 then
            this.clock = 0
        end
        if Config.TimeSkySetting[this.clock] then
            if this.clock == 10 then
                NetUtil.Broadcast("ShowNoticeInfoEvent", "新的一天开始了", 20, Vector3(-61.4808, -10.0305, -44.5828))
            elseif this.clock == 18 then
                NetUtil.Broadcast("ShowNoticeInfoEvent", "黄昏了，该回家了", 20, Vector3(-61.4808, -10.0305, -44.5828))
            elseif this.clock == 20 then
                NetUtil.Broadcast("ShowNoticeInfoEvent", "黑夜了，该去帐篷睡觉了", 20, Vector3(-61.4808, -10.0305, -44.5828))
            end
        end
        NetUtil.Broadcast("SycnTimeCEvent", this.clock)
        NetUtil.Fire_S("SycnTimeSEvent", this.clock)
        this:SycnSkyData()
    end
    this.sky.ClockTime = this.clock + this.timer / this.timeSpeed
end

---@param _clock number
function SceneTime:SycnTimeSEventHandler(_clock)
    if math.floor(_clock) == 19 then
        NetUtil.Broadcast("PlayEffectEvent", 100, Vector3(-106.406, -13.9315, 39.7601))
        world.Light:SetActive(true)
        for k, v in pairs(world.HangLight:GetChildren()) do
            for k1, v1 in pairs(v:GetChildren()) do
                v1.Color = Color(math.random(0, 255), math.random(0, 255), math.random(0, 100), 255)
            end
        end
    elseif math.floor(_clock) == 9 then
        world.Light:SetActive(false)
        for k, v in pairs(world.HangLight:GetChildren()) do
            for k1, v1 in pairs(v:GetChildren()) do
                v1.Color = Color(70, 70, 70, 255)
            end
        end
    end
    print(string.format("[SceneTime] 当前时间 %s 点", math.floor(_clock))) --! 上线删除
end

function SceneTime:OnPlayerJoinEventHandler(_player)
    NetUtil.Fire_C("SycnTimeCEvent", _player, this.clock)
end

return SceneTime
