--- 角色动画管理模块
--- @module PlayerAnim Mgr, client-side
--- @copyright Lilith Games, Avatar Team
--- @author Dead Ratman
local PlayerAnimMgr, this = ModuleUtil.New('PlayerAnimMgr', ClientBase)
local clipNodes = {
    [0] = {},
    [1] = {},
    [2] = {}
}
--- 初始化
function PlayerAnimMgr:Init()
    print('PlayerAnimMgr:Init')
    this:NodeRef()
    this:DataInit()
    this:EventBind()
end

--- 节点引用
function PlayerAnimMgr:NodeRef()
end

--- 数据变量初始化
function PlayerAnimMgr:DataInit()
    this:SetLayer()
end

--- 节点事件绑定
function PlayerAnimMgr:EventBind()
end

--导入动画资源
function PlayerAnimMgr:ImportAnimation(_anims, _path)
    for _, animaName in pairs(_anims) do
        ResourceManager.GetAnimation(_path .. animaName)
    end
end

--设置动作层级，layer为0时为全身动作，layer为1时仅播放上半身，layer为2时仅播放下半身
function PlayerAnimMgr:SetLayer()
    local skeleton = {}
    skeleton['Root'] = {'Root', 'Bone01', 'Bone_Pelvis'}

    skeleton['Upper'] = {'Bone_Spine', 'Bone_Spine1', 'Bone_Neck', 'Bone_Head'}

    skeleton['Lower'] = {
        'Bone_L_Thigh',
        'Bone_L_Calf',
        'Bone_L_Foot',
        'Bone_L_Toe0',
        'Bone_R_Thigh',
        'Bone_R_Calf',
        'Bone_R_Foot',
        'Bone_R_Toe0'
    }

    skeleton['RightHand'] = {
        'Bone_R_Clavicle',
        'Bone_R_UpperArm',
        'Bone_R_Forearm',
        'Bone_R_Hand',
        'Bone_R_Finger0',
        'Bone_R_Finger01',
        'Bone_R_Finger1',
        'Bone_R_Finger11'
    }

    skeleton['LeftHand'] = {
        'Bone_L_Clavicle',
        'Bone_L_UpperArm',
        'Bone_L_Forearm',
        'Bone_L_Hand',
        'Bone_L_Finger0',
        'Bone_L_Finger01',
        'Bone_L_Finger1',
        'Bone_L_Finger11'
    }

    for k, v in pairs(skeleton) do
        for _, v1 in pairs(v) do
            if k ~= 'Upper' and k ~= 'RightHand' and k ~= 'LeftHand' then
                localPlayer.Avatar:SetBoneBlendMask(1, v1, false)
            end
            if k ~= 'Lower' then
                localPlayer.Avatar:SetBoneBlendMask(2, v1, false)
            end
        end
    end
end

--创建一个包含单个动作的混合空间节点,并设置动作速率
function PlayerAnimMgr:CreateSingleClipNode(_animName, _speed, _nodeName, _gender)
    _gender = _gender or 0
    print(_gender, table.dump(clipNodes))
    local node = localPlayer.Avatar:AddBlendSpaceSingleNode(false)
    node:AddClipSingle(_animName, _speed or 1)
    if _nodeName then
        clipNodes[_gender][_nodeName] = node
    end
    return node
end

--创建一个一维混合空间节点并附带一个参数
--[[anims = 
		{
			{"anim_woman_idle_01", 0.0, 1.0},
			{"anim_woman_walkfront_01", 0.25, 1.0}
		}
]]
function PlayerAnimMgr:Create1DClipNode(_anims, _param, _nodeName, _gender)
    _gender = _gender or 0
    local node = localPlayer.Avatar:AddBlendSpace1DNode(_param)
    for _, v in pairs(_anims) do
        node:AddClip1D(v[1], v[2], v[3] or 1)
    end
    if _nodeName then
        clipNodes[_gender][_nodeName] = node
    end
    return node
end

function PlayerAnimMgr:Create2DClipNode(_anims, _param1, _param2, _nodeName, _gender)
    _gender = _gender or 0
    local node = localPlayer.Avatar:AddBlendSpace2DNode(_param1, _param2)
    for _, v in pairs(_anims) do
        node:AddClip2D(v[1], v[2], v[3], v[4] or 1)
    end
    if _nodeName then
        clipNodes[_gender][_nodeName] = node
    end
    return node
end

function PlayerAnimMgr:Play(_animNode, _layer, _weight, _transIn, _transOut, _isInterrupt, _isLoop, _speedScale)
    local node = nil
    if type(_animNode) == 'string' then
        node = clipNodes[localPlayer.Avatar.Gender][_animNode] or clipNodes[0][_animNode]
    else
        node = _animNode
    end
    localPlayer.Avatar:PlayBlendSpaceNode(
        node,
        _layer,
        _weight or 1,
        _transIn or 0,
        _transOut or 0,
        _isInterrupt or true,
        _isLoop or false,
        _speedScale or 1
    )
end

function PlayerAnimMgr:PlayAnimationEventHandler(
    _animName,
    _layer,
    _weight,
    _transIn,
    _transOut,
    _isInterrupt,
    _isLoop,
    _speedScale)
    this:CreateSingleClipNode(_animName, 1, _animName)
    this:Play(
        _animName,
        _layer or 0,
        _weight or 1,
        _transIn or 0.2,
        _transOut or 0.2,
        _isInterrupt or true,
        _isLoop or false,
        _speedScale or 1
    )
end

function PlayerAnimMgr:Update(dt)
end

return PlayerAnimMgr
