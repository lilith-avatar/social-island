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
    for k, v in pairs(rollInfoPanel) do
        if v.Offset.y <= 175 then
            v.Offset = v.Offset + Vector2(0, 3)
            v.CoinNum.Alpha = v.CoinNum.Alpha - 0.01
        else
            v.Offset = Vector2(0, -125)
            v.CoinNum.Alpha = 1
            v:SetActive(false)
            curCoinInfoPanel = v
            if remainingCoinNum > 0 then
                curCoinInfoPanel:SetActive(true)
                v.CoinNum.Text = "+" .. remainingCoinNum
                remainingCoinNum = 0
            end
        end
    end
end

--显示获得金币
function GuiCoinInfo:ShowGetCoinNumEventHandler(_num)
    remainingCoinNum = remainingCoinNum + _num
end

function GuiCoinInfo:Update(dt)
    this:RollInfoUI()
end

return GuiCoinInfo
