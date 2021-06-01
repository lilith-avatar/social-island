---@module TouchHandle --触摸响应模块,玩家控制模块的子模块
---@copyright Lilith Games, Avatar Team
---@author An Dai
--TODO:清理补偿变量
local TouchHandle = ModuleUtil.New('TouchHandle', ClientBase)
local this = TouchHandle

---常数
local camera
local slider
local clickThreshold = 0.07
if(world:GetDevicePlatform() == Enum.Platform.Windows) then
	clickThreshold = 0.15
end
local PixelToWorld = 1 / 1000
local borderMoveSpeed = 1

local TouchMode = {
	None = 0,
	Single = 1,
	Drag = 2,
	Double = 3
}

function Asymptote(x, A)
    A = A or 0.4
    if (A <= 0 or A >= 1) then
        error('A should be in good range')
    end
    if (x < 0) then
        error('x should be positive')
    end
    if (x <= A) then
        return x
    end
    return 1 + (3 * A * A - 2 * A) / x + (A * A - 2 * A * A * A) / x / x
end

---点击/滑动相关
this.touchMode = TouchMode.None
local lastTime = 0
local totalTime = 0
local firstFingerDistance = 0
local tempObjs = {}

---初始位置,屏幕坐标
local firstPos
---初始物体
local firstObjUUID

local function AddTime()
	local curTime = Timer:GetTime()
	local dt = curTime - lastTime
	totalTime = totalTime + dt
	lastTime = curTime
	return dt
end

--- 输入屏幕坐标，像素单位
--- 输出对应的物体表，距离从近到远
local function ScreenPosToItem(_pos)
	local re = {}
	local ray = camera:ScreenPointToRay(Vector3(_pos.x, _pos.y, 1.0))
	local rayCastAll = Physics:RaycastAll(ray.Origin, ray.Direction.Normalized * 100 + ray.Origin, false)
	local hitObjects = rayCastAll.HitObjectAll
	if(not HandMapping:IsInUI(_pos)) then
		---对应世界物体
		for i = 1, #hitObjects do
			local obj = hitObjects[i]
			if(obj.Name == 'Collider' and obj.Parent.UUID) then
				re[#re + 1] = obj.Parent.UUID.Value
			end
		end
	else
		---对应手牌区物体
		for i = 1, #hitObjects do
			local obj = hitObjects[i]
			if(obj.Name == 'Collider' and obj.Parent.Parent == camera.Deck) then
				re[#re + 1] = HandMapping:ModelToUUID(obj.Parent)
			end
		end
	end
	return re
end

local function InitTouch(_pos)
	this.touchMode = TouchMode.Single
	firstPos = _pos
	local t = ScreenPosToItem(_pos)
	firstObjUUID = t[1]
	totalTime = 0
	lastTime = Timer:GetTime()
	for i, v in ipairs(t) do
		tempObjs[v] = true
	end
end

local function IsBorder(_pos, _dt)
	local viewCoords = camera:ScreenToViewportPoint(Vector3(_pos.x, _pos.y, 1))
	local x = 0
	local y = 0
	if(viewCoords.x < 0.1) then
		x = -1
	elseif(viewCoords.x > 0.9) then
		x = 1
	end
	if(viewCoords.y < 0.1) then
		y = -1
	elseif(viewCoords.y > 0.9) then
		y = 1
	end
	if(x == 0 and y == 0) then
		return nil
	end
	return Vector2(x, y) * borderMoveSpeed * _dt
end

function this:RealInit()
	camera = localPlayer.Local.Independent.TableCam
	slider = localPlayer.Local.MainGui.ImgSlider
end

function this:MainHandler(container)
	---合理的双指操作：
	if(#container == 2 and PlayerInteract.curMode == Const.ControlModeEnum.None) then
		--双指触控
		if(self.touchMode ~= TouchMode.Double and container[2].Phase == 0) then
			---双指开始触摸
			firstFingerDistance = (container[1].Position - container[2].Position).Magnitude
			this.touchMode = TouchMode.Double
		elseif(self.touchMode ~= TouchMode.None) then
			---双指持续触摸
			local newDistance = (container[1].Position - container[2].Position).Magnitude
			local delta = firstFingerDistance - newDistance
			firstFingerDistance = newDistance
			CameraControl:Zoom(delta * PixelToWorld)
		end
		
		if(container[1].Phase == 3 or container[2].Phase == 3) then
			---松开一指则直接停止本次行为
			self:EndTouch()
		end
		return
	end
	
	---否则仅处理单指
	if(container[1].Phase == 0 and this.touchMode == TouchMode.None) then
		---单指开始
		InitTouch(container[1].Position)
		if(HandMapping.isOpen and not HandMapping:IsInUI(firstPos)) then
			HandMapping:Fold()
		elseif(not HandMapping.isOpen and HandMapping:IsInUI(firstPos)) then
			HandMapping:Unfold()
			return self:EndTouch()
		end
		self.touchMode = TouchMode.Single
	elseif(container[1].Phase == 3 and this.touchMode == TouchMode.Single) then
		---单指离开，对应点击
		self:ClickHandler()
		self:EndTouch()
	else
		--手指没放开，判断是否拖动
		local dt = AddTime()
		if(this.touchMode == TouchMode.Single and container[1].Phase == 1) then
			self.touchMode = TouchMode.Drag
		end
		if(self.touchMode == TouchMode.Drag) then
			self:DragHandler(container, dt)
		end
		if(container[1].Phase == 3) then
			self:EndTouch()
		end
	end
end

function this:EndTouch()
	totalTime = 0
	lastTime = 0
	firstObjUUID = nil
	firstPos = nil
	firstFingerDistance = 0
	tempObjs = {}
	PlayerInteract.vector3_dir = Vector3.Zero
	PlayerInteract.y_spd = 0
	if PlayerInteract.curMode == Const.ControlModeEnum.Rotate then
		SelectedObjs:StopRotate_Y()
		print('停止旋转')
	end
	this.touchMode = TouchMode.None
end

function this:ClickHandler()
	if(self.touchMode == TouchMode.None) then
		return
	end
	
	if(PlayerInteract.curMode == Const.ControlModeEnum.None) then
		this:NoneClick()
	elseif(PlayerInteract.curMode == Const.ControlModeEnum.Split) then
		this:SplitClick()
	elseif(PlayerInteract.curMode == Const.ControlModeEnum.Pile) then
		this:PileClick()
	elseif(PlayerInteract.curMode == Const.ControlModeEnum.Camera) then
		this:CameraClick()
	elseif(PlayerInteract.curMode == Const.ControlModeEnum.Select) then
		this:SelectClick()
	elseif(PlayerInteract.curMode == Const.ControlModeEnum.Rotate) then
		this:RotateClick()
	end
end

function this:DragHandler(container, dt)
	if(self.touchMode == TouchMode.None) then
		return
	end
	
	if(PlayerInteract.curMode == Const.ControlModeEnum.None) then
		this:NoneDrag(container, dt)
	elseif(PlayerInteract.curMode == Const.ControlModeEnum.Split) then
		this:SplitDrag(container, dt)
	elseif(PlayerInteract.curMode == Const.ControlModeEnum.Pile) then
		this:PileDrag(container, dt)
	elseif(PlayerInteract.curMode == Const.ControlModeEnum.Camera) then
		this:CameraDrag(container, dt)
	elseif(PlayerInteract.curMode == Const.ControlModeEnum.Select) then
		this:SelectDrag(container, dt)
	elseif(PlayerInteract.curMode == Const.ControlModeEnum.Rotate) then
		this:RotateDrag(container, dt)
	end
end

function this:NoneClick()
	if(not firstObjUUID) then
		SelectedObjs:CancelSelect()
	elseif(firstObjUUID and not SelectedObjs:GetSelectOrNot(firstObjUUID)) then
		SelectedObjs:CancelSelect()
		SelectedObjs:Select(firstObjUUID, false)
	end
end

function this:SplitClick()
	if(not firstObjUUID) then
		return
	end
	local selectUUID = firstObjUUID
	local unitSelect = table.nums(SelectedObjs.arr_selectedUnits)
	local stackSelect = table.nums(SelectedObjs.arr_selectedStacks)
	if(unitSelect + stackSelect == 0) then
		--当前没选择任何物体，选择
		SelectedObjs:Select(selectUUID, false)
		return
	end
	SelectedObjs:Adsorb(selectUUID)
	print('吸附物体')
end

function this:PileClick()
	if(not firstObjUUID) then
		return
	end
	---点击的是物体或堆叠
	local hitUUID = firstObjUUID
	local hitStack = LocalRooms:CheckInStack(hitUUID)
	local stackUUID
	if(hitStack) then stackUUID = hitStack.str_uuid end
	if(not hitStack) then
		---点击的不是堆叠，是单物体
		if(SelectedObjs.arr_selectedUnits[hitUUID]) then
			---已经选了，考虑是否要合并
			SelectedObjs:Stack(LocalRooms:GetUnitByUUID(hitUUID):GetType(), hitUUID)
			print('与所有同类合并')
			print('TODO:打乱')
			--TODO
			return
		else
			return
			---点了不成堆叠的没选择的单物体，无事发生
		end
	end
	---点击了堆叠
	if(SelectedObjs.arr_selectedStacks[stackUUID]) then
		---点击了已经选中的堆叠
		SelectedObjs:Stack(hitStack:GetType(), hitUUID)
		print('TODO:打乱')
		--TODO
		return
	else
		---点击了未选中的堆叠
		---取消所有选择并选择该堆叠
		SelectedObjs:CancelSelect()
		SelectedObjs:Select(firstObjUUID, true)
	end
end

function this:CameraClick()
	if(firstObjUUID) then
		CameraControl:LookAt(LocalRooms:GetUnitByUUID(firstObjUUID).obj_model.Position)
	else
		CameraControl:Reset()
	end
end

function this:SelectClick()
	if(firstObjUUID) then
		local uuid = firstObjUUID
		if(SelectedObjs:GetSelectOrNot(uuid)) then
			SelectedObjs:CancelSelect(uuid)
		else
			SelectedObjs:Select(uuid, false)
		end
	end
end

function this:RotateClick()
	if not SelectedObjs:HadSelectUnits() and firstObjUUID then
		--选择
		local uuid = firstObjUUID
		SelectedObjs:Select(uuid, false)
	elseif SelectedObjs:HadSelectUnits() then
		--反转
		SelectedObjs:Flip()
	end
end

---拖动处理函数

function this:NoneDrag(container, dt)
	local deltaPosition = container[1].DeltaPosition * PixelToWorld * CameraControl:GetDistance()
	local borderMove = IsBorder(container[1].Position, dt)
	if not SelectedObjs:HadSelectUnits() then
		CameraControl:Translate(-deltaPosition.x, -deltaPosition.y)
	elseif(borderMove) then
		---边界，移动镜头+物体
		CameraControl:Translate(borderMove.x, borderMove.y)
		PlayerInteract.vector3_dir = Vector3(borderMove.y, 0, -borderMove.x)
	else
		---物体移动
		local spd = deltaPosition.Magnitude / dt
		local factor = 0.75 + 1.25 * Asymptote(spd / 7)
		deltaPosition = Vector2(deltaPosition.x, deltaPosition.y / CameraControl:GetTheta())
		deltaPosition = CameraControl:CameraToWorld(deltaPosition)
		PlayerInteract.vector3_dir = factor * Vector3(deltaPosition.x, 0, deltaPosition.y / CameraControl:GetTheta())
		
	end
end

function this:SplitDrag(container, dt)
	local unitSelect = table.nums(SelectedObjs.arr_selectedUnits)
	local stackSelect = table.nums(SelectedObjs.arr_selectedStacks)
	if(unitSelect ~= 0 or stackSelect ~= 1) then
		self:EndTouch()
		return
	end
	if(not slider.ActiveInHierarchy) then
		--滑块选择数量
		local stackUUID
		for k, v in pairs(SelectedObjs.arr_selectedStacks) do
			stackUUID = k
		end
		local stackNum = LocalRooms:GetStackCountByUUID(stackUUID)
		if(stackNum <= 0) then
			self:EndTouch()
			return
		end
		PlayerInteract:SetSlider(0.5, stackNum)
		slider:SetActive(true)
	else
		--正常滑动
		local deltaP = container[1].DeltaPosition.x * 0.01
		PlayerInteract:AddSlider(deltaP)
	end
end

function this:PileDrag(container, dt)
	local unitSelect = table.nums(SelectedObjs.arr_selectedUnits)
	local stackSelect = table.nums(SelectedObjs.arr_selectedStacks)
	if(unitSelect == 0 and stackSelect == 1 and container[1].DeltaPosition.Magnitude > 5) then
		---是单选堆叠
		local stackUUID
		for k, v in pairs(SelectedObjs.arr_selectedStacks) do
			stackUUID = k
		end 
		---layout展开
		--TODO
		print('TODO:layout展开')
		this:EndTouch()
		return
	end
end

function this:CameraDrag(container, dt)
	local deltaAngle = container[1].DeltaPosition * PixelToWorld
	CameraControl:Rotate(-deltaAngle.y, -deltaAngle.x)
end

function this:SelectDrag(container, dt)
	local pos = container[1].Position
	local deltaPos = container[1].DeltaPosition
	local numOfRay = math.floor(deltaPos.Magnitude / 10) + 1
	for j = 1, numOfRay do
		local lerpedPos = pos - deltaPos + j / numOfRay * deltaPos
		local items = ScreenPosToItem(lerpedPos)
		for i, v in ipairs(items) do
			if(not tempObjs[v]) then
				SelectedObjs:Select(v, false)
				tempObjs[v] = true
			end
		end
	end
end	

function this:RotateDrag(container, dt)
	if(container[1].DeltaPosition.Magnitude < 0.001) then
		return
	end
	local deltaAngle = container[1].DeltaPosition.x * PixelToWorld
	PlayerInteract.y_spd = deltaAngle * -180 / math.pi
end

return TouchHandle