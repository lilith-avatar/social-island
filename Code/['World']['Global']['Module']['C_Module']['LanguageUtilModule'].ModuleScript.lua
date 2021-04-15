--- 语言包模块：根据游戏内语言设置返回对应的语言文本
--- @module  LanguageUtil, Client-side
--- @copyright Lilith Games, Avatar Team
--- @author Xiexy, Yuancheng Zhang
local LanguageUtil, this = ModuleUtil.New('LanguageUtil', ClientBase)
local lang = Config.GlobalSetting.DefaultLanguage
local defaultLang = Const.LanguageEnum.CHS
local valid = FrameworkConfig.DebugMode and false -- 打开参数校验

local CHAR_SIZE = 1

--- 设置当前语言
function LanguageUtil.SetLanguage(_lang)
    assert(Const.LanguageEnum[_lang], string.format('[LanguageUtil] %s 语言码不存在，请检查ConstModule', _lang))
    print(string.format('[LanguageUtil] 更改当前语言：%s => %s', lang, _lang))
    lang = _lang
end

--- 根据ID返回当前游戏语言对应的文本信息，如果对应语言为空，默认返回'*'+中文内容
-- @param @number _id LanguagePack.xls中的编号
function LanguageUtil.GetText(_id)
    assert(not string.isnilorempty(_id), '[LanguageUtil] 翻译ID为空，请检查策划表和LanguagePack')
    assert(
        Config.LanguagePack[_id],
        string.format('[LanguageUtil] LanguagePack[%s] 不存在对应翻译ID，请检查策划表和LanguagePack', _id)
    )
    local text = Config.LanguagePack[_id][lang]
    if string.isnilorempty(text) then
        text = '*' .. Config.LanguagePack[_id][defaultLang]
    end
    assert(
        not (valid and string.isnilorempty(text)),
        string.format('[LanguageUtil] LanguagePack[%s][%s] 不存在对应语言翻译内容，默认使用中文', _id, lang)
    )
    return text
end

--- 文字自适应
function LanguageUtil.TextAutoSize(_textUI, _minSize)
    local maxSize = math.floor(_textUI.FinalSize.y / CHAR_SIZE)
    local minSize = _minSize or 10

    --[[local maxColumns = math.floor(_textUI.FinalSize.x / (CHAR_SIZE * minSize))
    local maxRows = math.ceil(math.floor(_textUI.FinalSize.y / (CHAR_SIZE * minSize)) / 2)
    local maxAmount = maxColumns * maxRows]]
    local columns, rows = 1, 1

    local minUILenth, maxUILenth = 0, 0
    --计算最小/最大字号UI的实际长度
    minUILenth =
        math.floor(_textUI.FinalSize.x / (CHAR_SIZE * minSize)) *
        math.ceil(math.floor(_textUI.FinalSize.y / (CHAR_SIZE * minSize)) / 2) *
        minSize
    maxUILenth = math.floor(_textUI.FinalSize.x / (CHAR_SIZE * maxSize)) * maxSize

    local minStrLenth, maxStrLenth = 0, 0
    --计算最小/最大字号字符串的实际长度
    for i = 1, string.len(_textUI.Text) do
        if string.byte(_textUI.Text, i) > 127 then
            minStrLenth = minStrLenth + CHAR_SIZE * minSize * 2
            maxStrLenth = maxStrLenth + CHAR_SIZE * maxSize * 2
        else
            minStrLenth = minStrLenth + CHAR_SIZE * minSize
            maxStrLenth = maxStrLenth + CHAR_SIZE * maxSize
        end
    end
    print('文字自适应', _textUI, maxSize, minSize)
    print(minUILenth, maxUILenth, minStrLenth, maxStrLenth)
    if maxUILenth > maxStrLenth then --最大字号
        _textUI.FontSize = maxSize
    elseif minUILenth < minStrLenth then --最小字号
        _textUI.FontSize = minSize
        local lenth = 0
        for i = 1, string.len(_textUI.Text) do
            if string.byte(_textUI.Text, i) > 127 then
                lenth = lenth + CHAR_SIZE * minSize * 2
            else
                lenth = lenth + CHAR_SIZE * minSize
            end
            if lenth + CHAR_SIZE * 3 > minUILenth then
                _textUI.Text = string.sub(_textUI.Text, 1, i) .. '...'
                break
            end
        end
    else --自适应字号
        _textUI.FontSize = math.floor((minUILenth / minStrLenth) * minSize)
    end
    print('文字自适应', _textUI, _textUI.FontSize)
end

return LanguageUtil
