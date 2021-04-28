---  望远镜UI模块：
-- @module  GuiTelescope
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module GuiTelescope

local GuiTelescope, this = ModuleUtil.New('GuiTelescope', ClientBase)

local gui

local zoomMultiple = 1

function GuiTelescope:Init()
    print('GuiTelescope:Init')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function GuiTelescope:NodeRef()
    gui = localPlayer.Local.TelescopeGUI
end

--数据变量声明
function GuiTelescope:DataInit()
end

--节点事件绑定
function GuiTelescope:EventBind()
    gui.Panel.ZoomInBtn.OnClick:Connect(
        function()
            if zoomMultiple >= 0.2 then
                zoomMultiple = zoomMultiple - 0.1
                this:CamZoom(zoomMultiple)
            end
        end
    )
    gui.Panel.ZoomOutBtn.OnClick:Connect(
        function()
            if zoomMultiple <= 1.5 then
                zoomMultiple = zoomMultiple + 0.1
                this:CamZoom(zoomMultiple)
            end
        end
    )
    gui.Panel.LeaveBtn.OnClick:Connect(
        function()
            NetUtil.Fire_S('LeaveInteractSEvent', localPlayer, 14)
            NetUtil.Fire_C('LeaveInteractCEvent', localPlayer, 14)
        end
    )
end

--相机缩放
function GuiTelescope:CamZoom(_multiple)
    PlayerCam.fpsCam.FieldOfView = 30 * _multiple
end

--[[function GuiTelescope:InteractCEventHandler(_id)
    if _id == 14 then
        NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer, 14)
        NetUtil.Fire_C('SetCurCamEvent', localPlayer, PlayerCam.fpsCam)
    end
end]]

function GuiTelescope:LeaveInteractCEventHandler(_id)
    if _id == 14 then
        NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
        NetUtil.Fire_C('SetCurCamEvent', localPlayer)
        zoomMultiple = 1
        this:CamZoom(zoomMultiple)
    end
end

return GuiTelescope
