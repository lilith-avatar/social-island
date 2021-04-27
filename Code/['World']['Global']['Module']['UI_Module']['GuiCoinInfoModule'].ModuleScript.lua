---  金币信息UI模块：
-- @module  GuiCoinInfo
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module GuiCoinInfo
local GuiCoinInfo, this = ModuleUtil.New('GuiCoinInfo', ClientBase)

--gui
local coinInfoGUI
local rollInfoPanel = {}
local curCoinInfoPanel

--Effect
local coinEffect = {}
local blastEffect

--特效刷新间隔
local EFFECT_INTERVAL = 0.5

--特效最大上限
local EFFECT_EMI_MAX = 20

--特效梯度系数
local EFFECT_GRADIENT = 3

--待显示的金币数量
local remainingCoinNum = 0

function GuiCoinInfo:Init()
    print('GuiCoinInfo:Init')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function GuiCoinInfo:NodeRef()
    --[[
    coinInfoGUI = localPlayer.Local.SpecialBottomUI.GetCoinInfoGUI
    for i = 1, 6 do
        rollInfoPanel[i] = coinInfoGUI["Panel" .. i]
    end
    curCoinInfoPanel = rollInfoPanel[1]
    ]]
    coinEffect['1'] = localPlayer.Effect.GetCoinEffect.Coin1
    coinEffect['10'] = localPlayer.Effect.GetCoinEffect.Coin10
    coinEffect['100'] = localPlayer.Effect.GetCoinEffect.Coin100
    blastEffect = localPlayer.Effect.GetCoinEffect.Blast
end

--数据变量声明
function GuiCoinInfo:DataInit()
end

--节点事件绑定
function GuiCoinInfo:EventBind()
end

--信息UI滚动
function GuiCoinInfo:RollInfoUI()
    for k, v in pairs(rollInfoPanel) do
        if v.Offset.y <= 175 then
            v.Offset = v.Offset + Vector2(0, 3)
            v.CoinNum.Alpha = v.CoinNum.Alpha - 0.01
        else
            v.Offset = Vector2(0, -125)
            v:SetActive(false)
            v.CoinNum.Alpha = 1
            curCoinInfoPanel = v
            if remainingCoinNum > 0 then
                curCoinInfoPanel:SetActive(true)
                v.CoinNum.Text = '+' .. remainingCoinNum
                remainingCoinNum = 0
            end
        end
    end
end

--显示获得金币
function GuiCoinInfo:ShowGetCoinNumEventHandler(_num)
    --[[if _num > 0 then
        remainingCoinNum = remainingCoinNum + _num
    
        for k, v in pairs(localPlayer.Effect.GetCoinEffect:GetChildren()) do
            v:Emit(math.floor(tonumber(v.Name)))
        end
		if _num >= 1000 then
			this:GetCoinEffct(localPlayer.Local.Effect.GetCoinEffect.ConstraintFree.n1000)
		elseif _num >= 100 then
			this:GetCoinEffct(localPlayer.Local.Effect.GetCoinEffect.ConstraintFree.n100)
		elseif _num >= 10 then
			this:GetCoinEffct(localPlayer.Local.Effect.GetCoinEffect.ConstraintFree.n10)
		else
			this:GetCoinEffct(localPlayer.Local.Effect.GetCoinEffect.ConstraintFree.n1)
		end
    end]]
end

function GuiCoinInfo:UpdateCoinEventHandler(_num, _fromBag, _origin, _pos)
    if _pos == nil then
        if _num > 0 then
            remainingCoinNum = remainingCoinNum + _num
        end
    else
        GuiControl:CoinUIShake(_num)
    end
end

local timer = 0
function GuiCoinInfo:CalculateNum(dt)
    if remainingCoinNum > 0 then
        if timer < EFFECT_INTERVAL then
            timer = timer + dt
        else
            timer = 0
            if remainingCoinNum < 1 * EFFECT_EMI_MAX * EFFECT_GRADIENT then
                this:PlayEffect(1)
            elseif remainingCoinNum < 10 * EFFECT_EMI_MAX * EFFECT_GRADIENT then
                this:PlayEffect(10)
            elseif remainingCoinNum < 100 * EFFECT_EMI_MAX * EFFECT_GRADIENT then
                this:PlayEffect(100)
            else
                this:PlayEffect(100)
            end
        end
    end
end

function GuiCoinInfo:PlayEffect(_type)
    print('remainingCoinNum', remainingCoinNum)
    if remainingCoinNum > _type * EFFECT_EMI_MAX then
        this:Emit(_type, EFFECT_EMI_MAX)
        remainingCoinNum = remainingCoinNum - _type * EFFECT_EMI_MAX
    else
        if math.floor(remainingCoinNum / _type) > 0 then
            this:Emit(_type, math.floor(remainingCoinNum / _type))
        else
            this:Emit(_type, 1)
        end
        remainingCoinNum = 0
    end
end

function GuiCoinInfo:Emit(_type, _num)
    print('_type', _type)
    print('num', _num)
    coinEffect[tostring(_type)].Coin:Emit(_num)
    for k, v in pairs(blastEffect:GetChildren()) do
        v:Emit(_num)
    end
end

function GuiCoinInfo:Update(dt)
    this:CalculateNum(dt)
    --this:RollInfoUI()
end

return GuiCoinInfo
