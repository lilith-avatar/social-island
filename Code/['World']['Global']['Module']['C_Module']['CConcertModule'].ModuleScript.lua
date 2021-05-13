--- 客户端演唱会模块
--- @module CConcert Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local CConcert, this = ModuleUtil.New('CConcert', ClientBase)

--- 变量声明
--歌曲速度 bpm
local tempo = 123

--每拍音符总长度
local noteLength = 4

--每小节拍数
local noteNum = 4

--16分音符时长 s
local note16thDur = 0

-- 小节事件表
local subFuncTable = {}
-- 目前执行小节
local curSubIndex = 0
-- 目前执行小节进度
local curSubProgressTime = 0

-- 是否开始
local isStart = false

---节点声明
local concertRoot

--飞碟
local ufoOBJ

--NPC
local npc1
local npc2

--舞台
local stage

--顶部射灯1组
local topSpotlight1 = {}

--顶部射灯2组
local topSpotlight2 = {}

--顶部呼吸灯1组
local topBreathingLight1 = {}

--底部射灯1组
local bottomSpotlight1 = {}

--- 初始化
function CConcert:Init()
    print('[CConcert] Init()')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function CConcert:NodeRef()
    concertRoot = localPlayer.Local.Independent.Concert
    ufoOBJ = concertRoot.UFO
    npc1 = concertRoot.DJ.Npc1
    npc2 = concertRoot.DJ.Npc2
    stage = concertRoot.Stage
    for k, v in pairs(ufoOBJ.TopSpotlight1:GetChildren()) do
        topSpotlight1[k] = v
    end
    for k, v in pairs(ufoOBJ.TopSpotlight2:GetChildren()) do
        topSpotlight2[k] = v
    end
    for k, v in pairs(stage.Cylinder.BottomSpotlight1:GetChildren()) do
        bottomSpotlight1[k] = v
    end
end

--- 数据变量初始化
function CConcert:DataInit()
    note16thDur = 60 / (tempo * 16 / noteLength)
    print('note16thDur:', note16thDur)
    for k, v in pairs(Config.Sub) do
        subFuncTable[k] = {}
    end
    --this:TestInit()
end

--- 节点事件绑定
function CConcert:EventBind()
end

--- 初始化一个小节事件组
function CConcert:RegisterSubFunc(_subIndex, _notes, _noteIndex, _func)
    local noteTime = 0
    if _noteIndex >= 2 then
        for i = 2, _noteIndex do
            noteTime = noteTime + _notes[i - 1] * note16thDur
        end
    end
    local delayTime = (_subIndex - 1) * 16 * note16thDur + noteTime
    TimeUtil.SetTimeout(_func, delayTime)
    return delayTime
end

function CConcert:TestStart()
    for subIndex, sub in pairs(Config.Sub) do
        if sub.SynthesizerNotes then
            for noteIndex, note in pairs(sub.SynthesizerNotes) do
                this:RegisterSubFunc(
                    subIndex,
                    sub.SynthesizerNotes,
                    noteIndex,
                    function()
                        this:SpotlightFlashing(bottomSpotlight1, 2 * note16thDur / sub.Strength)
                    end
                )
            end
        end
        --[[if sub.DrumNotes then
            for noteIndex, note in pairs(sub.DrumNotes) do
                this:RegisterSubFunc(
                    subIndex,
                    sub.DrumNotes,
                    noteIndex,
                    function()
                        this:SpotlightVerticalSwing(
                            bottomSpotlight1,
                            2 * note16thDur,
                            sub.Strength,
                            Enum.EaseCurve.QuarticIn,
                            Enum.EaseCurve.QuarticOut
                        )
                    end
                )
            end
        end]]
    end
    SoundUtil.Play2DSE(localPlayer.UserId, 141)
end

--- 射灯组垂直摆动
function CConcert:SpotlightVerticalSwing(_spotlights, _dur, _strength, _forwardEaseCurve, _backEaseCurve)
    for k, v in pairs(_spotlights) do
        local originRot = v.Rotation
        local forwardTweener =
            Tween:TweenProperty(
            v,
            {Rotation = originRot + EulerDegree(_strength * 4 + 10, 0, 0)},
            _dur / 2,
            _forwardEaseCurve
        )
        local backTweener = Tween:TweenProperty(v, {Rotation = originRot}, _dur / 2, _backEaseCurve)
        forwardTweener.OnComplete:Connect(
            function()
                backTweener:Play()
            end
        )
        backTweener.OnComplete:Connect(
            function()
                forwardTweener:Destroy()
                backTweener:Destroy()
            end
        )
        forwardTweener:Play()
    end
end


--- 灯闪烁
function CConcert:SpotlightFlashing(_spotlights, _dur)
    for k, v in pairs(_spotlights) do
        v:SetActive(false)
        local obk = v
        local func = function()
            obk:SetActive(true)
        end
        TimeUtil.SetTimeout(func, _dur)
    end
end

function CConcert:Update(dt)
end

return CConcert
