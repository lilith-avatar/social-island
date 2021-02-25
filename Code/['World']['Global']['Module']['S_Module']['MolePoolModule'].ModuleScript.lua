---地鼠对象池
---@module MolePool
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local MolePool = class("MolePool")
local MoleClass = class("Mole")

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
    self:CreateModel(_moleId, _name, _parent)
end

function MoleClass:DataReset(_moleId)
    self.id = _moleId
    self.type = Config.MoleConfig[_moleId].Type
end

function MoleClass:Reset(_moleId, _parent)
    self:CreateModel(_moleId, nil, _parent)
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

function MoleClass:IsDestroy()
    if self.state == MoleStateEnum.Destroy then
        return true
    else
        return false
    end
end

return MolePool
