--- @module SeatGui 选座位模块
--- @copyright Lilith Games, Avatar Team
--- @author An Dai
local SeatGui = ModuleUtil.New('SeatGui', ClientBase)
local self = SeatGui
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

local indexToSit = nil
--- 初始化
function SeatGui:Init()
	self.arr_playerInfo = {}
	self:CreateGui()
end

function SeatGui:CreateGui()
	self.seatGui = world:CreateInstance('SeatGUI', 'SeatGui', localPlayer.Local)
	local bg = self.seatGui.ImgPopsBG
	local pnl = bg.PnlPlayerList
	local imgSeat = bg.ImgTable
	for i = 1, 12 do---先生成12个
		self.arr_playerInfo[#(self.arr_playerInfo) + 1]
			= world:CreateInstance('PlayerInfo', 'PlayerInfo', pnl)
	end
	for i, v in ipairs(imgSeat:GetChildren()) do
		if(string.sub(v.Name, 1, 7) == 'BtnSeat') then
			local index = tonumber(string.sub(v.Name, 8, -1))
			v.OnClick:Connect(function()
				print(index, '点击')
				--TODO:有人是点不了的
				if(GetSeatUserId(index) ~= -1) then
					print('有人了')
					return
				end
				if(indexToSit) then
					imgSeat['BtnSeat' .. indexToSit].ImgPeople:SetActive(false)
				end
				indexToSit = index
				imgSeat['BtnSeat' .. indexToSit].ImgPeople:SetActive(true)
				bg.BtnSure.Alpha = 1
			end)
		end
	end
	
	bg.BtnBack.OnClick:Connect(function()
		OptionGui:Open()
		self.seatGui:SetActive(false)
	end)
	
	bg.BtnSure.OnClick:Connect(function()
		if(not indexToSit) then
			return
		end
		LocalRooms:TrySwitchState(Const.GamingStateEnum.Gaming, indexToSit)
		self.seatGui:SetActive(false)
	end)
end

function SeatGui:Open()
	self:UpdateInfo()
	self.seatGui.ImgPopsBG.BtnSure.Alpha = 0.3
	indexToSit = nil
	self.seatGui:SetActive(true)
end


function SeatGui:DestroyGui()
	--TODO
end

function SeatGui:UpdateInfo()
	self:PnlClear()
	local bg = self.seatGui.ImgPopsBG
	local pnl = bg.PnlPlayerList
	local imgSeat = bg.ImgTable
	---锁
	local bg = self.seatGui.ImgPopsBG
	if(GetIsLocked()) then
		bg.ImgTable.ImgLock:SetActive(true)
	else
		bg.ImgTable.ImgLock:SetActive(false)
	end
	---座位
	local arr_gamingSeat = GetSeatArray()
	for i, v in ipairs(imgSeat:GetChildren()) do
		if(string.sub(v.Name, 1, 7) == 'BtnSeat') then
			local index = tonumber(string.sub(v.Name, 8, -1))
			v.Color = indexToColor[index]
			local num = #arr_gamingSeat
			v.Angle = -360 / num * (i - 1)
			if(index > num) then
				v:SetActive(false)
			else
				v:SetActive(true)
				if(arr_gamingSeat[index] ~= -1) then
					v.ImgPeople:SetActive(true)
					self:PnlAdd(index, arr_gamingSeat[index])
					v.Color = indexToColor[index]
				else
					v.ImgPeople:SetActive(false)
					v.Color = Color(255, 255, 255, 255)
				end
			end
		end
	end
end

function GetSeatUserId(_index)
	local arr_gamingSeat = GetSeatArray()
	return arr_gamingSeat[_index]
end

function SeatGui:PnlClear()
	for i, v in ipairs(self.arr_playerInfo) do
		v:SetActive(false)
	end
end

function SeatGui:PnlAdd(_index, _userId)
	for i, v in ipairs(self.arr_playerInfo) do
		if(not v.ActiveSelf) then
			--取第一个未激活的
			local y = 0.95 - 0.06 * (i - 1)
			v.AnchorsY = Vector2(y, y)
			v.TxtName.Text = world:GetPlayerByUserId(_userId).Name
			v.FigColor.Color = indexToColor[_index]
			v:SetActive(true)
			return
		end
	end
	local bg = self.seatGui.ImgPopsBG
	local pnl = bg.PnlPlayerList
	self.arr_playerInfo[#(self.arr_playerInfo) + 1]
			= world:CreateInstance('PlayerInfo', 'PlayerInfo', pnl)
	local info = self.arr_playerInfo[#(self.arr_playerInfo)]
	local y = 0.95 - 0.06 * (i - 1)
	info.AnchorsY = Vector2(y, y)
	info.TxtName.Text = world:GetPlayerByUserId(_userId).Name
	info.FigColor.Color = indexToColor[_index]
	info:SetActive(true)
end

function GetIsLocked()
	local LProom = LocalRooms:GetLPRoom()
	if(not LProom) then
		return true
	end
	return LProom.bool_lock
end

function GetSeatArray()
	local LProom = LocalRooms:GetLPRoom()
	if(not LProom) then
		return
	end
	return LProom.arr_gamingSeat
end

return SeatGui