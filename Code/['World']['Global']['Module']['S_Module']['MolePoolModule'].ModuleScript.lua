---地鼠对象池
---@module MolePool
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local MolePool = class("MolePool")
local MoleClass = class("Mole")

--**************** 对象池方法 ********************
---初始化函数
function MolePool:initialize(_objName, poolSize)
    self.pool = {}
    self.maxSize = poolSize
    self.objName = _objName
    print("[MolePool] initialize()", _objName, poolSize)
end

function MolePool:Destroy(_obj)
    if #self.pool == self.maxSize then
        _obj:Destroy()
    else
        table.insert(self.pool, _obj)
        _obj:SetActive(false)
    end
end

function MolePool:Create(_parent, _name)
    local mole
    if self.pool[1] then
        self.pool[1].Parent = _parent
        self.pool[1].Position, self.pool[1].Rotation = _parent.Position, _parent.Rotation
        self.pool[1]:SetActive(true)
        mole = table.deepcopy(self.pool[1])
        invoke(
            function()
                table.remove(self.pool, 1)
            end,
            wait()
        )
        return mole
    else
        mole = world:CreateInstance(self.objName, _name, _parent)
        mole.Position, mole.Rotation = _parent.Position, _parent.Rotation
        mole:SetActive(true)
        return mole
    end
end

--*************** 地鼠对象 ***********************
function MoleClass:initialize(_moleId, _name, _parent)
    self:CreateModel(_moleId, _name, _parent)
end

function MoleClass:Reset(_moleId, _name, _parent)
    self:CreateModel(_moleId, _name, _parent)
    return self
end

function MoleClass:ResetData(_moleId)
    self.beatTime = Config.MoleConfig[_moleId].BeatTime
end

function MoleClass:CreateModel(_moleId, _name, _parent)
    if self.model then
        self.model.Parent = _parent
        self.model.Position, self.model.Rotation = _parent.Position, _parent.Rotation
        self.model:SetActive(true)
    else
        self.model = world:CreateInstance(Config.MoleConfig[_moleId].Archetype, _name, _parent, _parent.Position, _parent.Rotation)
    end
end

function MoleClass:BeBeaten()
    if self.beatTime <= 0 then
        --TODO: 对象池摧毁
    else
        --TODO: 更换模型
    end
end

return MolePool
