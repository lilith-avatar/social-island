---@module GuiCook
---@copyright Lilith Games, Avatar Team
---@author Yen Yuan
local GuiCook, this = ModuleUtil.New('GuiCook', ClientBase)

---初始化函数
function GuiCook:Init()
    this:NodeDef()
    this:DataInit()
    this:EventBind()
end

function GuiCook:Test()
    NetUtil.Fire_C('GetItemEvent', localPlayer, 7001)
    NetUtil.Fire_C('GetItemEvent', localPlayer, 7002)
    NetUtil.Fire_C('GetItemEvent', localPlayer, 7003)
    NetUtil.Fire_C('GetItemEvent', localPlayer, 7004)
end

function GuiCook:DataInit()
    this.startUpdate = false
    this.timer = 0
    this.pageIndex = 1
    this.maxPage = 1
    this.UsingMaterial = {} --食材栏中的食材
    this.BagMaterial = {} --背包中的食材
    this.foodLocation = nil

    --* 背包物品显示参数-------------
    this.pageSize = 9

    --* 成品显示页面需要的参数
    this.foodId = nil
    this.totalDesk = 0
    this.remainDesk = 0
    --* 打赏需要的参数
    this.cookUserId = nil

    this.canEat = false
end

function GuiCook:NodeDef()
    this.root = localPlayer.Local.CookGui
    this.gui = this.root.CookPanel
    this.progressPanel = this.root.ProgressPanel
    this.foodPanel = this.root.FoodPanel
    this.detailPanel = this.root.DetailPanel
    --* 背包中食材的slot
    this.slotList = this.gui.DragPanel.SlotPanel:GetChildren()
    --* 显示材料的slot
    this.MaterialSlot = {
        this.gui.MaterialPanel.Material1,
        this.gui.MaterialPanel.Material2,
        this.gui.MaterialPanel.Material3
    }
    --* 进度条的slot
    --* Button------------------
    this.cookBtn = this.gui.MaterialPanel.CookBtn -- 烹饪按钮
    this.closeBtn = this.gui.MaterialPanel.CloseImg.CloseBtn -- 关闭按钮
    this.prevBtn = this.gui.DragPanel.PreBtn -- 上一页按钮
    this.nextBtn = this.gui.DragPanel.NextBtn -- 下一页按钮
    this.eatBtn = this.foodPanel.EatBtn
    this.deskBtn = this.foodPanel.DeskBtn
    --* Text--------------------
    this.pageTxt = this.gui.DragPanel.PageText
    this.titleTxt = this.foodPanel.TitleTxt
    this.numTxt = this.foodPanel.NumTxt
    --* icon--------------------
    this.foodIcon = this.foodPanel.IconImg
    this.detailIcon = this.detailPanel.IconImg
    --* 做饭的进度条
    this.progress = this.progressPanel.ProgressBar.ProgressImg
    --* 吃东西时候的信息ui
    this.detailName = this.detailPanel.TitleTxt
    this.authorName = this.detailPanel.AuthorTxt
    this.detailEatBtn = this.detailPanel.EatBtn
    this.detailReward = this.detailPanel.RewardBtn
    --* 黑幕
    this.black = this.root.Black

    --* 强引导相关
    this.guidePanel = this.root.GuidePanel
    this.guideBox = this.guidePanel.GuideBox
    this.step1 = this.guidePanel.DragPanel
    this.step2 = this.guidePanel.DragPanel.SlotPanel.FoodBgImg1
    this.guideBlack = this.guidePanel.Black
    this.guideMat = this.guidePanel.MaterialPanel
    this.guideDrag = this.guidePanel.DragPanel
    this.guideMatSlot = {
        this.guidePanel.DragPanel.SlotPanel.FoodBgImg1,
        this.guidePanel.DragPanel.SlotPanel.FoodBgImg2,
        this.guidePanel.DragPanel.SlotPanel.FoodBgImg3
    }
    this.guideCookSlot = {
        this.guidePanel.MaterialPanel.Material1,
        this.guidePanel.MaterialPanel.Material2,
        this.guidePanel.MaterialPanel.Material3
    }
    this.guideCook = this.guideMat.CookBtn
end

function GuiCook:EventBind()
    --单元格按键事件绑定
    for k, v in pairs(this.slotList) do
        v.ItemImg.SelectBtn.OnClick:Connect(
            function()
                this:ChooseMaterial(k)
            end
        )
    end
    for k, v in ipairs(this.MaterialSlot) do
        v.ItemImg.SelectBtn.OnClick:Connect(
            function()
                this:CancelMaterial(k)
            end
        )
    end
    this.cookBtn.OnClick:Connect(
        function()
            this:StartCook()
            NetUtil.Fire_C('PlayerCookEvent', localPlayer, this.UsingMaterial)
        end
    )
    this.closeBtn.OnClick:Connect(
        function()
            NetUtil.Fire_S('LeaveInteractSEvent', localPlayer, 26)
            this:HideGui()
        end
    )
    this.eatBtn.OnClick:Connect(
        function()
            CloudLogUtil.UploadLog('cook', 'cook_main_eat', {meal_id = this.foodId, share_slot = this.curShareSlot})
            this:EatFood()
        end
    )
    this.deskBtn.OnClick:Connect(
        function()
            CloudLogUtil.UploadLog('cook', 'cook_main_share', {meal_id = this.foodId, share_slot = this.curShareSlot})
            this:PutOnDesk()
        end
    )
    this.detailEatBtn.OnClick:Connect(
        function()
			local cookerName = world:GetPlayerByUserId(this.cookUserId)
			CloudLogUtil.UploadLog('cook', 'cook_share_eat',{meal_id = this.foodId, customer_uid = localPlayer.UserId, cooker_uid = this.cookUserId,customer_name = localPlayer.Name, cooker_name = this.cookerName})
            this:EatFood()
        end
    )
    this.detailReward.OnClick:Connect(
        function()
			local cookerName = world:GetPlayerByUserId(this.cookUserId)
            CloudLogUtil.UploadLog('pannel_actions', 'window_cookGui_mealGui_yes')
            CloudLogUtil.UploadLog('pannel_actions', 'window_cookGui_payGui_show')
            CloudLogUtil.UploadLog(
                'cook',
                'cook_reward_enter',
				{meal_id = this.foodId, customer_uid = localPlayer.UserId,customer_name=localPlayer.Name, cooker_uid = this.cookUserId,cooker_name =cookerName}
            )
            NetUtil.Fire_C(
                'SliderPurchaseEvent',
                localPlayer,
                27,
                LanguageUtil.GetText(Config.GuiText['CookGui_8'].Txt)
            )
        end
    )
end

function GuiCook:TransItemTable()
    --先清空表
    this.BagMaterial = {}
    for k, v in pairs(Data.Player.bag) do
        if v.count > 0 and Config.Material[k] and Config.Material[k].MaterialType == 'Food' then
            local data = {
                id = k
            }
            table.insert(this.BagMaterial, data)
        end
    end
    table.sort(
        this.BagMaterial,
        function(i1, i2)
            return i1.id < i2.id
        end
    )
end

function GuiCook:ShowUI()
    this:ClearAllMaterial()
    this:TransItemTable()
    this.progressPanel:SetActive(false)
    this.foodPanel:SetActive(false)
    this.detailPanel:SetActive(false)
    this.root:SetActive(true)
    this.gui:SetActive(true)
    this:ClickChangePage(1)
    CloudLogUtil.UploadLog('cook', 'cook_main_enter')
end

function GuiCook:ShowDetail()
    this.progressPanel:SetActive(false)
    this.foodPanel:SetActive(false)
    this.detailPanel:SetActive(true)
    this.gui:SetActive(false)
    this.root:SetActive(true)
    CloudLogUtil.UploadLog('pannel_actions', 'window_cookGui_mealGui_show')
end

function GuiCook:InteractCEventHandler(_gameId)
    if _gameId == 26 then
        --如果是第一次，则开启强引导
        if not Data.Player.notFirstCook then
            this:StartGuide()
        else
            this:ShowUI()
        end
    elseif _gameId == 27 then
		local cookerName = world:GetPlayerByUserId(this.cookUserId)
	    CloudLogUtil.UploadLog(
            'cook',
            'cook_meal_enter',
            {meal_id = this.foodId, customer_uid = localPlayer.UserId,customer_name=localPlayer.Name, cooker_uid = this.cookUserId,cooker_name =cookerName,cur_time = world.Sky.ClockTime}
        )
        if this.canEat then
            this:ShowDetail()
        else
            NetUtil.Fire_C('InsertInfoEvent', localPlayer, '宴会还没有开始，晚上再来吧', 2, false)
        end
    end
end

function GuiCook:PurchaseCEventHandler(_purchaseCoin, _interactID)
    if _interactID == 27 then
        this:HideGui()
		local cookerName = world:GetPlayerByUserId(this.cookUserId)
        CloudLogUtil.UploadLog('pannel_actions', 'window_cookGui_payGui_yes')
        CloudLogUtil.UploadLog(
            'cook',
            'cook_reward_confirm',
            {
				customer_name=localPlayer.Name,
				cooker_name =cookerName,
                meal_id = this.foodId,
                customer_uid = localPlayer.UserId,
                cooker_uid = this.cookUserId,
                reward_num = _purchaseCoin
            }
        )
        NetUtil.Fire_S('FoodRewardEvent', localPlayer.UserId, this.cookUserId, _purchaseCoin)
    end
end

function GuiCook:LeaveInteractCEventHandler(_gameId)
    if _gameId == 26 then
        this:HideGui()
    elseif _gameId == 27 then
        CloudLogUtil.UploadLog('pannel_actions', 'window_cookGui_mealGui_close')
		if this.cookUserId then
			local cookerName = world:GetPlayerByUserId(this.cookUserId)
		end
        CloudLogUtil.UploadLog('cook', 'cook_share_leave',{meal_id = this.foodId, customer_uid = localPlayer.UserId, cooker_uid = this.cookUserId,customer_name = localPlayer.Name, cooker_name = this.cookerName})
    end
end

function GuiCook:HideGui()
    this.root:SetActive(false)
	CloudLogUtil.UploadLog('cook', 'cook_main_leave')
end

function GuiCook:StartCook()
    if #this.UsingMaterial == 0 or not this.UsingMaterial then
        return
    end
    this.foodLocation = nil
    --开始烹饪
    this.gui:SetActive(false)
    --打开进度条
    --this.progressPanel:SetActive(true)
    --this.startUpdate = true
    NetUtil.Fire_S('PotShakeEvent', world.Pot.Pot1.Model3, localPlayer)
    world.ScenesAudio.BGM_Party.Volume = 0
    SoundUtil.Play2DSE(localPlayer.UserId, 135)
end

function GuiCook:GetFinalFoodEventHandler(_foodId)
    this.foodId = _foodId
end

function GuiCook:CancelMaterial(_index)
    if not this.UsingMaterial[_index] then
        return
    end
    CloudLogUtil.UploadLog('cook', 'cook_recall_' .. this.UsingMaterial[_index].id)
    table.insert(this.BagMaterial, this.UsingMaterial[_index])
    table.remove(this.UsingMaterial, _index)
    table.sort(
        this.BagMaterial,
        function(v1, v2)
            return v1.id < v2.id
        end
    )
    this:ShowMaterialIcon()
    this:ClickChangePage(this.pageIndex)
    this:JudgeCookLocked()
end

function GuiCook:ChooseMaterial(_index)
    if #this.UsingMaterial >= 3 then
        return
    end
    CloudLogUtil.UploadLog('cook', 'cook_select_' .. this.BagMaterial[(this.pageIndex - 1) * this.pageSize + _index].id)
    table.insert(this.UsingMaterial, {id = this.BagMaterial[(this.pageIndex - 1) * this.pageSize + _index].id})
    table.remove(this.BagMaterial, _index + (this.pageIndex - 1) * this.pageSize)
    this:ClickChangePage(this.pageIndex)
    this:ShowMaterialIcon()
    this:JudgeCookLocked()
end

function GuiCook:JudgeCookLocked()
    if this.UsingMaterial and #this.UsingMaterial == 3 then
        this.cookBtn.Locked:SetActive(false)
    else
        this.cookBtn.Locked:SetActive(true)
    end
end

function GuiCook:ClearAllMaterial()
    this.UsingMaterial = {}
    this:ShowMaterialIcon()
    this.cookBtn.Locked:SetActive(true)
end

function GuiCook:ShowMaterialIcon()
    for k, v in ipairs(this.MaterialSlot) do
        if this.UsingMaterial[k] then
            --v.ItemImg:SetActive(true)
            v.ItemImg.IMGNormal.Texture =
                ResourceManager.GetTexture('UI/ItemIcon/' .. Config.Item[this.UsingMaterial[k].id].Icon)
            v.ItemImg.IMGNormal.Size = Vector2(128, 128)
            v.ItemImg.ItemText.Text = LanguageUtil.GetText(Config.Item[this.UsingMaterial[k].id].Name)
        else
            v.ItemImg.IMGNormal.Texture = ResourceManager.GetTexture('UI/Cook/Result/CS_AVG_Icon_Food_1')
            v.ItemImg.IMGNormal.Size = Vector2(138, 151)
            v.ItemImg.ItemText.Text = 'Pick One'
        end
    end
end

function GuiCook:ClickChangePage(_pageIndex)
    this:GetMaxPageNum(#this.BagMaterial)
    if _pageIndex > this.maxPage then
        _pageIndex = this.maxPage
    end
    this:ShowItemsByPageIndex(_pageIndex)
    this:RefreshPageBar(_pageIndex)
end

function GuiCook:ShowItemsByPageIndex(_pageIndex)
    for i = 1, this.pageSize do
        if this.BagMaterial[(_pageIndex - 1) * this.pageSize + i] then
            -- 显示当前页面物品
            this:ShowItemByIndex(i, this.BagMaterial[(_pageIndex - 1) * this.pageSize + i].id)
        else
            this.slotList[i]:SetActive(false)
        end
    end
    this:GetMaxPageNum(#this.BagMaterial)
end

function GuiCook:ShowItemByIndex(_index, _itemId)
    if not _itemId then
        this.slotList[_index]:SetActive(false)
        this.slotList[_index].ItemID.Value = ''
        return
    end
    -- 更换图片
    this.slotList[_index].ItemImg.IMGNormal.Texture =
        ResourceManager.GetTexture('UI/ItemIcon/' .. Config.Item[_itemId].Icon)
    -- 显示数量
    this.slotList[_index].ItemImg.IMGNormal.Size = Vector2(184, 184)
    this.slotList[_index].NameTxt.Text = LanguageUtil.GetText(Config.Item[_itemId].Name)
    this.slotList[_index]:SetActive(_itemId and true or false)
end

---更新最大页面数
function GuiCook:GetMaxPageNum(_itemNum)
    this.maxPage = math.ceil(_itemNum / (this.pageSize))
    if this.maxPage <= 0 then
        this.maxPage = 1
    end
end

function GuiCook:RefreshPageBar(_pageIndex)
    this.pageIndex = _pageIndex
    --页面数字显示
    this.pageTxt.Text = tostring(math.floor(_pageIndex))
    --如果第一页则不显示上一页按钮
    if _pageIndex <= 1 then
        this.prevBtn:SetActive(false)
    end
    --如果最后一页不显示下一页按钮
    if _pageIndex == this.maxPage then
        this.nextBtn:SetActive(false)
    end
    --其他情况打开全部按钮
    if _pageIndex ~= 1 and _pageIndex ~= this.maxPage then
        this.prevBtn:SetActive(true)
        this.nextBtn:SetActive(true)
    end
end

local blackTween, showTween
function GuiCook:ShowFoodEventHandler()
    if not this.foodId then
        invoke(
            function()
                this:ShowFoodEventHandler()
            end,
            0.5
        )
        return
    end
    this.detailPanel:SetActive(false)
    this.gui:SetActive(false)
    this.gui:SetActive(false)
    this.root:SetActive(true)
    this.black:SetActive(true)
    blackTween = Tween:TweenProperty(this.black, {Color = Color(0, 0, 0, 255)}, 1, 1)
    blackTween:Play()
    blackTween:WaitForComplete()
    wait(0.5)
    SoundUtil.Play2DSE(localPlayer.UserId, 136)
    showTween = Tween:TweenProperty(this.black, {Color = Color(0, 0, 0, 0)}, 0.5, 1)
    showTween:Play()
    if Data.Player.notFirstCook then
        this:ConsumeMaterial()
    else
        Data.Player.notFirstCook = true
    end
    this.titleTxt.Text = LanguageUtil.GetText(Config.CookMenu[this.foodId].Name)
    this.foodIcon.Texture = ResourceManager.GetTexture('UI/MealIco/' .. Config.CookMenu[this.foodId].Ico)
    this.foodIcon.Size = Vector2(350, 350)
    this.foodPanel:SetActive(true)
    showTween:WaitForComplete()
    this.black:SetActive(false)
    invoke(
        function()
            world.ScenesAudio.BGM_Party.Volume = 60
        end,
        3
    )
end

function GuiCook:SycnDeskFoodNumEventHandler(_cur, _total)
    this.curShareSlot = _cur
    this.deskBtn.Text = string.format(LanguageUtil.GetText(Config.GuiText['CookGui_5'].Txt) .. '(%s/%s)', _cur, _total)
    if _cur >= _total then
        --禁止上桌
        this.deskBtn.Locked:SetActive(true)
    else
        this.deskBtn.Locked:SetActive(false)
    end
end

function GuiCook:ConsumeMaterial()
    for k, v in pairs(this.UsingMaterial) do
        Data.Player.bag[v.id].count = Data.Player.bag[v.id].count - 1
    end
end

function GuiCook:SetSelectFoodEventHandler(_foodId, _cookName, _cookUserId, _foodLocation)
    this.detailName.Text = LanguageUtil.GetText(Config.CookMenu[_foodId].Name)
    this.authorName.Text = 'By ' .. _cookName
    this.detailIcon.Texture = ResourceManager.GetTexture('UI/MealIco/' .. Config.CookMenu[_foodId].Ico)
    this.detailIcon.Size = Vector2(170, 170)
    this.cookUserId = _cookUserId
    this.foodId = _foodId
    this.foodLocation = _foodLocation
    -- 无法打赏自己做的菜
    if this.cookUserId == localPlayer.UserId or Data.Player.coin <= 0 then
        this.detailReward.Locked:SetActive(true)
    else
        this.detailReward.Locked:SetActive(true)
    end
end

function GuiCook:EatFood()
    NetUtil.Fire_C(
        'GetBuffEvent',
        localPlayer,
        Config.CookMenu[this.foodId].BuffId,
        Config.CookMenu[this.foodId].BuffDur
    )
    localPlayer.Local.ControlGui:SetActive(false)
    NetUtil.Fire_C('EatFoodEvent', localPlayer, this.foodId)
    this:HideGui()
    --
    if this.foodLocation then
        NetUtil.Fire_S('PlayerEatFoodEvent', this.foodLocation)
    end
    this.foodId = nil
    --this:ShowUI()
end

function GuiCook:PutOnDesk()
    NetUtil.Fire_C('FoodOnDeskActionEvent', localPlayer, this.foodId)
    this.foodId = nil
    this.root:SetActive(false)
    --NetUtil.Fire_C('ChangeMiniGameUIEvent', localPlayer)
end

function GuiCook:Update(dt)
end

function GuiCook:SycnTimeCEventHandler(_clock)
    if _clock >= 19 or _clock <= 6 then
        this.canEat = true
    else
        this.canEat = false
    end
end

function GuiCook:PurchaseCEventHandler(_purchaseCoin, _interactID)
    if _interactID == 27 then
        this:EatFood()
    end
end

--************* 强引导相关
function GuiCook:StartGuide()
    this.guideStep = 1
    this.root:SetActive(true)
    this.guidePanel:SetActive(true)
    --NetUtil.Fire_C('PlayerCookEvent', localPlayer, this.UsingMaterial)
    this:GuideStep1()
    this.guidePanel.ContinueBtn.OnClick:Connect(
        function()
            this.guideStep = this.guideStep + 1
            this['GuideStep' .. this.guideStep](self)
        end
    )
end

function GuiCook:TestGuide()
    this:GuideStep1()
end

function GuiCook:GuideStep1()
    this.guideBlack:SetActive(true)
    print('开场白')
end

function GuiCook:GuideStep2()
    this.guideDrag:ToTop()
    this:GuideBoxChangeSize(this.guideDrag)
end

function GuiCook:GuideStep3()
    this.guideDrag:ToBottom()
    this.guideMat:ToTop()
    this.guidePanel.ContinueBtn:ToTop()
    this:GuideBoxChangeSize(this.guideMat)
end

function GuiCook:GuideStep4()
    this.guideDrag:ToTop()
    this.guidePanel.ContinueBtn:ToTop()
    this.guidePanel.ContinueBtn:SetActive(false)
    this:GuideBoxChangeSize(this.guideMatSlot[1])
    this.guideMatSlot[1].ItemImg.SelectBtn.OnClick:Connect(
        function()
            this.guideStep = this.guideStep + 1
            this['GuideStep' .. this.guideStep](self)
        end
    )
end

function GuiCook:GuideStep5()
    this.guideCookSlot[1].ItemImg.IMGNormal.Texture = this.guideMatSlot[1].ItemImg.IMGNormal.Texture
    this.guideCookSlot[1].ItemImg.ItemText.Text = LanguageUtil.GetText(Config.Item[7004].Name)
    this.guideMatSlot[1].ItemImg.IMGNormal.Texture = this.guideMatSlot[2].ItemImg.IMGNormal.Texture
    this.guideMatSlot[2].ItemImg.IMGNormal.Texture = this.guideMatSlot[3].ItemImg.IMGNormal.Texture
    this.guideMatSlot[3]:SetActive(false)
    this:GuideBoxChangeSize(this.guideMatSlot[1])
end

function GuiCook:GuideStep6()
    this.guideCookSlot[2].ItemImg.IMGNormal.Texture = this.guideMatSlot[1].ItemImg.IMGNormal.Texture
    this.guideCookSlot[2].ItemImg.ItemText.Text = LanguageUtil.GetText(Config.Item[7002].Name)
    this.guideMatSlot[1].ItemImg.IMGNormal.Texture = this.guideMatSlot[2].ItemImg.IMGNormal.Texture
    this.guideMatSlot[2]:SetActive(false)
    this:GuideBoxChangeSize(this.guideMatSlot[1])
end

function GuiCook:GuideStep7()
    this.guideCookSlot[3].ItemImg.IMGNormal.Texture = this.guideMatSlot[1].ItemImg.IMGNormal.Texture
    this.guideCookSlot[3].ItemImg.ItemText.Text = LanguageUtil.GetText(Config.Item[7001].Name)
    this.guideMatSlot[1]:SetActive(false)
    this.guideDrag:ToBottom()
    this.guideMat:ToTop()
    this.guidePanel.ContinueBtn:ToTop()
    this.guideCook.Locked:SetActive(false)
    this:GuideBoxChangeSize(this.guideCook)
    this.guideCook.OnClick:Connect(
        function()
            this.guideStep = this.guideStep + 1
            this['GuideStep' .. this.guideStep](self)
        end
    )
end

function GuiCook:GuideStep8()
    NetUtil.Fire_C('PlayerCookEvent', localPlayer, {{id = 7001}, {id = 7002}, {id = 7004}})
    this.foodLocation = nil
    --开始烹饪
    this.guidePanel:SetActive(false)
    --打开进度条
    --this.progressPanel:SetActive(true)
    --this.startUpdate = true
    NetUtil.Fire_S('PotShakeEvent', world.Pot.Pot1.Model3, localPlayer)
    world.ScenesAudio.BGM_Party.Volume = 0
    SoundUtil.Play2DSE(localPlayer.UserId, 135)
end

local guideBoxTweener
function GuiCook:GuideBoxChangeSize(_parent)
    if guideBoxTweener then
        guideBoxTweener:Pause()
        guideBoxTweener:Destroy()
        this.guideBox:Destroy()
        guideBoxTweener = nil
    end
    this.guideBox = world:CreateInstance('GuideBox', 'GuideBox', _parent)
    --wait()
    this.guideBox.Size = _parent.Size * 1.2
    this.guideBox.Offset = Vector2(0, 0)
    guideBoxTweener = Tween:TweenProperty(this.guideBox, {Size = _parent.Size}, 0.5, 1)
    this.guideBox:SetActive(true)
    guideBoxTweener:Play()
    guideBoxTweener:WaitForComplete()
end

return GuiCook
