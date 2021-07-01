---@module GameFlow --客户端的入口出口模块
---@copyright Lilith Games, Avatar Team
---@author An Dai
local GameFlow = ModuleUtil.New('GameFlow', ClientBase)
local this = GameFlow

---进入桌游相机模式
---@param _pos Vector3 进入时候默认看向的点
function GameFlow:Init()
	self.inGame = false
end

---进入桌游相机模式
---@param _pos Vector3 进入时候默认看向的点
function GameFlow:Enter(_pos)
	if not _pos then
		return
	end
	if(self.inGame) then
		return
	end
	self.inGame = true
	self:OutClear()
	self.lastCamera = world.CurrentCamera
	world.CurrentCamera = localPlayer.Local.Independent.TableCam
	localPlayer.Local.MainGui:SetActive(true)
	--localPlayer.Local.ScreenGUI1:SetActive(true)
	PlayerInteract:InitListener()
	CameraControl:LookAt(_pos)
end

function GameFlow:Quit()
	if(not self.inGame) then
		return
	end
	world.CurrentCamera = self.lastCamera
	self.lastCamera = nil
	localPlayer.Local.MainGui:SetActive(false)
	--localPlayer.Local.ScreenGUI1:SetActive(false)
	PlayerInteract:DisConnect()
	self.inGame = false
	self:OutRecover()
end

---对应外界游戏逻辑
function GameFlow:OutClear()
	PlayerCtrl:StartTTS()

end

function GameFlow:OutRecover()
	PlayerCtrl:QuitTTS()

end

return GameFlow
