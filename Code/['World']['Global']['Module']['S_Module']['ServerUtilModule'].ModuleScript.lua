--- 服务器相关工具
--- @module Server-side Utilities
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang

local ServerUtil = {}

-- 检查碰撞对象是否为NPC
function ServerUtil.CheckHitObjIsPlayer(_hitObj)
    return _hitObj and _hitObj.ClassName == 'PlayerInstance' and _hitObj.Avatar and
        _hitObj.Avatar.ClassName == 'PlayerAvatarInstance'
end

return ServerUtil
