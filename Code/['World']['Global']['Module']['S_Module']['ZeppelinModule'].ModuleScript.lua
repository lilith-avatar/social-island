--- 热气球交互模块
--- @module Zeppelin Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local ZeppelinModule, this = ModuleUtil.New("ZeppelinModule", ServerBase)

--- 变量声明
-- 热气球对象池
local zeppelinObjPool = {}

-- 热气球乘客表
local zeppelinPassengerTable = {}

-- 站台区域
local stationArea = nil

-- 站台等待乘客表
local stationPassengerTable = {}

-- 终点区域
local desArea = nil

-- 移动路径表
local pathwayPointTable = {}

-- 最小出发间隔
local minDepartureInterval = 20

-- 计时器
local timer = {}

-- 乘坐按钮
local getOnBtn = nil

-- 倒计时UI
local cdUI = nil

--- 初始化
function ZeppelinModule:Init()
    print("ZeppelinModule:Init")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function ZeppelinModule:NodeRef()
    cdUI = localPlayer.Local.ZeppelinGUI.GUI.Figure.CDBGImg
    getOnBtn = localPlayer.Local.ZeppelinGUI.GUI.Figure.GetOnBtn
end

--- 数据变量初始化
function ZeppelinModule:DataInit()
    for i = 1, 5 do
    end
    zeppelinObjPool = {}
end

--- 节点事件绑定
function ZeppelinModule:EventBind()
end

return ZeppelinModule
