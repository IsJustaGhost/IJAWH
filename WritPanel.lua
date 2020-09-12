function IJAWH:CreateWritPanel()
    local craftTLW = CreateTopLevelWindow("IsJustaWritHelperHListTLW")
    craftTLW:SetDimensions(420, 280)
	craftTLW:SetAnchor(TOPLEFT, GuiRoot, nil, 250, 150)
    IJAWH.craftTLW = craftTLW
	
	EVENT_MANAGER:RegisterForEvent("IJAWH_RESIZE", EVENT_SCREEN_RESIZED, function()
	end)
	
    local craftPanel = CreateControlFromVirtual("IsJustaWritHelper_CraftPanel", IJAWH.craftTLW, "IsJustaWritHelper_CraftPanel")
    craftPanel:SetDimensions(420, 280)
    IJAWH.craftPanel = craftPanel
    
    local backdrop = CreateControlFromVirtual("IsJustaWritHelper_CraftPanelBg", IJAWH.craftTLW, "ZO_DefaultBackdrop")
	backdrop:SetAnchorFill()
    IJAWH.craftPanelBD = backdrop
	
		
	IJAWH.craftTLW:SetHidden(true)
	IsJustaWritHelper_CraftPanelWithdrawDivider:SetHidden(true)
	
    local function OnHorizonalScrollListShown(list)
        --local listContainer = list:GetControl():GetParent() 
        --listContainer.selectedLabel:SetHidden(false)
    end
 
    local function EqualityFunction(leftData, rightData)
        return leftData.name == rightData.name
    end
 
    local function OnHorizonalScrollListCleared(...)
       -- self:OnHorizonalScrollListCleared(...)
    end
	

    local function SetupFunction(control, data, selected, selectedDuringRebuild, enabled)
        control.list:SetText(data.name)
        control.listSort:SetText(data.sort)
        local width = control.list:GetStringWidth(control.list:GetText())  + 20
        control:SetWidth(width)
		
		local function alchemySetupCallback(oldState, newState)
			if newState == SCENE_SHOWING then
				self:setReagentSlots(data)
			end
		end

		if IJAWH.AlchemyFirstRun then
			GAMEPAD_ALCHEMY_CREATION_SCENE:RegisterCallback("StateChange", alchemySetupCallback)
			ALCHEMY_SCENE:RegisterCallback("StateChange", alchemySetupCallback)
			IJAWH.AlchemyFirstRun = false
		end
    end
	
    local function OnSelectedPatternChanged(selectedData, oldData, selectedDuringRebuild)
        IJAWH.craftPanel.variations:SetText(selectedData.variations)
        IJAWH.craftPanel.variations:SetText(selectedData.variations)
		self:setReagentSlots(selectedData)
    end
	
	IJAWH.craftPanel.listControl:SetDimensions(500, 105)
	
    local recipeList = ZO_HorizontalScrollList:New(craftPanel.listControl, "IsJustaWritHelper_HList_SlotTemplate", 3, SetupFunction, EqualityFunction, OnHorizonalScrollListShown, OnHorizonalScrollListCleared)
    recipeList:SetOnSelectedDataChangedCallback(function(selectedData, oldData, selectedDuringRebuild)
        OnSelectedPatternChanged(selectedData, oldData, selectedDuringRebuild)
    end)
	
	
    IJAWH.recipeList = recipeList
    
    recipeList.displayEntryType = ZO_HORIZONTAL_SCROLL_LIST_ANCHOR_ENTRIES_AT_FIXED_DISTANCE
    
    recipeList.offsetBetweenEntries = 50
	IJAWH:EnableReagentPanel(false)
	
	-------------------------------------------------
	local function SetToolTip(ctrl, text)
		ctrl:SetHandler("OnMouseEnter", function(self)
			ZO_Tooltips_ShowTextTooltip(self, TOP, text)
		end)
		ctrl:SetHandler("OnMouseExit", function(self)
			ZO_Tooltips_HideTextTooltip()
		end)
	end
	local function EntryFactory(pool)
		local name = "WritEntry" .. pool:GetNextControlId()
		local container = IJAWH.writsPanel.listContainer:CreateControl(name, CT_CONTROL)
		
		local toolTip = container:CreateControl("$(parent)ToolTip", CT_BUTTON)
		local writ = container:CreateControl("$(parent)Conditions", CT_LABEL)
		local status = container:CreateControl("$(parent)Status", CT_LABEL)
		local icon = container:CreateControl("$(parent)Icon", CT_TEXTURE)
		local iconToolTip = container:CreateControl("$(parent)IconToolTip", CT_BUTTON)

		writ:SetFont("ZoFontWinH3")
		icon:SetDimensions(230,25)
		writ:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		
		status:SetFont("ZoFontWinH3")	
		icon:SetDimensions(25,25)
		status:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		
		icon:SetTexture("/esoui/art/tooltips/icon_bank.dds")
		icon:SetHidden(true)
		icon:SetDimensions(25,25)
--		icon:SetColor(1, 1, 0, 1)
		
		
		SetToolTip(iconToolTip, GetString(SI_IJAWH_IN_WTHDRAW_LIST))
		iconToolTip:SetDimensions(25, 25)
		iconToolTip:SetHidden(true)
		
		toolTip:SetDimensions(230, 25)
		container.setToolTip = function(text) SetToolTip(toolTip, text) end
		
		container.toolTip = toolTip
		container.iconToolTip = iconToolTip
		container.writ = writ
		container.status = status
		container.icon = icon
		container:SetAnchor(BOTTOMLEFT, IsJustaWritHelper_CraftPanelDivider, nil, 0, 0)
		return container
	end
	local function ResetEntry(entry)
--		entry:SetHidden(true)
		entry:ClearAnchors()
		entry.writ:SetText("")
		entry.status:SetText("")
		entry.toolTip:SetHandler("OnMouseEnter", nil)
		entry.toolTip:SetHandler("OnMouseExit", nil)
		entry.iconToolTip:SetHidden(true)
		entry.icon:SetHidden(true)
	end
	local writList = ZO_ObjectPool:New(EntryFactory, ResetEntry)

	-------------------------------------------------
    local WritsPanelTLW = CreateTopLevelWindow("IsJustaWritHelper_WritsPanelTLW")
    IJAWH.WritsPanelTLW = WritsPanelTLW
    WritsPanelTLW:SetDimensions(310, 400)
	WritsPanelTLW:SetAnchor(TOPLEFT, GuiRoot, nil, 5, 5)
	
    local writsPanel = CreateControlFromVirtual("IsJustaWritHelper_WritsPanel", IJAWH.WritsPanelTLW, "IsJustaWritHelper_WritsPanel")
	IJAWH.writsPanel = writsPanel
	IJAWH.writsPanel.container:ClearAnchors()
	IJAWH.writsPanel.container:SetAnchor(TOPRIGHT, WritsPanelTLW, nil, 5, 5)
	
	-- adding it as a fragment to the hud scene to give hud control over hiding and showing it. 
	-- this will cause the panel to auto-hid/show with the hud for instances such as opening a menu
	local writsPanelTLWFragment = ZO_HUDFadeSceneFragment:New(WritsPanelTLW, nil, 0)
	HUD_SCENE:AddFragment(writsPanelTLWFragment)
	HUD_UI_SCENE:AddFragment(writsPanelTLWFragment)

	IJAWH_WRITPANEL_ORIGINAL_HEIGHT = 30
	IJAWH_WRITPANEL_ADJUSTED_HEIGHT = 0
	
	IJAWH.writsPanel:SetHidden(true)
	
	local function minimizeButton()
		IJAWH.writsPanelFunc:Minimize()
	end
	
	local function maximizeButton() 
		IJAWH.writsPanelFunc:Maximize()
	end
	function IJAWH:buttonMaxMin(state)
		if state then
			minimizeButton()
		else
			maximizeButton()
		end
	end
	
	IsJustaWritHelper_WritsPanelMaximize_Button:SetHidden(true)
	
	IsJustaWritHelper_WritsPanelMinimize_Button:SetHandler("OnMouseUp", minimizeButton)
	IsJustaWritHelper_WritsPanelMaximize_Button:SetHandler("OnMouseUp", maximizeButton)
	
	IsJustaWritHelper_WritsPanelContainerHeader:SetColor(0.8, 0.8, 0.8, 1)
	function IJAWH:wpMinMax(state)
		IJAWH_WRITPANEL_LIST_IsHidden = state
		local HEIGHT = state and IJAWH_WRITPANEL_ORIGINAL_HEIGHT or IJAWH_WRITPANEL_ADJUSTED_HEIGHT
		IsJustaWritHelper_WritsPanelContainerDivider:SetHidden(state)
		IJAWH.writsPanel.listContainer:SetHidden(state)
		IJAWH.writsPanel.writList = writList
		IJAWH.writsPanel.container:SetHeight(HEIGHT)
		local newState = state ~= true and true or false
		
		local r, g, b, a = IsJustaWritHelper_WritsPanelContainerHeader:GetColor()
		local num = tostring(g):gsub("^(0.8).*", "%1")
		if num ~= "0.8" then
			local up = {r = r and r / 0.8 or 0, g = g and g / 0.8 or 0, b = b and b / 0.8 or 0}
			IsJustaWritHelper_WritsPanelContainerHeader:SetColor(up.r, up.g, up.b, 1)
			PlaySound(SOUNDS.DEFAULT_CLICK)
		end
		IsJustaWritHelper_WritsPanelContainerHeader:SetHandler("OnMouseUp", function() IJAWH:wpMinMax(newState) end)
	end
	IJAWH:wpMinMax(false)
end

function IJAWH:setReagentSlots(selectedData)
	if not IJAWH_CurrentWrit.recipeData then return end
	if  IsInGamepadPreferredMode() then
		for i, slot in ipairs(GAMEPAD_ALCHEMY.reagentSlots) do		
			slot:SetItem(nil, nil, suppressSound, ignoreUsabilityRequirement)
		end
	else
		for i, slot in ipairs(ALCHEMY.reagentSlots) do		
			slot:SetItem(nil, nil, suppressSound, ignoreUsabilityRequirement)
		end
	end
	for i=1, #selectedData.itemName do
		if selectedData.totalStack[i] < 1 then IJAWH_EASYALCHEMY_OUT = true end
		if selectedData.canCraft then
			if selectedData.reagentSlots[i].meetsUsageRequirement then self:TryAddItemToCraft(selectedData.reagentSlots[i]) end
		end
	end
	
	IJAWH_CurrentWrit.recipeData = {}
	IJAWH_CurrentWrit.recipeData[1] = selectedData
	
	ALCHEMY_Iterations = selectedData.numIterations
	
	if IsJustaEasyAlchemy.isEasyAlchemy then IsJustaEasyAlchemy:UpdatePanel() end
	
	KEYBIND_STRIP:UpdateKeybindButton(IJAWH.craftKeybindButtonDescriptor)
	
	if IJAWH.PreviousKeybind.oldName then return end
	if IsInGamepadPreferredMode() then
		KEYBIND_STRIP:UpdateKeybindButtonGroup(GAMEPAD_ALCHEMY.mainKeybindStripDescriptor)
	else
		KEYBIND_STRIP:UpdateKeybindButtonGroup(ALCHEMY.keybindStripDescriptor)
	end
end

function IJAWH:EnableReagentPanel(enabled)
	if enabled == true then
		IJAWH:RefreshKeybinds()
		IJAWH.craftPanel.listControl:SetHidden(false)
		IJAWH.craftPanel.variations:SetHidden(false)
	--[[	
		IJAWH.craftPanel.listControl:ClearAnchors()
		IJAWH.craftPanel.listControl:SetAnchor(TOP, IsJustaWritHelper_CraftPanelDivider, TOP, -5, IJAWH_yPos - 20)
		IJAWH_PANEL_HEIGHT = IJAWH_PANEL_HEIGHT + 10 
		IJAWH_LAST_PANEL_HEIGHT = IJAWH_PANEL_HEIGHT
		IJAWH_PANEL_HEIGHT = IJAWH_PANEL_HEIGHT + 70
		IJAWH.craftPanel:SetHeight(IJAWH_PANEL_HEIGHT)
		IJAWH_lastyPos = IJAWH_yPos
		IJAWH_YPos = IJAWH_yPos + 75
		--]]

	else
	--[[	
		if IJAWH_LAST_PANEL_HEIGHT then
			IJAWH_PANEL_HEIGHT = IJAWH_LAST_PANEL_HEIGHT
			IJAWH.craftPanel:SetHeight(IJAWH_PANEL_HEIGHT)
			IJAWH_LAST_PANEL_HEIGHT = nil
		end
		IJAWH_yPos = IJAWH_lastYPos
		--]]
		IJAWH.craftPanel.listControl:SetHidden(true)
		IJAWH.craftPanel.variations:SetHidden(true)
	end
end
	
function IJAWH:AddKeybinds()
    KEYBIND_STRIP:AddKeybindButtonGroup(self.recipeListKeybindStripDescriptors)
end

function IJAWH:RemoveKeybinds()
    KEYBIND_STRIP:RemoveKeybindButtonGroup(self.recipeListKeybindStripDescriptors)
end

function IJAWH:RefreshKeybinds()
    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.recipeListKeybindStripDescriptors)
end

function IJAWH:InitializeKeybindStripDescriptors()
    self.recipeListKeybindStripDescriptors = 
    {
        {
            --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
            name = "Back",
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            ethereal = true,
            enabled = function() return self.recipeList:GetNumItems() > 0 end,
            callback = function()
                self.recipeList:MoveRight()
             --   PlaySound(SOUNDS.GAMEPAD_PAGE_BACK)
            end,
        },

        {
            --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
            name = "Next",
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            ethereal = true,
            enabled = function() return self.recipeList:GetNumItems() > 0 end,
            callback = function()
                self.recipeList:MoveLeft()
             --   PlaySound(SOUNDS.GAMEPAD_PAGE_FORWARD)
            end,
        },
    }
end

-------------------------------------
-- Writ Panel Animation Functions
-------------------------------------
local function CreateSlideAnimations(container, motion, maximizeAnimation)
	if not container.slideAnim then container.slideAnim = {} end
    if not container.slideAnim[motion] then
        container.slideAnim[motion] = ANIMATION_MANAGER:CreateTimelineFromVirtual("IJAMinMaxAnim", container.container)
    end
    if maximizeAnimation then
		container.slideAnim[motion]:SetHandler("OnStop", function(animation) container.container:SetClampedToScreen(true) end)
    else
        container.slideAnim[motion]:SetHandler("OnStop", nil)
    end
end

function IJAWH.writsPanelFunc:Minimize()
	local container = IJAWH.writsPanel
	if not IJAWH.writsPanel.isMinimized then
	
		CreateSlideAnimations(container, "minimize", true)
		
		local minimizeDistance
		if not container.slideAnim.minimize:IsPlaying() then
			minimizeDistance = container.container:GetRight()
			container.originalPosition = container.container:GetRight()
		else
			minimizeDistance = container.originalPosition
		end
		
		minimizeDistance = minimizeDistance + 40 --need a buffer to get the edge offscreen
		container.container:SetClampedToScreen(false)
		
		container.slideAnim.minimize:SetHandler('OnStop', function()
			IJAWH.writsPanel.container:SetHidden(true)
		end)
		
		container.slideAnim.minimize:GetAnimation(1):SetTranslateDeltas(-minimizeDistance, 0)
		container.slideAnim.minimize:PlayFromStart()
        PlaySound(SOUNDS.CHAT_MAXIMIZED)
		IJAWH.writsPanel.isMinimized = true
		
		IsJustaWritHelper_WritsPanelMinimize_Button:SetHidden(true)
		IsJustaWritHelper_WritsPanelMaximize_Button:SetHidden(false)
    end
end

function IJAWH.writsPanelFunc:Maximize()
	local container = IJAWH.writsPanel
	
	if IJAWH.writsPanel.isMinimized then
		CreateSlideAnimations(container, "minimize")
		IJAWH.writsPanel.container:SetHidden(false)
		local maximizeDistance
		
		if not IsJustaSANDBOX_inGroup and IJAWH.writsPanel.isRight then
			maximizeDistance = container.container:GetRight() + 400
			IJAWH.writsPanel.isRight = false
		elseif IsJustaSANDBOX_inGroup and (not IJAWH.writsPanel.isRight) then
			maximizeDistance = container.container:GetRight() + 680
			IJAWH.writsPanel.isRight = true
		else
			maximizeDistance = container.originalPosition - container.container:GetRight()
		end
		container.slideAnim.minimize:GetAnimation(1):SetTranslateDeltas(maximizeDistance, 0)
		container.slideAnim.minimize:PlayFromStart()
		PlaySound(SOUNDS.CHAT_MINIMIZED)
		IJAWH.writsPanel.isMinimized = false
		IsJustaWritHelper_WritsPanelMinimize_Button:SetHidden(false)
		IsJustaWritHelper_WritsPanelMaximize_Button:SetHidden(true)
    end
end

-- for reposition for group
-- >>>>>>>>>>>>>>>>>
function IJAWH.writsPanelFunc:MoveRight()
	local container = IJAWH.writsPanel
	if not IJAWH.writsPanel.isRight and not IJAWH.writsPanel.isMinimized then
		CreateSlideAnimations(container, "groupMove")
		local groupDistance
		if not container.slideAnim.groupMove:IsPlaying() then
			groupDistance = 280
			container.originalPosition = container.container:GetRight()
		else
			groupDistance = container.originalPosition
		end
		container.slideAnim.groupMove:GetAnimation(1):SetTranslateDeltas(groupDistance, 0)
		container.slideAnim.groupMove:PlayFromStart()
        PlaySound(SOUNDS.CHAT_MAXIMIZED)
		IJAWH.writsPanel.isRight = true
    end
end
function IJAWH.writsPanelFunc:MoveLeft()
	local container = IJAWH.writsPanel
	if IJAWH.writsPanel.isRight and not IJAWH.writsPanel.isMinimized then
		CreateSlideAnimations(container, "groupMove")
--		local soloDistance =  container.container:GetRight() - container.groupPosition
		local soloDistance =  280
		container.slideAnim.groupMove:GetAnimation(1):SetTranslateDeltas(-soloDistance, 0)
		container.slideAnim.groupMove:PlayFromStart()
        PlaySound(SOUNDS.CHAT_MINIMIZED)
		
		IJAWH.writsPanel.isRight = false
    end
end