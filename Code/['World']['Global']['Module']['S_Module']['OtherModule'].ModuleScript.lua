--- 其他杂项
--- @module Other
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang, Dead Ratman
local Other, this = ModuleUtil.New('Other', ServerBase)

--! 初始化

function Other:Init()
    --print('[Other] Init()')
    SoundUtil.Init(Config.Sound)
    SoundUtil.InitAudioSource()
end

--! Event handlers

-- 玩家受伤事件
function Other:SPlayerHitEventHandler(_attackPlayer, _hitPlayer, _data)
    if _hitPlayer.Avatar.ClassName == 'PlayerAvatarInstance' then
        print('玩家受伤事件')
        NetUtil.Fire_C('CPlayerHitEvent', _hitPlayer, _data)
    end
end

-- 播放全局音效
function Other:SPlayEffectEventHandler(_id, _pos, _playerIndex)
    NetUtil.Broadcast('PlayEffectEvent', _id, _pos, _playerIndex)
end

return Other
