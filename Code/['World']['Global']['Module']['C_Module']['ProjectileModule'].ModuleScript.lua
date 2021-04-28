--- 投射物模块
--- @module Projectile, client-side
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local Projectile, this = ModuleUtil.New('Projectile', ClientBase)

--- 初始化
function Projectile:Init()
    print('Projectile:Init')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function Projectile:NodeRef()
end

--- 数据变量初始化
function Projectile:DataInit()
end

--- 节点事件绑定
function Projectile:EventBind()
end

--创建一个可用的投射物
function Projectile:CreateAvailableProjectile(_id, _pos, _rot, _targetPos, _force)
    local projectileConfig = Config.Projectile[_id]
    local projectileObj = this:InstanceProjectile(projectileConfig.ModelName, _pos, _rot)
    this:ShootProjectile(projectileObj, _targetPos, _force)
    NetUtil.Fire_S('SProjectileShootEvent', localPlayer, _id, projectileObj)
    NetUtil.Fire_C('CProjectileShootEvent', localPlayer, _id, projectileObj)
    projectileObj.OnCollisionBegin:Connect(
        function(_hitObj, _hitPoint)
            if _hitObj ~= localPlayer and _hitObj.ClassName == 'PlayerInstance' and _hitObj.Avatar then
                if _hitObj.Avatar.ClassName == 'PlayerAvatarInstance' then
                    --NetUtil.Fire_S("SProjectileHitEvent", localPlayer, _id, projectileObj, _hitObj, _hitPoint)
                    --NetUtil.Fire_C("CProjectileHitEvent", localPlayer, _id, projectileObj, _hitObj, _hitPoint)
                    local hitPlayers = this:GetPlayersByRange(_hitObj, _hitPoint, projectileConfig.HitRange)
                    this:AddForceToHitPlayer(
                        projectileObj,
                        projectileConfig.HitType,
                        projectileConfig.AddForceToHitPlayer,
                        _hitPoint,
                        hitPlayers
                    )
                    this:HitBuff(
                        hitPlayers,
                        {
                            addBuffID = projectileConfig.HitAddBuffID,
                            addDur = projectileConfig.HitAddBuffDur,
                            removeBuffID = projectileConfig.HitRemoveBuffID
                        }
                    )
                    this:PlayHitSoundEffect(_hitPoint, projectileConfig.HitSoundID, projectileConfig.HitEffectName)
                    projectileObj:Destroy()
                end
            elseif _hitObj.AnimalID and projectileConfig.Hunt then
                CloudLogUtil.UploadLog(
                    'battle_actions',
                    'hit_event',
                    {hit_target_id = 2, target_detail = _hitObj, attack_target = localPlayer, attack_type = 2}
                )
                NetUtil.Fire_S('SProjectileHitEvent', localPlayer, _id, projectileObj, _hitObj, _hitPoint)
                NetUtil.Fire_C('CProjectileHitEvent', localPlayer, _id, projectileObj, _hitObj, _hitPoint)
                _hitObj.AnimalDeadEvent:Fire()
                this:PlayHitSoundEffect(_hitPoint, projectileConfig.HitSoundID, projectileConfig.HitEffectName)
                projectileObj:Destroy()
            elseif _hitObj.Name == 'ArrowTargetCol' then
                CloudLogUtil.UploadLog(
                    'battle_actions',
                    'hit_event',
                    {hit_target_id = 3, target_detail = _hitObj.Parent, attack_target = localPlayer, attack_type = 2}
                )
                NetUtil.Fire_S('SProjectileHitEvent', localPlayer, _id, projectileObj, _hitObj, _hitPoint)
                NetUtil.Fire_C('CProjectileHitEvent', localPlayer, _id, projectileObj, _hitObj, _hitPoint)
                _hitObj.Parent.ArrowTargetEvent:Fire(_hitPoint)
                this:PlayHitSoundEffect(_hitPoint, projectileConfig.HitSoundID, projectileConfig.HitEffectName)
                projectileObj:Destroy()
            end
        end
    )
    return projectileObj
end

--实例化投射物
function Projectile:InstanceProjectile(_archetType, _pos, _rot)
    local projectile = world:CreateInstance(_archetType, _archetType, world, _pos, _rot)
    return projectile
end

--发射投射物
function Projectile:ShootProjectile(_projectile, _targetPos, _force)
    _projectile.Forward = _targetPos - _projectile.Position
    _projectile.LinearVelocity = _projectile.Forward * _force
end

--获取命中范围内的玩家
function Projectile:GetPlayersByRange(_hitObj, _hitPos, _range)
    local players = {}
    for k, v in pairs(world:FindPlayers()) do
        if _range > 0 then
            if (_hitPos - v.Position).Magnitude <= _range then
                players[#players + 1] = v
            end
        else
            players[#players + 1] = _hitObj
            return players
        end
    end
    return players
end

--对命中玩家施加力
function Projectile:AddForceToHitPlayer(_projectile, _type, _force, _pos, _players)
    for k, v in pairs(_players) do
        if _type == 1 then
            v.LinearVelocity =
                Vector3(_projectile.LinearVelocity.x, 0, _projectile.LinearVelocity.z).Normalized * _force
        elseif _type == 2 then
            v.LinearVelocity = (v.Position - _pos).Normalized * _force
        end
    end
end

--命中增加/移除buff
function Projectile:HitBuff(_players, _buffData)
    for k, v in pairs(_players) do
        CloudLogUtil.UploadLog(
            'battle_actions',
            'hit_event',
            {hit_target_id = 1, target_detail = v, attack_target = localPlayer, attack_type = 2}
        )
        NetUtil.Fire_S('SPlayerHitEvent', localPlayer, v, _buffData)
    end
end

--播放命中音效和特效
function Projectile:PlayHitSoundEffect(_pos, _seID, _effect)
    SoundUtil.Play3DSE(_pos, _seID)
    local effect = world:CreateInstance(_effect, _effect .. 'Instance', world, _pos)
    invoke(
        function()
            effect:Destroy()
        end,
        1
    )
end

function Projectile:Update(dt)
end

return Projectile
