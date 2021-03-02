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
function ChairClass:initialize()
end

function ChairClass:CommonDataInit()
end

function ChairClass:Sit()
end

function ChairClass:Stand()
end

--********************* qte摇摇椅 *************************
function ChairClass:Fly()
end

function ChairClass:Flying()
end

function ChairClass:SetSpeed()
end

function ChairClass:Return()
end

function ChairClass:QteUpdate()
end

return ChairClass
