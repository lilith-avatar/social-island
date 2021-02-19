--- UFO模块
--- @module UFOMgr Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local UFOMgr, this = ModuleUtil.New("UFOMgr", ServerBase)

--- 变量声明
--传送门
local portal1, portal2

--- 初始化
function UFOMgr:Init()
    print("[UFOMgr] Init()")
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function UFOMgr:NodeRef()
    portal1 = world.MiniGames.Game_12_UFO.Portal.Portal1
    portal2 = world.MiniGames.Game_12_UFO.Portal.Portal2
end

--- 数据变量初始化
function UFOMgr:DataInit()
end

--- 节点事件绑定
function UFOMgr:EventBind()
    portal1.OnCollisionBegin:Connect(
        function(_hitObject)
            if _hitObject.ClassName == "PlayerInstance" then
                this:Teleport(_hitObject, portal2.Position + Vector3(math.random(-3, 3), 0, math.random(-3, 3)))
            end
        end
    )
    portal2.OnCollisionBegin:Connect(
        function(_hitObject)
            if _hitObject.ClassName == "PlayerInstance" then
                this:Teleport(_hitObject, portal1.Position + Vector3(math.random(-3, 3), 0, math.random(-3, 3)))
            end
        end
    )
end

--- 传送
function UFOMgr:Teleport(_player, _pos)
    
    _player.Position = _pos
end

function UFOMgr:Update(dt)
end

return UFOMgr
