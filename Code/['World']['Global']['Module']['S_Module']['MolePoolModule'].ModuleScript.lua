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
        mole = self.pool[1]:Reset(nil, _name, _parent)
        -- self.pool[1].Parent = _parent
        -- self.pool[1].Position, self.pool[1].Rotation = _parent.Position, _parent.Rotation
        -- self.pool[1]:SetActive(true)
        -- mole = table.deepcopy(self.pool[1])
        invoke(
            function()
                table.remove(self.pool, 1)
            end,
            wait()
        )
    else
        -- mole = world:CreateInstance(self.objName, _name, _parent)
        -- mole.Position, mole.Rotation = _parent.Position, _parent.Rotation
        -- mole:SetActive(true)
        mole = MoleClass:new(self.objId, _name, _parent)
    end
    return mole
end

--*************** 地鼠对象 ***********************
function MoleClass:initialize(_moleId, _name, _parent)
    self.type = Config.MoleConfig[_moleId].Type
    self.moleId = _moleId
    self.timer = 0
    self.state = MoleStateEnum.Appearing
    self:CreateModel(_moleId, _name, _parent)
    --开始计时并表现
end

function MoleClass:Destroy(_isRealDestroy)
    if _isRealDestroy then
        self.model:Destroy()
        self = nil
    else
        self.model:SetActive(false)
    end
end

function MoleClass:Reset(_name, _parent)
    self:CreateModel(self.moleId, _name, _parent)
    self:ResetData()
    --开始计时并表现
    return self
end

function MoleClass:ResetData()
    self.beatTime = Config.MoleConfig[self.moleId].BeatTime
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

function MoleClass:BeBeaten()
    self.beatTime = self.beatTime - 1
    if self.beatTime <= 0 then
        --TODO: 对象池摧毁
    else
        --TODO: 更换模型
    end
end

function MoleClass:StartTimer()
end

return MolePool
