---@module ChairClass
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local ChairClass = class("ChairClass")
local Config = Config

-- 状态枚举
local StateEnum = {
}

-- 类型枚举
local TypeEnum = {
    Normal = 1,
    QTE = 2
}

---椅子的构造函数
---@param _type string
---@param _pos Vector3
--- @param _rot EulerDegree
function ChairClass:initialize(_type, _id, _arch, _parent, _pos, _rot)
end

function ChairClass:CommonDataInit(_arch, _parent, _pos, _rot, _id)
end

function ChairClass:Sit(_player)
end

function ChairClass:Stand()
end

--********************* qte摇摇椅 *************************
function ChairClass:Fly()
end

function ChairClass:Flying(dt)
end

function ChairClass:SetSpeed(_dir, _speed)
end

function ChairClass:Return()
end

function ChairClass:QteUpdate(dt)
end

return ChairClass
