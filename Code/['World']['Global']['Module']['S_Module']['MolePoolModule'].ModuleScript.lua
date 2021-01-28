---地鼠对象池
---@module MolePool
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local MolePool = class("MolePool")
local MoleClass = class("Mole")
local MoleStateEnum = {
    Appearing = 1,
    Keeping = 2,
    Disapearing = 3,
    Destroy = 4
}

local Config = Config

--**************** 对象池方法 ********************
---初始化函数
function MolePool:initialize(_objName, poolSize, _objId)
    self.pool = {}
    self.maxSize = poolSize
    self.objName = _objName
    self.objId = _objId
    print("[MolePool] initialize()", _objName, poolSize)
end

function MolePool:Destroy(_obj)
    if #self.pool == self.maxSize then
        _obj:Destroy(true)
    else
        table.insert(self.pool, _obj)
        _obj:Destroy(false)
    end
end

function MolePool:Create(_parent, _name)
    local mole
    if self.pool[1] then
        mole = self.pool[1]:Reset(nil, _parent)
        invoke(
            function()
                table.remove(self.pool, 1)
            end,
            wait()
        )
    else
        mole = MoleClass:new(self.objId, _name, _parent)
    end
    return mole
end

--*************** 地鼠对象 ***********************
function MoleClass:initialize(_moleId, _name, _parent)
    self.type = Config.MoleConfig[_moleId].Type
    self.moleId = _moleId
    self.timer = 0
    self.beatTime = Config.MoleConfig[_moleId].HitNum
    self.state = MoleStateEnum.Appearing
    self.mesh = nil
    self:CreateModel(_moleId, _name, _parent)
    --开始计时并表现
end

function MoleClass:Destroy(_isRealDestroy)
    self.state = MoleStateEnum.Destroy
    if _isRealDestroy then
        self.model:Destroy()
        self = nil
    else
        self.model:SetActive(false)
    end
end

function MoleClass:Reset(_name, _parent)
    self:ResetData()
    self:CreateModel(self.moleId, _name, _parent)
    self:ChangeMesh()
    --开始计时并表现
    return self
end

function MoleClass:ResetData()
    self.beatTime = Config.MoleConfig[self.moleId].HitNum
    self.timer = 0
    self.state = MoleStateEnum.Appearing
    self.mesh = nil
end

function MoleClass:CreateModel(_moleId, _name, _parent)
    if self.model then
        self.model.Parent = _parent
        self.model.Position, self.model.Rotation = _parent.Position, _parent.Rotation
        self.model:SetActive(true)
    else
        self.model =
            world:CreateInstance(
            Config.MoleConfig[_moleId].Archetype,
            _name,
            _parent,
            _parent.Position,
            _parent.Rotation
        )
    end
end

function MoleClass:BeBeaten(_player)
    self.beatTime = self.beatTime - 1
    if self.beatTime <= 0 then
        -- TODO: 播动画
        self.state = MoleStateEnum.Destroy
        NetUtil.Fire_C(
            "AddScoreAndBoostEvent",
            _player,
            Config.MoleConfig[self.moleId].Type,
            Config.MoleConfig[self.moleId].Reward,
            Config.MoleConfig[self.moleId].BoostReward
        )
    else
        self:ChangeMesh()
    end
end

function MoleClass:ChangeMesh()
    for _,v in pairs(self.model:GetChildren()) do
        v:SetActive(false)
        if v.Name == Config.MoleConfig[self.moleId].BeatenArch[self.beatTime] then
            v:SetActive(true)
        end
    end
end

function MoleClass:IsDestroy()
    if self.state == MoleStateEnum.Destroy then
        return true
    else
        return false
    end
end

function MoleClass:StartTimer(dt)
    self.timer = self.timer + dt
    if self.state == MoleStateEnum.Destroy then
        return
    end
    if self.state == MoleStateEnum.Appearing then
        if self.timer >= Config.MoleConfig[self.moleId].AppearTime then
            --停止播放动作
            self.timer = 0
            self.state = MoleStateEnum.Keeping
        end
    end
    if self.state == MoleStateEnum.Keeping then
        if self.timer >= Config.MoleConfig[self.moleId].AppearTime then
            --播放动作
            self.timer = 0
            self.state = MoleStateEnum.Disapearing
        end
    end
    if self.state == MoleStateEnum.Disapearing then
        if self.timer >= Config.MoleConfig[self.moleId].AppearTime then
            --销毁
            self.timer = 0
            self.state = MoleStateEnum.Destroy
        end
    end
end

return MolePool
