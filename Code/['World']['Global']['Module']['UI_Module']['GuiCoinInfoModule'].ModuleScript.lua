---  金币信息UI模块：
-- @module  GuiCoinInfo
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module GuiCoinInfo
local GuiCoinInfo, this = ModuleUtil.New("GuiCoinInfo", ClientBase)

--gui
local coinInfoGUI
local rollInfoPanel = {}
local curCoinInfoPanel

--待显示的金币数量
local remainingCoinNum = 0

function GuiCoinInfo:Init()
    print("GuiCoinInfo:Init")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function GuiCoinInfo:NodeRef()
    coinInfoGUI = localPlayer.Local.SpecialBottomUI.GetCoinInfoGUI

    this.player = localPlayer
    this.coinEffect = this.player.Local.Effect.GetCoinEffect.ConstraintFree.Fx
    this.coinTree = this.player.Independent.GetCoinEffect.ConstraintFree

    for i = 1, 6 do
        rollInfoPanel[i] = coinInfoGUI["Panel" .. i]
    end
    curCoinInfoPanel = rollInfoPanel[1]
end

--数据变量声明
function GuiCoinInfo:DataInit()
end

--节点事件绑定
function GuiCoinInfo:EventBind()
end

--信息UI滚动
function GuiCoinInfo:RollInfoUI()
    for k, v in pairs(rollInfoPanel) do--[[
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
                v.CoinNum.Text = "+" .. remainingCoinNum
                remainingCoinNum = 0
            end
        end]]
    end
end

--显示获得金币
function GuiCoinInfo:ShowGetCoinNumEventHandler(_num)
    if _num > 0 then
        remainingCoinNum = remainingCoinNum + _num
		--[[
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
		end]]
    end
end

function GuiCoinInfo:UpdateCoinEventHandler(_num, _bool, _pos)
    if _pos ~= nil then
        this.coinEffect.Position = _pos
        this.coinEffect:SetActive(true)
        invoke(function()
            this.coinEffect:SetActive(false)       
        end, 3)
    else
        if _num > 0 then
            if _num >= 1000 then
                this:CoinPer(this.coinTree.n1000)
            elseif _num >= 100 then
                this:CoinPer(this.coinTree.n100)
            elseif _num >= 10 then
                this:CoinPer(this.coinTree.n10)
            else
                this:CoinPer(this.coinTree.n1)
            end
        end
    end
end

function GuiCoinInfo:CoinPer(_effect)
    local Tweener
    _effect.Position = this.player.Position + Vector3(0,1.7,0)
    this.coinTree.Fx.Position = this.player.Position + Vector3(0,2,0)
    _effect:SetActive(true)
    
    if Tweener then Tweener:Complete() end
    Tweener = Tween:TweenProperty(_effect, { Position = _effect.Position + Vector3(0,1.7,0) }, 1.5, 1)
    Tweener:Play()
    Tweener.OnComplete:Connect(function()
        _effect:SetActive(false)
        this.coinTree.Fx:SetActive(true)
    end)
    invoke(function()
        this.coinTree.Fx:SetActive(false)
    end, 0.2)
end


function GuiCoinInfo:GetCoinEffct(_effect)
	_effect.LocalPosition = Vector3(0,0,0)
	_effect.LinearVelocity = _effect.LinearVelocity + Vector3(0,localPlayer.LinearVelocity.y,0)
	_effect:SetActive(true)
	invoke(function()
		if _effect.LocalPosition.y >= 0.15 then
			localPlayer.Local.Effect.GetCoinEffect.ConstraintFree.Fx:SetActive(false)
			_effect.LinearVelocity = Vector3(0,0,0)
			wait(0.2)
			if _effect.LinearVelocity == Vector3(0,0,0) then
				_effect.LinearVelocity = Vector3(0,-1,0)
			end
			wait(0.2)
			if _effect.LinearVelocity == Vector3(0,-1,0) then
				localPlayer.Local.Effect.GetCoinEffect.ConstraintFree.Fx.Position = _effect.Position 
				localPlayer.Local.Effect.GetCoinEffect.ConstraintFree.Fx:SetActive(true)
				_effect.LinearVelocity = Vector3(0,4,0)
			end
			_effect:SetActive(false)
		end
	end,0.15)
end

function GuiCoinInfo:Update(dt)
    this:RollInfoUI()
end

return GuiCoinInfo
