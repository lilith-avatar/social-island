---@module HandMapping --玩家手牌管理模块(主要管理映射)
---@copyright Lilith Games, Avatar Team
---@author An Dai

---临时代码
local handZone = class('handZone')
function handZone:initialize(_obj)
	self.m_obj = _obj
	self.m_size = Vector2(self.m_obj.Size.x, self.m_obj.Size.z)
	self.m_pos = self.m_obj.Position
end

function handZone:WorldToLocal(_pos)
	local delta = _pos - self.m_pos
	return Vector3(delta:Dot(self.m_obj.Right), delta:Dot(self.m_obj.Forward), delta:Dot(self.m_obj.Up))
end

--- @param _pos Vector3 世界坐标
function handZone:IsIn(_pos)
	local localDelta = self:WorldToLocal(_pos)
	if(math.abs(localDelta.x) > 0.5 * self.m_size.x) then
		return false
	end
	if(math.abs(localDelta.y) > 0.5 * self.m_size.y) then
		return false
	end
	return true
end

function handZone:Destroy()
	table.cleartable(self)
end

local HandMapping = ModuleUtil.New('HandMapping', ClientBase)
local this = HandMapping

---全局常数
local cameraDistance = 0.3
local deck
local camera
local whiteColor = Color(255, 255, 255, 255)
local unrealColor = Color(143, 207, 255, 200)

---游戏常数，如果以后有多种卡牌的话需要改成表
local cardSize = Vector3(0.189, 0.2634, 0.0294)--单位：Meter
local zoneEntityWidth = 1.1--单位：Meter
local zoneViewWidth = 0.7--单位：Anchor
local mapScale
local mapCardSize
local cardMapThickness = 0.0001
local topAnchor
local foldAnchor

function HandMapping:Init()
	--实体手牌区
	this.zone = nil
	--TODO:获知游戏类型，调整几何
	camera = localPlayer.Local.Independent.TableCam
	deck = camera.Deck
	---变量
	self.isOpen = true
	self.isEmpty = true
	self.isPlaying = false
	self.cardTable = {}
	self.mapTable = {}
	
	---计算缩放比例
	local ray = camera:ViewportPointToRay(Vector3(0.5 + 0.5 * zoneViewWidth, 0.5, 1))
	local dir = ray.Direction.Normalized
	local localDir = Vector3(dir:Dot(camera.Right), dir:Dot(camera.Up), dir:Dot(camera.Forward))
	local factor = cameraDistance / localDir.z
	local rightBorder = factor * localDir.x--实体距离，半屏宽
	
	mapScale = rightBorder / zoneEntityWidth * 2
	mapCardSize = cardSize * mapScale
	
	local upBorder = cameraDistance * math.tan(0.5 * camera.FieldOfView * math.pi / 180)--实体距离，半屏高
	local re0 = camera:ViewportPointToRay(Vector3(0.5, 0, 1))
	local test = camera.Forward:Angle(re0.Direction)
	topAnchor = (mapCardSize.y - 0.5 * deck.Size.y) * 0.5 / upBorder
	foldAnchor = (0.27 * mapCardSize.y - 0.5 * deck.Size.y) * 0.5 / upBorder
	--0.27是经测量得到的牌的Title占整个牌的比例
	self:Fold()
end

function HandMapping:Unfold()
	if(self.isOpen) then
		return
	end
	self.isOpen = true
	deck = camera.Deck or world:CreateInstance('Deck', 'Deck', camera)
	local ray = camera:ViewportPointToRay(Vector3(0.5, topAnchor, 1))
	local pos = ray:GetPoint(cameraDistance)
	local delta = pos - camera.Position
	deck.LocalPosition = Vector3(delta:Dot(camera.Right), delta:Dot(camera.Up), delta:Dot(camera.Forward))
end

function HandMapping:Fold()
	if(not self.isOpen) then
		return
	end
	self.isOpen = false
	deck = camera.Deck or world:CreateInstance('Deck', 'Deck', camera)
	local ray = camera:ViewportPointToRay(Vector3(0.5, foldAnchor, 1))
	local pos = ray:GetPoint(cameraDistance)
	local delta = pos - camera.Position
	deck.LocalPosition = Vector3(delta:Dot(camera.Right), delta:Dot(camera.Up), delta:Dot(camera.Forward))
end

function HandMapping:Adapt()
	--TODO: 实体区摆放
	
	--映射区摆放
	local n = #(self.mapTable)
	if(n <= 0) then
		return self:CheckEmpty()
	end
	if(n * mapCardSize.x <= mapScale * zoneEntityWidth or n <= 1) then
		--放得下，平铺
		for i = 1, n do
			local card = self.mapTable[i].obj
			card.LocalPosition = Vector3
			(
				(i - 1 + (n - 1) * -0.5) * mapCardSize.x,
				-0.5 * mapCardSize.y,
				0
			)
		end
	else
		--放不下，折叠
		local cardRight = self.mapTable[n].obj
		local xRight = 0.5 * mapScale * zoneEntityWidth -  0.5 * mapCardSize.x
		local xDelta = (mapScale * zoneEntityWidth - mapCardSize.x) / (n - 1)
		local zDelta = cardMapThickness
		cardRight.LocalPosition = Vector3
		(
			xRight,
			-0.5 * mapCardSize.y,
			0
		)
		for i = 1, n - 1 do
			local card = self.mapTable[i].obj
				card.LocalPosition = Vector3
				(
					xRight - (n - i) * xDelta,
					-0.5 * mapCardSize.y,
					(n - i) * zDelta
				)
		end
	end
	self:CheckEmpty()
end

function HandMapping:CheckEmpty()
	if(#(self.mapTable) > 0 and self.isEmpty) then
		self.isEmpty = false
		deck:SetActive(true)
	elseif(#(self.mapTable) == 0 and not self.isEmpty) then
		self.isEmpty = true
		deck:SetActive(false)
		self:Fold()
	end
end

function HandMapping:AddMap(_id, _m, isChosen)
	local config = Config.Unit[_id]
	local _obj = world:CreateInstance(config.Archetype, config.Name .. 'Model', deck, Vector3(1000, 0, 0), EulerDegree(90, 0, 0))
	_obj.Scale = mapScale
	_obj.LocalRotation = EulerDegree(90, 180, 0)
	_obj.CastShadows = false
	if(config.Texture ~= '') then
		_obj.Texture = ResourceManager.GetTexture(config.Texture)
	end
	if(isChosen) then
		_obj.Color = unrealColor
	end
	self.mapTable[_m].obj = _obj
	self:Adapt()
end

function HandMapping:AddCard(_uuid, _pos, isChosen)
	local id = LocalRooms:GetUnitByUUID(_uuid).num_id
	local xPos = self.zone:WorldToLocal(_pos).x
	self.cardTable[_uuid] = {
		cardId = id,
		place = nil
	}
	self.mapTable[#(self.mapTable) + 1] = {
		uuid = _uuid,
		x = xPos
	}
	self:Sort()
	self:AddMap(self.cardTable[_uuid].cardId, self.cardTable[_uuid].place, isChosen)
end

function HandMapping:LeaveCard(_uuid)
	print('Leave!!')
	self.mapTable[self.cardTable[_uuid].place].obj:Destroy()
	self.mapTable[self.cardTable[_uuid].place] = self.mapTable[#(self.mapTable)]
	self.mapTable[#(self.mapTable)] = nil
	self.cardTable[_uuid] = nil
	self:Sort()
	self:Adapt()
end

local function compare(t1, t2)
	return t1.x < t2.x
end

function HandMapping:Sort()
	table.sort(self.mapTable, compare)
	for i, v in ipairs(self.mapTable) do
		self.cardTable[v.uuid].place = i
	end
end

--- @param _pos Vector3 世界坐标
function HandMapping:IsInEntity(_pos)
	return self.zone:IsIn(_pos)
end

--- @param _pos Vector2 屏幕坐标
function HandMapping:IsInUI(_pos)
	local viewPortPos = camera:ScreenToViewportPoint(Vector3(_pos.x, _pos.y, 1))
	local upBorder = self.isOpen and topAnchor or foldAnchor
	upBorder = self.isEmpty and 0 or upBorder
	local rightBorder = 0.5 * zoneViewWidth
	return(math.abs(viewPortPos.x - 0.5) < rightBorder and viewPortPos.y < upBorder)
end

function HandMapping:ModelToUUID(_model)
	for i, v in pairs(self.mapTable) do
		if(v.obj == _model) then
			return v.uuid
		end
	end
end

function HandMapping:FixUpdate(_dt)
	if(not self.isPlaying) then
		return
	end
	---同步自己的操作物体
	for k ,v in pairs(SelectedObjs.arr_selectedUnits) do
		---k:uuid, v:C_UnitBase对象
		---检查是否响应手牌区和是否在手牌区内
		if(Config.Unit[v.num_id].HideTexture == '') then
			goto Continue
		end
		local pos = v.obj_model.Position
		if(self:IsInEntity(pos)) then
			if(not self.cardTable[k]) then
				print('添加虚影')
				---添加一个虚影
				self:AddCard(k, pos, true)
			else
				local xPos = self.zone:WorldToLocal(pos).x
				self.mapTable[self.cardTable[k].place].x = xPos
				self:Sort()
				self:Adapt()
			end
		elseif(self.cardTable[k]) then
			---删除
			print('删除')
			self:LeaveCard(k)
		end
		::Continue::
	end
end

function HandMapping:InitZone(gameId, _tableObj, n)
	local config = Config.Game[gameId].HandCard[n]
	if(self.zone) then
		self.zone:Destroy()
		self.zone = nil
	end
	local seatIndex = nil
	for i, v in ipairs(LocalRooms.room_localPlayer.arr_gamingSeat) do
		if(v == localPlayer.UserId) then
			seatIndex = i
			break
		end
	end
	
	self.zone = handZone:new(LocalRooms.room_localPlayer.local_table['HandZone' .. seatIndex])
	self.isPlaying = true
end

function HandMapping:LeaveGame()
	if(self.zone) then
		self.zone:Destroy()
	end
	self.zone = nil
	self.isOpen = true
	self.isEmpty = true
	self.isPlaying = false
	for k, v in pairs(self.mapTable) do
		v.obj:Destroy()
	end
	self.cardTable = {}
	self.mapTable = {}
	self:Fold()
end

function HandMapping:ElementOutHandEventHandler(_room_uuid, _uuid)
    if(not self.isPlaying) then
		return
	end
	if(SelectedObjs.arr_selectedUnits[_uuid]) then
		---是自己选择的
		if(self.cardTable[_uuid]) then
			--已经有了，变成虚的
			self.mapTable[self.cardTable[_uuid].place].obj.Color = unrealColor
		end
		return
	end
	local obj = LocalRooms:GetUnitByUUID(_uuid)
    if not obj then
        return
    end
	
    if(not self.cardTable[_uuid]) then
		return
	end
	
	---是从手牌区里走的，需要踢出
	self:LeaveCard(_uuid)
end 

function HandMapping:ElementHandEventHandler(_room_uuid, _player, _uuid)
	if(_player ~= localPlayer) then
		return
	end
    local room = LocalRooms:GetRoomByUuid(_room_uuid)
	if not room then
		return
	end
	if(not self.isPlaying) then
		return
	end
	local obj = LocalRooms:GetUnitByUUID(_uuid)
    if not obj then
        return
    end
	
	local _pos = obj.obj_model.Position
	
    if(self.cardTable[_uuid] and _player== localPlayer) then
		--已经有了，变成实心的
		print('变成实体')
		self.mapTable[self.cardTable[_uuid].place].obj.Color = whiteColor
	else
		self:AddCard(_uuid, _pos)
	end
end

return HandMapping
