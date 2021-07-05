---  通知信息UI模块：
-- @module  GuiNoticeInfo
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module GuiNoticeInfo
local GuiNoticeInfo, this = ModuleUtil.New('GuiNoticeInfo', ClientBase)

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

-- UIFadeTween动画
local uiFadeTween = nil

-- 玩家信息处理队列
local playerInfoList = {}

function GuiNoticeInfo:Init()
    --print('GuiNoticeInfo:Init')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function GuiNoticeInfo:NodeRef()
    noticeInfoGUI = localPlayer.Local.SpecialTopUI.NoticeInfoGUI
    for i = 1, 5 do
        rollItemInfoPanel[i] = noticeInfoGUI.Info.ItemInfoBG['Panel' .. i]
    end
    for i = 1, 2 do
        rollNoticeInfoPanel[i] = noticeInfoGUI.Info.NoticeInfoBG['Panel' .. i]
		rollNoticeInfoPanel[i].Join.Text = LanguageUtil.GetText(Config.GuiText['InfoGui_6'].Txt)
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
	SoundUtil.Play2DSE(localPlayer.UserId, 36)
	moveTween:Play()
    moveTween.OnComplete:Connect(
        function()
            moveTween:Destroy()
            _panel.Info.Text = _right and _panel.Info.Text or 'nil'
        end
    )
end

--获取空闲的通知UI
function GuiNoticeInfo:GetFreeNoticeUI()
    for k, v in pairs(rollNoticeInfoPanel) do
        if v.Info.Text == 'nil' then
            return v
        end
    end
    return nil
end

local itemRollTimer = 0
--信息UI滚动
function GuiNoticeInfo:RollInfoUI(dt)
    itemRollTimer = itemRollTimer + dt
    for k, v in pairs(rollItemInfoPanel) do
        local rate = (v.Offset.y + 160) / 400 + 0.3
        local speed = rate * rate * rate + 0.1
        if v.Offset.y <= 240 then
            v.Offset = v.Offset + Vector2(0, 20 * speed)
            for _, ui in pairs(v:GetChildren()) do
                ui.Alpha = ui.Alpha - 0.1 * speed
            end
        else
            v.Offset = Vector2(v.Offset.x, -160)
            v:SetActive(false)
            for _, ui in pairs(v:GetChildren()) do
                ui.Alpha = 1
            end
            curItemInfoPanel = v
            if #remainingItemID > 0 and itemRollTimer > 1 then
                itemRollTimer = 0
                curItemInfoPanel:SetActive(true)
				SoundUtil.Play2DSE(localPlayer.UserId, 109)
                v.Icon.Texture = ResourceManager.GetTexture('UI/ItemIcon/' .. Config.Item[remainingItemID[1]].Icon)
                LanguageUtil.SetText(v.InfoText, Config.Item[remainingItemID[1]].Name, true, 20, 40)
                table.remove(remainingItemID, 1)
            end
        end
    end
    if #remainingNoticeInfo > 0 then
        if this:GetFreeNoticeUI() then
            local tmpUI = this:GetFreeNoticeUI()
            tmpUI.profile.Texture = ResourceManager.GetTexture('UI/NPCTalk/' .. remainingNoticeInfo[1].profileImg)
            tmpUI.Info:SetActive(false)
            tmpUI.Info.Text = remainingNoticeInfo[1].text
            LanguageUtil.TextAutoSize(tmpUI.Info, 10, 50)
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
            if tempData.callBack then
                tmpUI.Join:SetActive(true)
            else
                tmpUI.Join:SetActive(false)
            end
			SoundUtil.Play2DSE(localPlayer.UserId, 3)
            tmpUI.Join.OnClick:Connect(
                function()
					if GameFlow.inGame then
						NetUtil.Fire_C('InsertInfoEvent', localPlayer, LanguageUtil.GetText(Config.GuiText.BoardGame_7.Txt), 3, true)
						return
					end
                    this:PopUpNotice(tmpUI, false)
					SoundUtil.Play2DSE(localPlayer.UserId, 108)
                    tempData.t = 0.5
                    --print(type(tempData.callBack))
                    if type(tempData.callBack) == 'function' then
                        tempData.callBack()
                    elseif type(tempData.callBack) == 'userdata' then
						localPlayer.Position = tempData.callBack
						if tempData.id == 1 then
							CloudLogUtil.UploadLog('pannel_actions', 'window_eventGui_maze_yes')
						elseif tempData.id == 3 then
							CloudLogUtil.UploadLog('pannel_actions', 'window_eventGui_snail_yes')
						elseif tempData.id == 4 then
							CloudLogUtil.UploadLog('pannel_actions', 'window_eventGui_ufo_yes')
						end
                    end
                end
            )
            tmpUI.Close.OnClick:Clear()
            tmpUI.Close.OnClick:Connect(
                function()
					SoundUtil.Play2DSE(localPlayer.UserId, 6)
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

--- UI渐隐渐显
function GuiNoticeInfo:UIFade(_ui, _isFade)
    local alpha = _isFade and 0 or 255
    uiFadeTween =
        Tween:TweenProperty(
        _ui,
        {Color = Color(_ui.Color.r, _ui.Color.g, _ui.Color.b, alpha)},
        0.2,
        Enum.EaseCurve.Linear
    )
    uiFadeTween:Play()
end

--- 显示玩家信息文字
function GuiNoticeInfo:ShowInfo(dt)
    if #playerInfoList > 0 then
        noticeInfoGUI.Info.PlayerInfoBG:SetActive(true)
        if noticeInfoGUI.Info.PlayerInfoBG.BG.Info.Text ~= playerInfoList[1].text then
            SoundUtil.Play2DSE(localPlayer.UserId, 3)
            noticeInfoGUI.Info.PlayerInfoBG.BG.Info:SetActive(false)
            noticeInfoGUI.Info.PlayerInfoBG.BG.Info.Text = playerInfoList[1].text
            LanguageUtil.TextAutoSize(noticeInfoGUI.Info.PlayerInfoBG.BG.Info, 10, 40)
            this:UIFade(noticeInfoGUI.Info.PlayerInfoBG.BG.Info, false)
            this:UIFade(noticeInfoGUI.Info.PlayerInfoBG.BG.Icon, false)
            this:UIFade(noticeInfoGUI.Info.PlayerInfoBG.BG, false)
        end
        playerInfoList[1].t = playerInfoList[1].t - dt
        if playerInfoList[1].t <= 1 and noticeInfoGUI.Info.PlayerInfoBG.BG.Info.Color.a == 255 then
            this:UIFade(noticeInfoGUI.Info.PlayerInfoBG.BG.Info, true)
            this:UIFade(noticeInfoGUI.Info.PlayerInfoBG.BG.Icon, true)
            this:UIFade(noticeInfoGUI.Info.PlayerInfoBG.BG, true)
            invoke(
                function()
                    table.remove(playerInfoList, 1)
                    noticeInfoGUI.Info.PlayerInfoBG.BG.Info.Text = ''
                end,
                1
            )
        end
    else
        noticeInfoGUI.Info.PlayerInfoBG:SetActive(false)
    end
end

--- 插入玩家信息文字
function GuiNoticeInfo:InsertInfoEventHandler(_text, _t,_isTop)
	if  LanguageUtil.GetText(_text) then
		infoText = LanguageUtil.GetText(_text)
	else
		infoText = _text
	end
	
	if GuiNoticeInfo:CheckInfoUnique(infoText,playerInfoList) then
		if _isTop then
			table.insert(
				playerInfoList,
				{
					text = infoText,
					1,
					t = _t + 0.4
				}
			)
		else
			table.insert(
				playerInfoList,
				{
					text = infoText,
					t = _t + 0.4
				}
			)
		end
	end
end

--- 检查消息队列唯一性
function GuiNoticeInfo:CheckInfoUnique(_text,_table)
	local res = true
	for k ,v in pairs(_table) do
		if v.text == _text then
			res = false
		end
	end
	return res
end

--显示通知信息
function GuiNoticeInfo:ShowNoticeInfoEventHandler(_noticeInfoID, _callBack)
    local info = Config.NoticeInfo[_noticeInfoID]
    --print(table.dump(info))
    table.insert(
        remainingNoticeInfo,
        {
            id = _noticeInfoID,
            text = LanguageUtil.GetText(Config.GuiText[info.TextID].Txt),
            t = info.Dur + 1,
            profileImg = info.ProfileImg,
            callBack = _callBack or nil
        }
    )
    if _noticeInfoID == 1 then
        CloudLogUtil.UploadLog('pannel_actions', 'window_eventGui_maze_show')
    elseif _noticeInfoID == 3 then
        CloudLogUtil.UploadLog('pannel_actions', 'window_eventGui_snail_show')
    elseif _noticeInfoID == 4 then
        CloudLogUtil.UploadLog('pannel_actions', 'window_eventGui_ufo_show')
    end
end

function GuiNoticeInfo:Update(dt)
    this:RollInfoUI(dt)
    this:ShowInfo(dt)
end

return GuiNoticeInfo
