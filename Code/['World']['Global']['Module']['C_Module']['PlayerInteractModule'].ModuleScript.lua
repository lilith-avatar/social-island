---@module PlayerInteract --玩家操作管理模块
---@copyright Lilith Games, Avatar Team
---@author An Dai
local PlayerInteract = ModuleUtil.New('PlayerInteract', ClientBase)
local this = PlayerInteract
local camera
local gui
local tips
local touchScreen
local figHand
local SelectBtn
local SplitBtn
local RotateBtn
local CameraBtn
local PileBtn
local slider

local clickText = {
	Camera = '重置镜头/聚焦物体',
	Select = '追加选择/取消选择',
	Rotate = '翻转物品',
	Pile = '物品成堆/洗牌',
	Split = '吸附同类物品'
}

local dragText = {
	Camera = '旋转视角',
	Select = '多选物品',
	Rotate = '旋转物品',
	Pile = '展开牌叠',
	Split = '二分牌叠'
}
 
---私有变量

---模式相关
this.curMode = Const.ControlModeEnum.None

--@param _p 比例
function PlayerInteract:SetSlider(_p, totalNum, _obj)
	if(totalNum and totalNum <= 0) then
		slider.TxtLeft.Text = ''
		slider.TxtRight.Text = ''
		return
	end
	totalNum = totalNum or tonumber(slider.TxtLeft.Text) + tonumber(slider.TxtRight.Text)
	_p = math.clamp(_p, 0, 1)
	if(_obj) then
		local pos = camera:WorldToViewportPoint(_obj.Position)
		slider.AnchorsX = Vector2(pos.x, pos.x)
		slider.AnchorsY = Vector2(pos.y - 0.1, pos.y - 0.1)
	end
	local anX = slider.BoxSlider.AnchorsX
	local width = anX.y - anX.x
	slider.BoxSlider.AnchorsX = Vector2(_p - 0.5 * width, _p + 0.5 * width)
	local leftNum = math.round(_p * totalNum)
	local rightNum = totalNum - leftNum
	slider.TxtLeft.Text = string.format('%d', leftNum)
	slider.TxtRight.Text = string.format('%d', rightNum)
end

function PlayerInteract:ResetSlider()
	self:SetSlider(0.5, 0)
end

function PlayerInteract:AddSlider(_p)
	local anX = slider.BoxSlider.AnchorsX
	local curP = 0.5 * (anX.x + anX.y)
	self:SetSlider(curP + _p)
end

function PlayerInteract:Init()
	---当前选中手指滑动的方向,包含了速度
	self.vector3_dir = Vector3.Zero
	---上一帧移动方向
	self.vector3_dir_l = self.vector3_dir
	---当前选中物体的Y轴旋转速度
	self.y_spd = 0
end

function PlayerInteract:InitListener()
	camera = localPlayer.Local.Independent.TableCam
	world.CurrentCamera = camera
	camera.LookAt = localPlayer
	gui = localPlayer.Local.MainGui
	touchScreen = gui.FigControl
	figHand = gui.FigHand
	SelectBtn = gui.BtnChoose
	SplitBtn = gui.BtnSuck
	RotateBtn = gui.BtnPivot
	CameraBtn = gui.BtnCamera
	PileBtn = gui.BtnStack
	tips = gui.ImgTips
	slider = gui.ImgSlider
	---当前选中手指滑动的方向,包含了速度
	self.vector3_dir = Vector3.Zero
	---当前选中物体的Y轴旋转速度
	self.y_spd = 0
	
    touchScreen.OnTouched:Connect(function(container) TouchHandle:MainHandler(container) end)
	SelectBtn.OnDown:Connect(function() self:OnBtnDown('SelectBtn') end)
	SelectBtn.OnUp:Connect(function() self:OnBtnUp('SelectBtn') end)
	SplitBtn.OnDown:Connect(function() self:OnBtnDown('SplitBtn') end)
	SplitBtn.OnUp:Connect(function() self:OnBtnUp('SplitBtn') end)
	RotateBtn.OnDown:Connect(function() self:OnBtnDown('RotateBtn') end)
	RotateBtn.OnUp:Connect(function() self:OnBtnUp('RotateBtn') end)
	CameraBtn.OnDown:Connect(function() self:OnBtnDown('CameraBtn') end)
	CameraBtn.OnUp:Connect(function() self:OnBtnUp('CameraBtn') end)
	PileBtn.OnDown:Connect(function() self:OnBtnDown('PileBtn') end)
	PileBtn.OnUp:Connect(function() self:OnBtnUp('PileBtn') end)
end

function PlayerInteract:DisConnect()
	touchScreen.OnTouched:Clear()
	SelectBtn.OnUp:Clear()
	SplitBtn.OnDown:Clear()
	SplitBtn.OnUp:Clear()
	RotateBtn.OnDown:Clear()
	RotateBtn.OnUp:Clear()
	CameraBtn.OnDown:Clear()
	CameraBtn.OnUp:Clear()
	PileBtn.OnDown:Clear()
    PileBtn.OnUp:Clear()
end

function PlayerInteract:FixUpdate(_dt)
	if self.vector3_dir.Magnitude ~= 0 then
		SelectedObjs:Move(self.vector3_dir / _dt, _dt)
	end
	if self.y_spd ~= 0 then
		SelectedObjs:Rotate_Y(self.y_spd)
	end
	if(world:GetDevicePlatform() == Enum.Platform.Windows) then
		self:GetKeyboardInput(_dt)
	end
	if self.vector3_dir.Magnitude == 0 and self.vector3_dir_l.Magnitude ~= 0 then
		SelectedObjs:StopMove()
	end
	self.vector3_dir_l = self.vector3_dir
end

function PlayerInteract:OnBtnDown(_btnName)
	if(this.curMode == Const.ControlModeEnum.None) then
		---当前为空，切换功能
		local str = string.sub(_btnName, 1, -4)
		tips.InfoClick.Text = clickText[str]
		tips.InfoDrag.Text = dragText[str]
		tips:SetActive(true)
		TouchHandle:EndTouch()
		this.curMode = Const.ControlModeEnum[str]
		return
	end
	
end

function PlayerInteract:OnBtnUp(_btnName)
	if(this.curMode == Const.ControlModeEnum[string.sub(_btnName, 1, -4)]) then
		---松开了当前模式不同的按键且当前不为空
		tips:SetActive(false)
		tips.InfoClick.Text = ''
		tips.InfoDrag.Text = ''
		TouchHandle:EndTouch()
		this.curMode = Const.ControlModeEnum.None
		if(slider.ActiveInHierarchy) then
			--TODO
			print('TODO:切牌！')
			slider:SetActive(false)
		end
		self:ResetSlider()
	end
end

function PlayerInteract:GetKeyboardInput(_dt)
	if(not GameFlow.inGame) then
		return
	end
	---UI手牌测试
	if Input.GetPressKeyData(Enum.KeyCode.K) == Enum.KeyState.KeyStatePress then
		if(HandMapping.isOpen) then
			HandMapping:Fold()
		else
			HandMapping:Unfold()
		end
	end
	
	---缩放
	if(Input.GetPressKeyData(Enum.KeyCode.W) == Enum.KeyState.KeyStatePress) then
		CameraControl:Zoom(-0.2)
	end
	
	if(Input.GetPressKeyData(Enum.KeyCode.S) == Enum.KeyState.KeyStatePress) then
		CameraControl:Zoom(0.2)
	end
	
	if(Input.GetPressKeyData(Enum.KeyCode.Equals) == Enum.KeyState.KeyStatePress) then
		HandMapping:Add()
	end
	
	if(Input.GetPressKeyData(Enum.KeyCode.Minus) == Enum.KeyState.KeyStatePress) then
		HandMapping:Leave()
	end
	
	---按钮
	if(Input.GetPressKeyData(Enum.KeyCode.Z) == Enum.KeyState.KeyStatePress) then
		self:OnBtnDown('Cameraxxx')
	elseif(Input.GetPressKeyData(Enum.KeyCode.Z) == Enum.KeyState.KeyStateRelease) then
		self:OnBtnUp('Cameraxxx')
	end
	
	if(Input.GetPressKeyData(Enum.KeyCode.X) == Enum.KeyState.KeyStatePress) then
		self:OnBtnDown('Pilexxx')
	elseif(Input.GetPressKeyData(Enum.KeyCode.X) == Enum.KeyState.KeyStateRelease) then
		self:OnBtnUp('Pilexxx')
	end
	
	if(Input.GetPressKeyData(Enum.KeyCode.C) == Enum.KeyState.KeyStatePress) then
		self:OnBtnDown('Splitxxx')
	elseif(Input.GetPressKeyData(Enum.KeyCode.C) == Enum.KeyState.KeyStateRelease) then
		self:OnBtnUp('Splitxxx')
	end
	
	if(Input.GetPressKeyData(Enum.KeyCode.V) == Enum.KeyState.KeyStatePress) then
		self:OnBtnDown('Rotatexxx')
	elseif(Input.GetPressKeyData(Enum.KeyCode.V) == Enum.KeyState.KeyStateRelease) then
		self:OnBtnUp('Rotatexxx')
	end
	
	if(Input.GetPressKeyData(Enum.KeyCode.B) == Enum.KeyState.KeyStatePress) then
		self:OnBtnDown('Selectxxx')
	elseif(Input.GetPressKeyData(Enum.KeyCode.B) == Enum.KeyState.KeyStateRelease) then
		self:OnBtnUp('Selectxxx')
	end
	
	
	---鼠标拖动
	local mousePos = Input.GetMouseScreenPos()
	self.mousePos = self.mousePos or mousePos
	local DeltaPosition = mousePos - self.mousePos
	if(Input.GetPressKeyData(Enum.KeyCode.Mouse1) == Enum.KeyState.KeyStatePress) then
		TouchHandle:MainHandler({[1] = {Phase = 0, DeltaPosition = mousePos - self.mousePos, Position = mousePos}})
	elseif(Input.GetPressKeyData(Enum.KeyCode.Mouse1) == Enum.KeyState.KeyStateRelease) then
		TouchHandle:MainHandler({[1] = {Phase = 3, DeltaPosition = mousePos - self.mousePos, Position = mousePos}})
	elseif(Input.GetPressKeyData(Enum.KeyCode.Mouse1) == Enum.KeyState.KeyStateHold) then
		TouchHandle:MainHandler({[1] = {DeltaPosition = mousePos - self.mousePos, Position = mousePos, Phase = DeltaPosition.Magnitude > 2 and 1 or 2}})
	end
	self.mousePos = mousePos
end

return PlayerInteract