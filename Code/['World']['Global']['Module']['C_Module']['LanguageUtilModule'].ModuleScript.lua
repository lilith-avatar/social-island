--- 语言包模块：根据游戏内语言设置返回对应的语言文本
--- @module  LanguageUtil, Client-side
--- @copyright Lilith Games, Avatar Team
--- @author Xiexy, Yuancheng Zhang
local LanguageUtil, this = ModuleUtil.New('LanguageUtil', ClientBase)
local lang = Config.GlobalSetting.DefaultLanguage
local defaultLang = Const.LanguageEnum.CHS
local valid = FrameworkConfig.DebugMode and false -- 打开参数校验

local CHAR_SIZE = 0.8

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

local function utf8Len(str)
    local len = #str
    local left = 0
    local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    local length = 0
    local startNum = 1
    local wordLen = 0
    local strTb = {}
    while left ~= len do
        local temp = string.byte(str, startNum)
        --将字符串的某个字符转换成十六进制
        local i = #arr
        while arr[i] do
            if temp >= arr[i] then
                left = left + i
                break
            end
            i = i - 1
        end
        length = length + 1

        wordLen = i + wordLen
        local tmpString = string.sub(str, startNum, wordLen)
        startNum = startNum + i
        strTb[#strTb + 1] = tmpString
    end

    return length, strTb
end

--- 文字自适应
function LanguageUtil.TextAutoSize(_textUI, _minSize, _maxSize)
    _textUI:SetActive(false)
    local textLength, textTable = utf8Len(_textUI.Text)
    local maxSize = _maxSize or math.floor(_textUI.FinalSize.y / CHAR_SIZE)
    local minSize = _minSize or 10
    if maxSize > math.floor(_textUI.FinalSize.y / CHAR_SIZE) then
        maxSize = math.floor(_textUI.FinalSize.y / CHAR_SIZE)
    end

    local minUILenth, maxUILenth = 0, 0
    --计算最小/最大字号UI的实际长度
    minUILenth =
        math.floor(_textUI.FinalSize.x / (CHAR_SIZE * minSize)) *
        math.ceil(math.floor(_textUI.FinalSize.y / (CHAR_SIZE * minSize)) / 2) *
        minSize
    maxUILenth =
        math.floor(_textUI.FinalSize.x / (CHAR_SIZE * maxSize)) *
        math.ceil(math.floor(_textUI.FinalSize.y / (CHAR_SIZE * maxSize)) / 2) *
        maxSize

    local minStrLenth, maxStrLenth, sizeLength = 0, 0, 0
    --计算最小/最大字号字符串的实际长度
    for i = 1, textLength do
        --print(textTable[i], string.byte(textTable[i]))
        if string.byte(textTable[i]) > 127 then
            sizeLength = sizeLength + CHAR_SIZE * 2
        else
            sizeLength = sizeLength + CHAR_SIZE
        end
    end
    minStrLenth = sizeLength * minSize
    maxStrLenth = sizeLength * maxSize
    --print('文字自适应', _textUI, maxSize, minSize, textLength)
    --print(minUILenth, maxUILenth, minStrLenth, maxStrLenth)
    if maxUILenth > maxStrLenth then --最大字号
        _textUI.FontSize = maxSize
    elseif minUILenth < minStrLenth then --最小字号
        _textUI.FontSize = minSize
        local lenth = 0
        for i = 1, textLength do
            if string.byte(_textUI.Text, i) > 127 then
                lenth = lenth + CHAR_SIZE * minSize * 2
            else
                lenth = lenth + CHAR_SIZE * minSize
            end
            if lenth + CHAR_SIZE * 3 > minUILenth then --超出文本框变为省略号
                _textUI.Text = string.sub(_textUI.Text, 1, i) .. '...'
                break
            end
        end
    else --自适应字号
        local curSize = math.floor((minUILenth / minStrLenth) * minSize)
        local uiSize = 0
        local textSize = curSize * sizeLength
        if curSize > maxSize then
            curSize = maxSize
        end

        while true do
            uiSize =
                (math.floor(_textUI.FinalSize.x / (CHAR_SIZE * curSize)) > 0 and
                math.floor(_textUI.FinalSize.x / (CHAR_SIZE * curSize)) or
                1) *
                (math.ceil(math.floor(_textUI.FinalSize.y / (CHAR_SIZE * curSize)) / 2) > 0 and
                    math.ceil(math.floor(_textUI.FinalSize.y / (CHAR_SIZE * curSize)) / 2) or
                    1) *
                curSize
            textSize = curSize * sizeLength
            --print('ui x', math.floor(_textUI.FinalSize.x / (CHAR_SIZE * curSize)))
            --print('ui y', math.ceil(math.floor(_textUI.FinalSize.y / (CHAR_SIZE * curSize)) / 2))
            --print(uiSize, textSize, sizeLength, curSize)
            if uiSize > textSize then
                _textUI.FontSize = curSize
                
                break
            end
            curSize = curSize - 1
        end
    end
    _textUI:SetActive(true)
    --print('文字自适应', _textUI, _textUI.FontSize)
end

--- 根据ID返回当前游戏语言对应的文本信息，并设置文字大小自适应
function LanguageUtil.SetText(_textUI, _id, _isAuto, _minSize, _maxSize)
    _textUI:SetActive(false)
    _textUI.Text = this.GetText(_id)
    if _isAuto then
        this.TextAutoSize(_textUI, _minSize, _maxSize)
    end
    _textUI:SetActive(true)
end

return LanguageUtil
