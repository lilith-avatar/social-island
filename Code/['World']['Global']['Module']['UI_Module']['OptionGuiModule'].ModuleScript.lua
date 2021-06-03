--- @module OptionGui 房间设置的UI模块
--- @copyright Lilith Games, Avatar Team
--- @author An Dai
local OptionGui = ModuleUtil.New('OptionGui', ClientBase)
local self = OptionGui
local autoGame = false--加入游戏自动点选游戏进入选座位的通道

--- 初始化
function OptionGui:Init()
	self:CreateGui()
end

function OptionGui:CreateGui()
	self.optionGui = world:CreateInstance('OptionGUI', 'OptionGui', localPlayer.Local)
	local bg = self.optionGui.ImgSettingBG
	
	bg.BtnReset.OnClick:Connect(function()
		if(not GetIsOwner()) then
			return
		end
		local gameId = LocalRooms:GetLPRoom().num_id
		LocalRooms:TryChangeRoom(gameId)
		self.optionGui:SetActive(false)
	end)
	
	bg.BtnChoose.OnClick:Connect(function()
		if(not GetIsOwner()) then
			return
		end
		RoomGui:ResetGameList()
		localPlayer.Local.GameListGui:SetActive(true)
		self.optionGui:SetActive(false)
	end)
	
	bg.BtnLock.OnClick:Connect(function()
		if(not GetIsOwner()) then
			return
		end
		LocalRooms:TryChangeLock(not GetIsLocked())
		self.optionGui:SetActive(false)
	end)
	
	bg.BtnWatch.OnClick:Connect(function()
		if(GetIsWatching()) then
			if(not HasEmptySeat()) then
				self.optionGui:SetActive(false)
				return
			end
			if(GetIsOwner()) then
				---房主，直接让服务器安排上
				LocalRooms:TrySwitchState(Const.GamingStateEnum.Gaming)
			else
				---二等人，选座位等批准
				SeatGui:Open()
			end
		else
			LocalRooms:TrySwitchState(Const.GamingStateEnum.Watching)
		end
		self.optionGui:SetActive(false)
	end)
	
	bg.BtnExit.OnClick:Connect(function()
		LocalRooms:TryLeaveRoom()
		self.optionGui:SetActive(false)
	end)
	
	bg.BtnCancle.OnClick:Connect(function()
		self.optionGui:SetActive(false)
	end)
	
end

function OptionGui:Open()
	if(autoGame) then
		autoGame = false
		return
	end
	local isOwner = GetIsOwner()
	if(isOwner) then
		self.optionGui.ImgSettingBG.BtnReset.Alpha = 1
		self.optionGui.ImgSettingBG.BtnChoose.Alpha = 1
		self.optionGui.ImgSettingBG.BtnLock.Alpha = 1
	else
		self.optionGui.ImgSettingBG.BtnReset.Alpha = 0.3
		self.optionGui.ImgSettingBG.BtnChoose.Alpha = 0.3
		self.optionGui.ImgSettingBG.BtnLock.Alpha = 0.3
	end
	
	if(GetIsLocked()) then
		self.optionGui.ImgSettingBG.BtnLock.Text = LanguageUtil.GetText(Config.GuiText['BoardGame_21'].Txt)
	else
		self.optionGui.ImgSettingBG.BtnLock.Text = LanguageUtil.GetText(Config.GuiText['BoardGame_20'].Txt)
	end
	
	if(GetIsWatching()) then
		self.optionGui.ImgSettingBG.BtnWatch.Text = LanguageUtil.GetText(Config.GuiText['BoardGame_23'].Txt)
		if(not HasEmptySeat()) then
			self.optionGui.ImgSettingBG.BtnWatch.Alpha = 0.3
		else
			self.optionGui.ImgSettingBG.BtnWatch.Alpha = 1.0
		end
	else
		self.optionGui.ImgSettingBG.BtnWatch.Text = LanguageUtil.GetText(Config.GuiText['BoardGame_22'].Txt)
		self.optionGui.ImgSettingBG.BtnWatch.Alpha = 1.0
	end
	self.optionGui.ImgSettingBG.BtnReset.Text = LanguageUtil.GetText(Config.GuiText['BoardGame_19'].Txt)
	self.optionGui.ImgSettingBG.BtnExit.Text = LanguageUtil.GetText(Config.GuiText['BoardGame_24'].Txt)
	self.optionGui.ImgSettingBG.BtnCancle.Text = LanguageUtil.GetText(Config.GuiText['BoardGame_25'].Txt)
	
	self.optionGui:SetActive(true)
end

function OptionGui:EnterRoomEventHandler(_uuid, _player)
	if(_player == localPlayer) then
		wait();wait()
		if(not GetIsWatching()) then
			return
		end
		if(GetIsOwner() or not HasEmptySeat()) then
			return
		end
		autoGame = true
		SeatGui:Open()
	end
end

function HasEmptySeat()
	local LProom = LocalRooms:GetLPRoom()
	if(not LProom) then
		return false
	end
	return LProom:HasEmptySeat()
end

function GetIsOwner()
	local LProom = LocalRooms:GetLPRoom()
	if(not LProom) then
		return false
	end
	return LProom.player_owner == localPlayer
end

function OptionGui:DestroyGui()
	--TODO
end

function GetIsLocked()
	local LProom = LocalRooms:GetLPRoom()
	if(not LProom) then
		return true
	end
	return LProom.bool_lock
end

function GetIsWatching()
	local LProom = LocalRooms:GetLPRoom()
	if(not LProom) then
		return true
	end
	return LProom.arr_watchPlayers[localPlayer.UserId] and true or false
end


return OptionGui