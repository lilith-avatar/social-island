---@module MoleUIMgr
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local MoleUIMgr,this = ModuleUtil.New('MoleUIMgr',ClientBase)

---初始化函数
function MoleUIMgr:Init()
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

---节点定义
function MoleUIMgr:NodeDef()
end

---数据初始化
function MoleUIMgr:DataInit()
end

---事件绑定
function MoleUIMgr:EventBind()
end

---Update函数
function MoleUIMgr:Update()
end

return MoleUIMgr