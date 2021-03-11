---  通知信息UI模块：
-- @module  GuiNoticeInfo
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module GuiNoticeInfo
local GuiNoticeInfo, this = ModuleUtil.New("GuiNoticeInfo", ClientBase)

--gui
local noticeInfoGUI
local rollItemInfoPanel = {}
local curItemInfoPanel

local rollNoticeInfoPanel = {}

--待显示的ItemID表
local remainingItemID = {}
--待显示的Notice表
local remainingNoticeInfo = {}
--当前显示的Notice表
local curNoticeInfo = {}

function GuiNoticeInfo:Init()
    print("GuiNoticeInfo:Init")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function GuiNoticeInfo:NodeRef()
    noticeInfoGUI = localPlayer.Local.SpecialTopUI.NoticeInfoGUI
    for i = 1, 5 do
        rollItemInfoPanel[i] = noticeInfoGUI.Info.ItemInfoBG["Panel" .. i]
    end
    for i = 1, 2 do
        rollNoticeInfoPanel[i] = noticeInfoGUI.Info.NoticeInfoBG["Panel" .. i]
    end
    curItemInfoPanel = rollItemInfoPanel[1]
end

--数据变量声明
function GuiNoticeInfo:DataInit()
end

--节点事件绑定
function GuiNoticeInfo:EventBind()
end

--弹出信息
function GuiNoticeInfo:PopUpNotice(_panel, _right)
    local x = _right and 0 or -700
    local moveTween = Tween:TweenProperty(_panel, {Offset = Vector2(x, _panel.Offset.y)}, 0.5, Enum.EaseCurve.Linear)
    moveTween:Play()
    moveTween.OnComplete:Connect(
        function()
            moveTween:Destroy()
            _panel.Info.Text = _right and _panel.Info.Text or "nil"
        end
    )
end

--获取空闲的通知UI
function GuiNoticeInfo:GetFreeNoticeUI()
    for k, v in pairs(rollNoticeInfoPanel) do
        if v.Info.Text == "nil" then
            return v
        end
    end
    return nil
end

--信息UI滚动
function GuiNoticeInfo:RollInfoUI(dt)
    for k, v in pairs(rollItemInfoPanel) do
        if v.Offset.y <= 240 then
            v.Offset = v.Offset + Vector2(0, 3)
            for _, ui in pairs(v:GetChildren()) do
                ui.Alpha = ui.Alpha - 0.01
            end
        else
            v.Offset = Vector2(v.Offset.x, -160)
            v:SetActive(false)
            for _, ui in pairs(v:GetChildren()) do
                ui.Alpha = 1
            end
            curItemInfoPanel = v
            if #remainingItemID > 0 then
                curItemInfoPanel:SetActive(true)
                v.InfoText.Text = LanguageUtil.GetText(Config.Item[remainingItemID[1]].Name)
                table.remove(remainingItemID, 1)
            end
        end
    end
    if #remainingNoticeInfo > 0 then
        if this:GetFreeNoticeUI() then
            local tmpUI = this:GetFreeNoticeUI()
            tmpUI.Info.Text = remainingNoticeInfo[1].text
            local tempData = remainingNoticeInfo[1]
            table.insert(
                curNoticeInfo,
                {
                    ui = tmpUI,
                    data = tempData
                }
            )
            table.remove(remainingNoticeInfo, 1)
            tmpUI.Join.OnClick:Clear()
            tmpUI.Join.OnClick:Connect(
                function()
                    localPlayer.Position = tempData.pos
                end
            )
            tmpUI.Close.OnClick:Clear()
            tmpUI.Close.OnClick:Connect(
                function()
                    this:PopUpNotice(tmpUI, false)
                    tempData.t = 0.5
                end
            )
            this:PopUpNotice(tmpUI, true)
        end
    end
    for k, v in pairs(curNoticeInfo) do
        if v.data.t <= 0.5 then
            this:PopUpNotice(v.ui, false)
            table.remove(curNoticeInfo, k)
        else
            v.data.t = v.data.t - dt
        end
    end
end

--显示获得物品
function GuiNoticeInfo:ShowGetItem(_itemID)
    table.insert(remainingItemID, _itemID)
end

--显示通知信息
function GuiNoticeInfo:ShowNoticeInfoEventHandler(_text, _t, _pos)
    table.insert(
        remainingNoticeInfo,
        {
            text = _text,
            t = _t + 1,
            pos = _pos
        }
    )
end

function GuiNoticeInfo:Update(dt)
    this:RollInfoUI(dt)
end

return GuiNoticeInfo
