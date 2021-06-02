--- @module MainGui 房间设置的UI模块
--- @copyright Lilith Games, Avatar Team
--- @author An Dai
local MainGui = ModuleUtil.New('MainGui', ClientBase)
local self = MainGui

local indexToColor = {
	Color(255,43,103,255),
	Color(255,80,80,255),
	Color(255,134,53,255),
	Color(252,194,93,255),
	Color(255,216,1,255),
	Color(196,228,45,255),
	Color(26,241,157,255),
	Color(0,148,136,255),
	Color(74,206,212,255),
	Color(39,116,255,255),
	Color(186,38,255,255),
	Color(255,75,151,255)
}

local isOwner = false

--- 初始化
function MainGui:Init()
	self:CreateGui()
	TouchHandle:RealInit()
end

function MainGui:CreateGui()
	self.arr_playerInfo = {}
	self.arr_playerNode = {}
	self.arr_request = {}
	self.mainGui = world:CreateInstance('MainGUI', 'MainGui', localPlayer.Local)
	self.listInfo = self.mainGui.ImgPlayerInfo
	
	for i = 1, 12 do---先生成12个
		self.arr_playerInfo[#(self.arr_playerInfo) + 1] = self:CreateNode()
	end
	
	self.mainGui.BtnOption.OnClick:Connect(function()
		OptionGui:Open()
	end)
	
	self.listInfo.ImgSide.BtnArrow.OnClick:Connect(function()
		self.listInfo.ImgSide.ImgArrow.Angle = 180 - self.listInfo.ImgSide.ImgArrow.Angle
		self.listInfo.Size = Vector2(263 - self.listInfo.Size.x, self.listInfo.Size.y)
	end)
end

function MainGui:UpdateInfo()
	isOwner = GetIsOwner()
	--。。。。。。
	local list = self.listInfo.PnlList
	local index = 0
	local room = LocalRooms:GetLPRoom()	
	local arr_gamingPlayers = room.arr_gamingPlayers
	local arr_watchPlayers = room.arr_watchPlayers
	
	local toDelete = {}
	for k, v in pairs(self.arr_request) do
		if not arr_watchPlayers[k] then
			toDelete[#toDelete + 1] = k
		end
	end
	for i, v in ipairs(toDelete) do
		self.arr_request[v] = nil
	end
	toDelete = nil
	
	self.arr_playerNode = {}
	---游戏中
	for k, v in pairs(arr_gamingPlayers) do
		index = index + 1
		self.arr_playerInfo[index] = self.arr_playerInfo[index] or self:CreateNode()
		local info = self.arr_playerInfo[index]
		self.arr_playerNode[k] = info
		local y = 0.993 - 0.073 * index
		info.AnchorsY = Vector2(y, y)
		info.TxtName.Text = NameHandle(v.Name)
		info.FigColor.Color = indexToColor[room:GetPlayerSeat(v.UserId)] or Color(255, 255, 255, 255)
		info.FigColor:SetActive(true)
		info.FigColor.ImgAgree:SetActive(false)
		info.FigColor.BtnAgree:SetActive(false)
		if(room.player_owner == v) then
			info.ImgOwner:SetActive(true)
		else
			info.ImgOwner:SetActive(false)
		end
		info:SetActive(true)
	end
	--中间牌子
	local y = 0.993 - 0.073 * (index + 1)
	list.ImgWatch.AnchorsY = Vector2(y, y)
	--观战
	for k, v in pairs(arr_watchPlayers) do
		index = index + 1
		self.arr_playerInfo[index] = self.arr_playerInfo[index] or self:CreateNode()
		local info = self.arr_playerInfo[index]
		self.arr_playerNode[k] = info
		y = 0.84 - 0.073 * (index - 1)
		info.AnchorsY = Vector2(y, y)
		info.TxtName.Text = NameHandle(v.Name)
		if(room.player_owner == v) then
			info.ImgOwner:SetActive(true)
		else
			info.ImgOwner:SetActive(false)
		end

		if(not self.arr_request[v.UserId]) then
			info.FigColor:SetActive(false)
			info.FigColor.ImgAgree:SetActive(false)
			info.FigColor.BtnAgree:SetActive(false)
		else
			local color = indexToColor[self.arr_request[v.UserId]]
			info.FigColor.Color = color
			info.FigColor:SetActive(true)
			info.FigColor.ImgAgree:SetActive(true)
			info.FigColor.BtnAgree:SetActive(true)
		end
		info:SetActive(true)
	end
	for i = index + 1, #(self.arr_playerInfo) do
		self.arr_playerInfo[i]:SetActive(false)
	end
end

function GetIsOwner()
	local LProom = LocalRooms:GetLPRoom()
	if(not LProom) then
		return false
	end
	return LProom.player_owner == localPlayer
end

---确保字符串长度合法
function NameHandle(_str)
	local permit = 6
	if(string.len(_str) <= permit) then
		return _str
	end
	return string.sub(_str, 1, permit - 2)
end

---一堆事件
function MainGui:RoomCreatedEventHandler(_roomUuid)
	if not LocalRooms:GetLPRoom() then return end
	wait()
	if(_roomUuid ~= LocalRooms:GetLPRoom().str_uuid) then
		return 
	end
	print('here!');self:UpdateInfo()
end

---TODO：房主和普通人的区别
function MainGui:RoomOwnerChangedEventHandler()
	if not LocalRooms:GetLPRoom() then return end
	wait()
	print('here!');self:UpdateInfo()
end

function MainGui:EnterRoomEventHandler(_roomUuid)
	if FsmMgr.playerActFsm.curState.stateName == "Idle" or FsmMgr.playerActFsm.curState.stateName == "BowIdle" then
		if not LocalRooms:GetLPRoom() then return end
		wait()
		if(_roomUuid ~= LocalRooms:GetLPRoom().str_uuid) then
			return 
		end
		print('here!');self:UpdateInfo()
	else
		NetUtil.Fire_C('InsertInfoEvent', _player, LanguageUtil.GetText(Config.GuiText.BoardGame_2.Txt), 3, true)
	end
end

function MainGui:LeaveRoomEventHandler(_roomUuid)
	if not LocalRooms:GetLPRoom() then return end
	if(_roomUuid ~= LocalRooms:GetLPRoom().str_uuid) then
		return 
	end
	print('here!');self:UpdateInfo()
end

function MainGui:StateChangedEventHandler(_roomUuid)
	wait()
	if not LocalRooms:GetLPRoom() then return end
	if(_roomUuid ~= LocalRooms:GetLPRoom().str_uuid) then
		return 
	end
	print('here!');self:UpdateInfo()
	invoke(function()
		self:UpdateInfo()
	end, 0.1)
end

function MainGui:EnterRoomSyncEventHandler(_roomUuid)
	if not LocalRooms:GetLPRoom() then return end
	wait()
	if(_roomUuid ~= LocalRooms:GetLPRoom().str_uuid) then
		return 
	end
	print('here!');self:UpdateInfo()
end

function MainGui:EnterRoomSyncEventHandler(_player, _roomUuid)
	if not LocalRooms:GetLPRoom() then return end
	wait()
	if(_player == localPlayer) then
		print('here!');self:UpdateInfo()
	end
end

function MainGui:RequestEnterEventHandler(_roomUuid, _requester, _index)
	if _roomUuid ~= LocalRooms:GetLPRoom().str_uuid then
		return
	end
	local uid = _requester.UserId
	local node = self.arr_playerNode[uid]
	if(not node) then
		return
	end
	self.arr_request[uid] = _index
	
	print('here!');self:UpdateInfo()
end

function MainGui:CreateNode()
	local node = world:CreateInstance('PlayerInfo', 'PlayerInfo', self.listInfo.PnlList)
	node.FigColor.BtnAgree.OnClick:Connect(function()
		local uid
		for k, v in pairs(self.arr_playerNode) do
			if(v == node) then
				uid = k
			end
		end
		if(not uid) then
			return
		end
		if(not self.arr_request[uid]) then
			return
		end
		--TODO
		NetUtil.Fire_S('AllowEnterEvent', LocalRooms:GetLPRoom().str_uuid, localPlayer, world:GetPlayerByUserId(uid), self.arr_request[uid])
		self.arr_request[uid] = nil
		node.FigColor.BtnAgree:SetActive(false)
		node.FigColor.ImgAgree:SetActive(false)
		node.FigColor:SetActive(false)
	end)
	return node
end

return MainGui