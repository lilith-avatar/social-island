--- NPC对决module
--- @module NpcBattle
--- @copyright Lilith Games, Avatar Team
--- @author Lin
local NpcBattle, this = ModuleUtil.New('NpcBattle', ClientBase)

local npcGui
-- Cache
local Config = Config

function NpcBattle:Init()
    print('[NpcBattle] Init()')
    self:InitData()
end

function NpcBattle:InitData()
    npcGui = localPlayer.Local.NpcGui
    this.RED_BAR = ResourceManager.GetTexture('Internal/Blood_Red')
    this.GREEN_BAR = ResourceManager.GetTexture('Internal/Blood_Green')
    this.ORANGE_BAR = ResourceManager.GetTexture('Internal/Blood_Orange')
end

-------------------以下为NPC宠物相关
--修改携带宠物的值节点数值
function NpcBattle:ReadyBattleEventHandler(_currObj)
    currNpcObj = _currObj
    if currNpcObj then
        print('NPC准备战斗')
        npcGui.Visible = false
        currNpcObj.MonsterVal.Value.Position = currNpcObj.Position - currNpcObj.Forward * 2
        this.currentHealth = math.random(50, 100)
        currNpcObj.HealthVal.Value = this.currentHealth
        currNpcObj.AttackVal.Value = math.random(20, 30)
        this.HealthGUI = currNpcObj.MonsterVal.Value.Cube.HealthGui
        this.HealthGUI:SetActive(true)
        this:HealthChange()
    end
end

function NpcBattle:MBattleEventHandler(_enum, _arg1, _arg2)
    if _enum == 'ShowSkill' then
        local _skillTxt = {'石头', '剪刀', '布'}
        if currNpcObj.BattleVal.Value == -1 then --如果没有决定，则随机一个
            math.randomseed(os.time() - 0.1)
            currNpcObj.BattleVal.Value = math.random(1, 3)
        end
        this.HealthGUI.SkillText.Text = _skillTxt[currNpcObj.BattleVal.Value]
    elseif _enum == 'NewRound' then
        currNpcObj.BattleVal.Value = -1
    elseif _enum == 'NPCBeHit' then
        invoke(
            function()
                currNpcObj.HealthVal.Value = math.max(0, currNpcObj.HealthVal.Value - _arg1)
                local _manaBall = world:CreateObject('Sphere', 'Ball', world, _arg2.MonsterVal.Value.Cube.Position)
                _manaBall.Size = Vector3.One * 0.3
                local Tweener =
                    Tween:TweenProperty(
                    _manaBall,
                    {Position = currNpcObj.MonsterVal.Value.Cube.Position},
                    0.5,
                    Enum.EaseCurve.Linear
                )
                Tweener:Play()
                wait(0.5)
                this.HealthGUI.HitText.Text = _arg1
                _manaBall:Destroy()
                this:HealthChange()
                local Tweener = Tween:ShakeProperty(currNpcObj.MonsterVal.Value.Cube, {'LocalPosition'}, 1, 0.1)
                Tweener:Play()
                wait(1)
                this.HealthGUI.HitText.Text = ''
            end
        )
    elseif _enum == 'Over' then
        this.HealthGUI:SetActive(false)
    end
end

-- 血条随生命值颜色改变而改变
function NpcBattle:HealthChange()
    if this.HealthGUI then
        local percent = currNpcObj.HealthVal.Value / this.currentHealth
        if percent >= 0.7 then
            this.HealthGUI.BackgroundImg.HealthBarImg.Texture = this.GREEN_BAR
        elseif percent >= 0.3 then
            this.HealthGUI.BackgroundImg.HealthBarImg.Texture = this.ORANGE_BAR
        else
            this.HealthGUI.BackgroundImg.HealthBarImg.Texture = this.RED_BAR
        end
        this.HealthGUI.BackgroundImg.HealthBarImg.AnchorsX = Vector2(0.05, 0.9 * percent + 0.05)
        this.HealthGUI.BloodText.Text = currNpcObj.HealthVal.Value .. '/' .. this.currentHealth
    end
end

return NpcBattle
