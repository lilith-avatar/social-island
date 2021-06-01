---@module CameraControl --相机操作管理模块
---@copyright Lilith Games, Avatar Team
---@author An Dai
local CameraControl = ModuleUtil.New('CameraControl', ClientBase)
local this = CameraControl
local math = math

local rad2deg = 180 / math.pi
local deg2rad = 1 / rad2deg

local camera

---初值
local startPoint = Vector3(7.74, 5.0285, -1.5279)
local moveRange = 10
local lookAtPoint = startPoint
local R = 3
local Theta = 45 * deg2rad
local Phy = 0

---脏标记，是否需要更新
local needUpdate = true

function CameraControl:Init()
	camera = localPlayer.Local.Independent.TableCam
end

function CameraControl:Reset()
	lookAtPoint = startPoint
	R = 3
	Theta = 60 * deg2rad
	Phy = 0
	needUpdate = true
end

function CameraControl:GetDistance()
	return R
end

function CameraControl:GetTheta()
	return Theta
end

function CameraControl:GetPhy()
	return Phy
end

function CameraControl:UpdateTransform()
	local position = lookAtPoint
		+ Vector3(
			R * math.cos(Theta) * math.cos(Phy),
			R * math.sin(Theta),
			R * math.cos(Theta) * math.sin(Phy)
		)
	camera.Position = position
	camera.Rotation = EulerDegree.LookRotation((lookAtPoint - position).Normalized, Vector3.Up) 
	needUpdate = false
end

function CameraControl:FixUpdate(_dt, _tt)
	if(needUpdate) then
		self:UpdateTransform()
	end
end

function CameraControl:CameraToWorld(_pos)
	---相机的方位角和相机的朝向刚好是反的
	return Vector2
	(
		-math.cos(Phy) * _pos.y - math.sin(Phy) * _pos.x,
		-math.sin(Phy) * _pos.y+ math.cos(Phy) * _pos.x
	)
end

function CameraControl:Translate(_deltaX, _deltaY)
	local toWorld = self:CameraToWorld(Vector2(_deltaX, _deltaY))
	local rawZ = toWorld.y
	local rawX = toWorld.x
	local distance = Vector2(rawX, rawZ).Magnitude
	local dir = Vector2(rawX, rawZ).Normalized
	distance = math.min(distance, moveRange)
	local newX = distance * dir.x
	local newZ = distance * dir.y
	lookAtPoint = lookAtPoint + Vector3(newX, 0, newZ)
	needUpdate = true
end

function CameraControl:Rotate(_deltaTheta, _deltaPhy)
	Theta = math.clamp(Theta + _deltaTheta, 0, 89 * deg2rad)
	Phy = Phy + _deltaPhy
	needUpdate = true
end

function CameraControl:Zoom(_deltaR)
	R = math.clamp(R + _deltaR, 0.5, moveRange)
	needUpdate = true
end

function CameraControl:LookAt(_pos)
	--TODO
	lookAtPoint = _pos
	startPoint = _pos
	R = 3
	Theta =  60 * deg2rad
	needUpdate = true
end

function CameraControl:SetSeat(_i, _n)
	self:Reset()
	Phy = math.pi * 2 / _n * (_n - _i)
end

return CameraControl