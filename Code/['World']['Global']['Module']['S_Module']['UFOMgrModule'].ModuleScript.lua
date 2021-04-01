--- UFO模块
--- @module UFOMgr Module
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local UFOMgr, this = ModuleUtil.New('UFOMgr', ServerBase)

--- 变量声明
--传送门
local portal1, portal2

---UFO
local UFO

local durUFO = 0

local timer = 0

--- 初始化
function UFOMgr:Init()
    print('[UFOMgr] Init()')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function UFOMgr:NodeRef()
    portal1 = world.MiniGames.Game_12_UFO.Portal.Portal1
    portal2 = world.MiniGames.Game_12_UFO.Portal.Portal2
    UFO = world.MiniGames.Game_12_UFO.Outside.UFO
end

--- 数据变量初始化
function UFOMgr:DataInit()
end

--- 节点事件绑定
function UFOMgr:EventBind()
    portal1.OnCollisionBegin:Connect(
        function(_hitObject)
            if _hitObject and _hitObject.Avatar and _hitObject.Avatar.ClassName == 'PlayerAvatarInstance' then
                this:Teleport(_hitObject, portal2.Position + Vector3(math.random(-3, 3), 0, math.random(-3, 3)))
            end
        end
    )
    portal2.OnCollisionBegin:Connect(
        function(_hitObject)
            if _hitObject and _hitObject.Avatar and _hitObject.Avatar.ClassName == 'PlayerAvatarInstance' then
                this:Teleport(_hitObject, portal1.Position + Vector3(math.random(-3, 3), 0, math.random(-3, 3)))
            end
        end
    )
end

--- 开启UFO
function UFOMgr:ActiveUFO()
    durUFO = 120
    UFO:SetActive(true)
    NetUtil.Broadcast('ShowNoticeInfoEvent', '神秘的UFO出现了，天空出现了大量金币', 10, Vector3(54.3585, 66.6861, 24.6156))
end

--- UFO计时
function UFOMgr:UFOCD(dt)
    if durUFO > 0 then
        durUFO = durUFO - dt
        if timer >= 2 then
            NetUtil.Fire_S('SpawnCoinEvent', 'P', UFO.Position + Vector3(0, -10, 0), 500)
            timer = 0
        else
            timer = timer + dt
        end
    elseif durUFO < 0 then
        durUFO = 0
        UFO:SetActive(false)
    end
end

--- 传送
function UFOMgr:Teleport(_player, _pos)
    SoundUtil.Play3DSE(_player.Position, 108)
	SoundUtil.Play3DSE(_pos, 108)
    _player.Position = _pos
end

function UFOMgr:Update(dt)
    this:UFOCD(dt)
end

return UFOMgr
