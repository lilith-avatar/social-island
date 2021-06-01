---@module GuiMap
---@copyright Lilith Games, Avatar Team
---@author Changoo Wu
local GuiClock, this = ModuleUtil.New('GuiClock', ClientBase)

local gui, ico,txt
local FRESH_TIME = 0.2
local tt = 0

---初始化函数
function GuiClock:Init()
    --print('[GuiClock] Init()')
    this:NodeDef()
    this:DataInit()
    this:EventBind()
	this:InitIco()
end

---节点定义
function GuiClock:NodeDef()
    gui = localPlayer.Local.ControlGui.Menu.ClockBg
    ico = gui.Ico
	txt = gui.TimeTxt
end

---数据初始化
function GuiClock:DataInit()

end

---事件绑定
function GuiClock:EventBind()
end


function GuiClock:InitIco()
	if math.floor(world.Sky.ClockTime)< 6 or math.floor(world.Sky.ClockTime) > 20 then
		ico.Texture = ResourceManager.GetTexture('UI/clock/Common_Img_A_Midnight')
	elseif	math.floor(world.Sky.ClockTime)< 10 then
		ico.Texture = ResourceManager.GetTexture('UI/clock/Common_Img_A_EarlyMorning')
	elseif math.floor(world.Sky.ClockTime)< 17 then
		ico.Texture = ResourceManager.GetTexture('UI/clock/Common_Img_A_Morning')
	elseif math.floor(world.Sky.ClockTime)< 20 then
		ico.Texture = ResourceManager.GetTexture('UI/clock/Common_Img_A_Night')
	end
end

---Update函数
function GuiClock:Update(_dt)
	tt = tt + _dt
	if tt > FRESH_TIME then
		txt.Text = math.floor(world.Sky.ClockTime) .. ":"..GuiClock:CheckFormat(world.Sky.ClockTime)
		tt = 0
	end
end

--整数转60进制
function GuiClock:CheckFormat(_clockTime)
	if math.floor(_clockTime) == 0 then
		if string.len(tostring(tonumber(_clockTime* 60))) == 1 then
			return '0'..tostring(math.floor(tonumber(_clockTime* 60)))
		else
			return tostring(math.floor(tonumber(_clockTime* 60)))
		end
	elseif string.len(tostring(math.floor(math.fmod( _clockTime, math.floor(_clockTime) )* 60))) == 1 then
		return '0'..tostring(math.floor(math.fmod( _clockTime, math.floor(_clockTime) )* 60))
	else
		return tostring(math.floor(math.fmod( _clockTime, math.floor(_clockTime) )* 60))
	end
end

function GuiClock:SycnTimeCEventHandler(_clock)
	if _clock == 6 then
		ico.Texture = ResourceManager.GetTexture('UI/clock/Common_Img_A_EarlyMorning')
	elseif _clock == 10 then
		ico.Texture = ResourceManager.GetTexture('UI/clock/Common_Img_A_Morning')
	elseif _clock == 17 then
		ico.Texture = ResourceManager.GetTexture('UI/clock/Common_Img_A_Night')
	elseif _clock == 20 then
		ico.Texture = ResourceManager.GetTexture('UI/clock/Common_Img_A_Midnight')
	end
end

return GuiClock
