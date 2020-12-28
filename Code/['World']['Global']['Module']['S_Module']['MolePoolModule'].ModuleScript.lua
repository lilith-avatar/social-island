---地鼠对象池
---@module MolePool
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local MolePool = class("MolePool")

---初始化函数
function MolePool:initialize(_objName, poolSize)
    self.pool = {}
    self.maxSize = poolSize
    self.objName = _objName
end

function MolePool:Destroy(_obj)
    if #self.pool == self.maxSize then
        _obj:Destroy()
    else
        table.insert(self.pool, _obj)
        _obj:SetActive(false)
    end
end

function MolePool:Create(_parent, _pos, _rot)
    local mole
    if self.pool[1] then
        self.pool[1].Position, self.pool[1].Rotation = _pos, _rot
        self.pool[1]:SetParentTo(_parent, _pos, _rot)
        self.pool[1]:SetActive(true)
        mole = self.pool[1]
        table.remove(self.pool, 1)
        return mole
    else
        mole = world:CreateInstance(self.objName, self.objName, _parent)
        return mole
    end
end

return MolePool
