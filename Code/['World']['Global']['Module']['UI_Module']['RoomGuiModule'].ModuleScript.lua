--- @module RoomGui 房间信息相关的UI管理模块
--- @copyright Lilith Games, Avatar Team
--- @author An Dai
local RoomGui = ModuleUtil.New('RoomGui', ClientBase)
local self = RoomGui
local isCreating = nil
local activatedBtn = nil
local gameToCreate = nil

local MaxNum = 12
local MinNum = 1
local curNum = 12

--- 初始化
function RoomGui:Init()
	self.localFolder = localPlayer.Local
	self:CreateGui()
end

--TODO
function RoomGui:CreateGui()
	self.settingGui = world:CreateInstance('SettingGUI', 'SettingGui', self.localFolder)
	self.gameListGui = world:CreateInstance('GameListGUI', 'GameListGui', self.localFolder)
	self.settingGui.ImgSettingBG.BtnLock.OnClick:Connect(function()
		local yes = self.settingGui.ImgSettingBG.BtnLock.ImgLock
		yes:SetActive(not yes.ActiveSelf)
	end)
	
	self.settingGui.ImgSettingBG.BtnCancle.OnClick:Connect(function()
		self.settingGui:SetActive(false)
		ResetSettingGUI()
	end)
	
	self.settingGui.ImgSettingBG.BtnSure.OnClick:Connect(ConfirmCreateRoom)
	InitGameList()
	
	self.gameListGui.ImgPopsBG.BtnSure.OnClick:Connect(function()
		if(not gameToCreate) then
			return
		end
		LocalRooms:TryChangeRoom(gameToCreate)
		self.gameListGui:SetActive(false)
		ResetGameList()
		isCreating = false
	end)
	
	self.gameListGui.ImgPopsBG.BtnBack.OnClick:Connect(function()
		self.gameListGui:SetActive(false)
		ResetGameList()
		isCreating = false
	end)
	
	self.settingGui.ImgSettingBG.ImgSlider.BtnAdd.OnClick:Connect(function()
		curNum = math.min(curNum + 1, MaxNum)
		SetSettingGUI()
	end)
	
	self.settingGui.ImgSettingBG.ImgSlider.BtnMinus.OnClick:Connect(function()
		curNum = math.max(curNum - 1, MinNum)
		SetSettingGUI()
	end)
end

---玩家开始创建，需要初始化，如果中途退出则不通知服务端
function RoomGui:StartCreateRoom(_gameId)
--不在飞碟上，或是不在Idle状态就不许打牌
	if FsmMgr.playerActFsm.curState.stateName == "Idle" or FsmMgr.playerActFsm.curState.stateName == "BowIdle" then
		if localPlayer.Position.x > 2000 then 
			NetUtil.Fire_C('InsertInfoEvent', localPlayer, LanguageUtil.GetText(Config.GuiText.BoardGame_1.Txt), 3, true)
			return 
		end
		LocalRooms:TryCreateRoom(4, false)
		invoke(function() LocalRooms:TryChangeRoom(_gameId) end,0.5)
		invoke(function()LocalRooms:TrySwitchState(Const.GamingStateEnum.Gaming) end,0.5)
	else
		NetUtil.Fire_C('InsertInfoEvent', localPlayer, LanguageUtil.GetText(Config.GuiText.BoardGame_2.Txt), 3, true)
	end
end

function RoomGui:CUseItemEventHandler(_id)
    if _id == 4005 then
        self:StartCreateRoom(1000)
    elseif _id == 4006 then
        self:StartCreateRoom(1002)
    end
end

function ConfirmCreateRoom()
	local isLocked = false
	self.settingGui:SetActive(false)
	LocalRooms:TryCreateRoom(curNum, isLocked)
	isCreating = true
end

function RoomGui:RoomCreatedEventHandler(_uuid, _player, _pos, _lock)
	--[[
	if(_player == localPlayer) then
		ResetGameList()
		self.gameListGui:SetActive(true)
	end]]
end

function ResetSettingGUI()
	curNum = MaxNum
	local bg = self.settingGui.ImgSettingBG
	bg.BtnLock.ImgLock:SetActive(false)
	SetSettingGUI()
end

function SetSettingGUI()
	local bg = self.settingGui.ImgSettingBG
	bg.ImgSlider.TxtNum.Text = curNum
	local x = (curNum - MinNum) / (MaxNum - MinNum)
	bg.ImgSlider.BoxSlider.AnchorsX = Vector2(x, x)
end

function ResetGameList()
	if(activatedBtn) then
		activatedBtn.ImgChoose:SetActive(false)
	end
	activatedBtn = nil
	gameToCreate = nil
	self.gameListGui.ImgPopsBG.BtnSure.Alpha = 0.3
end

function RoomGui:ResetGameList()
	ResetGameList()
end

function InitGameList()
	local i = 0
	for k, v in pairs(Config.Game) do
		if(not v.Enable) then
			goto Continue
		end
		i = i + 1
		local info = world:CreateInstance('GameInfo', 'GameInfo',
			self.gameListGui.ImgPopsBG.PnlGameList)
		local x = (i - 1) % 4
		local y = (i - x - 1) / 4
		info.AnchorsX = Vector2(0.25 * x, 0.25 * x)
		info.AnchorsY = Vector2(0.95 - 0.32 * y, 0.95 - 0.32 * y)
		info:SetActive(true)
		info.ImgInfoBG.TxtGameName.Text = v.Name
		info.ImgInfoBG.TxtNum.Text = v.Des
		info.ImgGamePic.Texture = ResourceManager.GetTexture(v.Icon)
		info.OnClick:Connect(function()
			ResetGameList()
			activatedBtn = info
			activatedBtn.ImgChoose:SetActive(true)
			gameToCreate = v.ID
			self.gameListGui.ImgPopsBG.BtnSure.Alpha = 1
		end)
		::Continue::
	end
end

return RoomGui