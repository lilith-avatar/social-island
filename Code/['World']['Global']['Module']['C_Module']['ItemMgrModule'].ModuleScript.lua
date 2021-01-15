---  物品管理模块：
-- @module  ItemMgr
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module ItemMgr

local ItemMgr, this = ModuleUtil.New("ItemMgr", ClientBase)

function ItemMgr:Init()
    print("ItemMgr:Init")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function ItemMgr:NodeRef()
end

--数据变量声明
function ItemMgr:DataInit()
end

--节点事件绑定
function ItemMgr:EventBind()
end

function ItemMgr:Update(dt, tt)
end

return ItemMgr
