---  武器管理模块：
-- @module  WeaponMgr
-- @copyright Lilith Games, Avatar Team
-- @author Dead Ratman
---@module WeaponMgr

local WeaponMgr, this = ModuleUtil.New("WeaponMgr", ClientBase)

function WeaponMgr:Init()
    --print("WeaponMgr:Init")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--节点引用
function WeaponMgr:NodeRef()
end

--数据变量声明
function WeaponMgr:DataInit()
    this.curWeapon = nil
end

--节点事件绑定
function WeaponMgr:EventBind()
end

function WeaponMgr:Update(dt, tt)
end

return WeaponMgr
