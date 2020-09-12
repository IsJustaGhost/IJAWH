IsJustaEasyAlchemy = {}
function IsJustaEasyAlchemy:CreateAlchemyPanel()
    local IsJustaEasyAlchemyTLW = CreateTopLevelWindow("IsJustaEasyAlchemyHListTLW")
    IsJustaEasyAlchemyTLW:SetDimensions(900, 100)
	
	IsJustaEasyAlchemyTLW:SetHidden(true)
	
	IsJustaEasyAlchemy.AlchemyTLW = IsJustaEasyAlchemyTLW
	
	local IsJustaEasyAlchemyHList = CreateControlFromVirtual("IsJustaEasyAlchemy_AlchemyPanel", IsJustaEasyAlchemyTLW, "IsJustaEasyAlchemy_AlchemyPanel")
	
	IsJustaEasyAlchemyHList:SetDimensions(900, 100)

    IsJustaEasyAlchemyHList:SetScale(.5)
	IsJustaEasyAlchemy.AlchemyHList = IsJustaEasyAlchemyHList
	
	IsJustaEasyAlchemy.AlchemyHList.pattern = {[1] = nil, [2] = nil, [3] = nil, [4] = nil, [5] = nil, [6] = nil}
	IsJustaEasyAlchemy.AlchemyHList.Trait = {}
	
	IsJustaEasyAlchemy.LoadignProgress = IsJustaEasyAlchemy_LoadingProgress
    IsJustaEasyAlchemy.LoadignProgressAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("LoadingAnimation", self.LoadignProgress)
	
	IsJustaEasyAlchemy_LoadingProgress:SetAnchor(CENTER, GuiRoot, nil, 0, 0)
	ZO_AlchemyTopLevel:BringWindowToTop()
	
	
		local name = "Saved Recipes"
		local creationData = {
			activeTabText = name,
			categoryName = name,
			descriptor = "Saved Recipes",
			normal = "esoui/art/inventory/inventory_tabicon_consumables_up.dds",
			pressed = "esoui/art/inventory/inventory_tabicon_consumables_down.dds",
			highlight = "esoui/art/inventory/inventory_tabicon_consumables_over.dds",
			disabled = "esoui/art/inventory/inventory_tabicon_consumables_disabled.dds",
			callback = function(creationData)
				ALCHEMY.modeBarLabel:SetText(GetString(name))
				ALCHEMY:SetMode(creationData.descriptor)
			end
		}
		ZO_MenuBar_AddButton(ALCHEMY.modeBar, creationData)
	
	
    local data = ZO_GamepadEntryData:New(name, "esoui/art/inventory/inventory_tabicon_consumables_up.dds")
	
    data.mode = 3
	GAMEPAD_ALCHEMY.modeList:AddEntry("ZO_GamepadItemEntryTemplate", data)
    GAMEPAD_ALCHEMY.modeList:Commit()
	
	ZO_PostHook(ZO_GamepadAlchemy, "SelectMode", function(self)
		local data = self.modeList:GetTargetData()
		if data then
			if data.mode == 3 then
				SCENE_MANAGER:Push("gamepad_alchemy_creation")
				zo_callLater(function()
					IsJustaEasyAlchemy:updateList()
				end, 100)
			end
		end
	end)


end
function IsJustaEasyAlchemy:updateList()
	ZO_GamepadCraftingUtils_SetupGenericHeader(GAMEPAD_ALCHEMY, "Saved")
    ZO_GamepadCraftingUtils_RefreshGenericHeader(GAMEPAD_ALCHEMY)
	
	
	
	GAMEPAD_ALCHEMY.inventory.list:Clear()
	GAMEPAD_ALCHEMY.inventory.list:AddEntry({name = "test", iconFile = "esoui/art/inventory/inventory_tabicon_consumables_up.dds"})
	
	GAMEPAD_ALCHEMY.inventory.list:Commit()
	GAMEPAD_ALCHEMY.inventory:SetNoItemLabelText("No Saved Recipes")
end
function IsJustaEasyAlchemy:UpdatePanel()
	local resultLink
	IJAWH:UpdateSolvent()
	if IsInGamepadPreferredMode() then
		resultLink = GetAlchemyResultingItemLink(GAMEPAD_ALCHEMY:GetAllCraftingBagAndSlots()):gsub("%|H1", "|H0")
	else
		resultLink = GetAlchemyResultingItemLink(ALCHEMY:GetAllCraftingBagAndSlots()):gsub("%|H1", "|H0")
	end
	
	if resultLink ~= "" then
		IsJustaEasyAlchemy.Unknown = false
	else
		if IJAWH_EASYALCHEMY_OUT then
			resultLink = GetString(SI_TRADESKILLRESULT132)
		else
			resultLink = zo_strformat(GetString(SI_ALCHEMY_UNKNOWN_RESULT),IsJustaEasyAlchemy.AlchemyHList.pattern[1])
			IsJustaEasyAlchemy.Unknown = true
			IJAWH_EASYALCHEMY_OUT = false
		end
	end
	
	IJAWH:EnableReagentPanel(true)
	IJAWH:showCraftPannel(resultLink)
end
		
function IsJustaEasyAlchemy:SetupSelecters()
	BufferTable = {}
	local NO_LEADING_EDGE = false
	
	local duration = 1000
	local function onStartLookup()
		IsJustaEasyAlchemy.LoadignProgressAnimation:PlayForward()
		IsJustaEasyAlchemy.LoadignProgress:StartCooldown(duration, duration, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
	end

	local function onEndLookup()
		IsJustaEasyAlchemy.LoadignProgressAnimation:PlayBackward()
		if IJAWH_CurrentWrit.recipeData then
			IJAWH:setStationForWrit()
			IsJustaEasyAlchemy:UpdatePanel()
		end
	end	
	
	local function OnUpdateHandler()	
		if not IJAWH.activeEvents.UpdateTicRegistered and IsJustaEasyAlchemy.AlchemyHList.pattern[2] ~= nil then 
			EVENT_MANAGER:RegisterForUpdate("IJAWH_UpdateTic", 100, OnUpdateHandler)
			EVENT_MANAGER:RegisterForUpdate("IJAWH_RepeatProgress", duration+10, onStartLookup)
			IJAWH.activeEvents.UpdateTicRegistered = true
			onStartLookup()
		end
		
		if not IJAWH:BufferReached("wait", 4) then return end
		IsJustaEasyAlchemy:buildCraftString()
		EVENT_MANAGER:UnregisterForUpdate("IJAWH_UpdateTic")
		EVENT_MANAGER:UnregisterForUpdate("IJAWH_RepeatProgress")
		IJAWH.activeEvents.UpdateTicRegistered = false
		onEndLookup()
	end

    local function SetupFunction_Trait3(control, data, selected, selectedDuringRebuild, enabled)
		IsJustaEasyAlchemy.AlchemyHList.pattern[4] = data.trait
		OnUpdateHandler(data)
		
    end
	
	local function OnSelectedpatternChanged_Trait3(selectedData, oldData, selectedDuringRebuild)
		if selectedData then
			IsJustaEasyAlchemy.AlchemyHList.trait3Label:SetText(selectedData.trait)
			IsJustaEasyAlchemy.AlchemyHList.pattern[4] = selectedData.trait
		end	
		OnUpdateHandler(selectedData)
    end
	   
    local trait3Hlist = ZO_HorizontalScrollList:New(IsJustaEasyAlchemy.AlchemyHList.trait3Control, "IsJustaEasyAlchemy_HList_SlotTemplate", 3, SetupFunction_Trait3)
    trait3Hlist:SetOnSelectedDataChangedCallback(function(selectedData, oldData, selectedDuringRebuild)
        OnSelectedpatternChanged_Trait3(selectedData, oldData, selectedDuringRebuild)
    end)
	
	trait3Hlist.displayEntryType = ZO_HORIZONTAL_SCROLL_LIST_ANCHOR_ENTRIES_AT_FIXED_DISTANCE
    trait3Hlist.offsetBetweenEntries = 100
	
	IsJustaEasyAlchemy.AlchemyHList.Trait[3] = trait3Hlist
	IsJustaEasyAlchemy.AlchemyHList.Trait[3]:AddEntry({trait = ""})
	IsJustaEasyAlchemy.AlchemyHList.Trait[3]:Commit()
	
    local function SetupFunction_Trait2(control, data, selected, selectedDuringRebuild, enabled)
		self:SetEffectList(3,data)
		IsJustaEasyAlchemy.AlchemyHList.pattern[3] = data.trait
		IsJustaEasyAlchemy.AlchemyHList.pattern[4] = nil
		OnUpdateHandler(data)
		
    end
	
    local function OnSelectedpatternChanged_Trait2(selectedData, oldData, selectedDuringRebuild)
	
		if selectedData then
			IsJustaEasyAlchemy.AlchemyHList.trait2Label:SetText(selectedData.trait)
			IsJustaEasyAlchemy.AlchemyHList.trait3Label:SetText("")
			self:SetEffectList(3,selectedData)
		IsJustaEasyAlchemy.AlchemyHList.pattern[3] = selectedData.trait
		end
		OnUpdateHandler(selectedData)
		
    end
	
    local trait2Hlist = ZO_HorizontalScrollList:New(IsJustaEasyAlchemy.AlchemyHList.trait2Control, "IsJustaEasyAlchemy_HList_SlotTemplate", 3, SetupFunction_Trait2)
    trait2Hlist:SetOnSelectedDataChangedCallback(function(selectedData, oldData, selectedDuringRebuild)
        OnSelectedpatternChanged_Trait2(selectedData, oldData, selectedDuringRebuild)
    end)
	
	trait2Hlist.displayEntryType = ZO_HORIZONTAL_SCROLL_LIST_ANCHOR_ENTRIES_AT_FIXED_DISTANCE
    trait2Hlist.offsetBetweenEntries = 100
	
	IsJustaEasyAlchemy.AlchemyHList.Trait[2] = trait2Hlist
	IsJustaEasyAlchemy.AlchemyHList.Trait[2]:AddEntry({trait = ""})
	IsJustaEasyAlchemy.AlchemyHList.Trait[2]:Commit()
	
    local function SetupFunction_Trait1(control, data, selected, selectedDuringRebuild, enabled)
		self:SetEffectList(2,data)
		IsJustaEasyAlchemy.AlchemyHList.pattern[2] = data.trait
		IsJustaEasyAlchemy.AlchemyHList.pattern[3] = nil
		IsJustaEasyAlchemy.AlchemyHList.pattern[4] = nil
    end
	
    local function OnSelectedpatternChanged_Trait1(selectedData, oldData, selectedDuringRebuild)
		if selectedData then
			IsJustaEasyAlchemy.AlchemyHList.trait1Label:SetText(selectedData.trait)
			IsJustaEasyAlchemy.AlchemyHList.trait3Label:SetText("")
			self:SetEffectList(2,selectedData)
			IsJustaEasyAlchemy.AlchemyHList.pattern[2] = selectedData.trait
		end 
		OnUpdateHandler()
		
    end
	
    local trait1Hlist = ZO_HorizontalScrollList:New(IsJustaEasyAlchemy.AlchemyHList.trait1Control, "IsJustaEasyAlchemy_HList_SlotTemplate", 3, SetupFunction_Trait1)
    trait1Hlist:SetOnSelectedDataChangedCallback(function(selectedData, oldData, selectedDuringRebuild)
        OnSelectedpatternChanged_Trait1(selectedData, oldData, selectedDuringRebuild)
    end)
	
	trait1Hlist.displayEntryType = ZO_HORIZONTAL_SCROLL_LIST_ANCHOR_ENTRIES_AT_FIXED_DISTANCE
    trait1Hlist.offsetBetweenEntries = 100
	
	IsJustaEasyAlchemy.AlchemyHList.Trait[1] = trait1Hlist
	IsJustaEasyAlchemy.AlchemyHList.Trait[1]:AddEntry({trait = ""})
	IsJustaEasyAlchemy.AlchemyHList.Trait[1]:Commit()
	

    local function SetupFunction(control, data, selected, selectedDuringRebuild, enabled)
		IsJustaEasyAlchemy.AlchemyHList.pattern[1] = data.solvent
    end
	
    local function OnSelectedpatternChanged(selectedData, oldData, selectedDuringRebuild)	
		IsJustaEasyAlchemy.AlchemyHList.solventLabel:SetText(selectedData.solvent)
		
		IsJustaEasyAlchemy.AlchemyHList.pattern[1] = selectedData.solvent
		IsJustaEasyAlchemy.AlchemyHList.pattern[2] = nil
		IsJustaEasyAlchemy.AlchemyHList.pattern[3] = nil
		IsJustaEasyAlchemy.AlchemyHList.pattern[4] = nil
		
		
		self:SetEffectList(1,selectedData)
		OnUpdateHandler()
    end
	
    local solventHlist = ZO_HorizontalScrollList:New(IsJustaEasyAlchemy.AlchemyHList.solventControl, "IsJustaEasyAlchemy_HList_SlotTemplate", 3, SetupFunction)
    solventHlist:SetOnSelectedDataChangedCallback(function(selectedData, oldData, selectedDuringRebuild)
        OnSelectedpatternChanged(selectedData, oldData, selectedDuringRebuild)
    end)
	
	solventHlist.displayEntryType = ZO_HORIZONTAL_SCROLL_LIST_ANCHOR_ENTRIES_AT_FIXED_DISTANCE
    solventHlist.offsetBetweenEntries = 100
	IsJustaEasyAlchemy.AlchemyHList.solventType = solventHlist
	

end

function IsJustaEasyAlchemy:InitialiseSolventList()
	IsJustaEasyAlchemy.AlchemyHList.solventType:Clear()
	for i=1, 2 do
		IsJustaEasyAlchemy.AlchemyHList.solventType:AddEntry({solvent = IJAWH.alchemyVariatons[i].solvent, Table = IJAWH.alchemyVariatons[i]})
	end
	IsJustaEasyAlchemy.AlchemyHList.solventType:Commit()
end

function IsJustaEasyAlchemy:SetSolventLevel(isPoison)
    local solventRank = IJAWH:GetSkillRank(CRAFTING_TYPE_ALCHEMY, 1)

    local solventList
    if isPoison == "Poison" then
        solventList = {[1] = {"I", "II"}, [2] = "III", [3] = "IV", [4] = "V", [5] = "VI", [6] = "VII", [7] = "VIII", [8] = "IX"}
	else
        solventList = {[1] = {"Sip","Tincture"},[2] = "Dram",[3] = "Potion",[4] = "Solution",[5] = "Elixir", [6] = "Panacea", [7] = "Distillate", [8] = "Essence"}
    end
	local solvent = solventList[solventRank]
	if type(solvent) == "table" then	-- for alchemy level 1
		local playerLevel = GetUnitLevel("player")
		solvent = playerLevel < 10 and solvent[1] or solvent[2]
	end
	
	return solvent
end

function IsJustaEasyAlchemy:buildCraftString()
	local isPoison = IJAWH:isPoison(IsJustaEasyAlchemy.AlchemyHList.pattern[1])
	local pattern = IsJustaEasyAlchemy:ConvertTraitNames(isPoison)
	local traits = {}
	local craftLine = nil
	
	if  IsInGamepadPreferredMode() then
		for i, slot in ipairs(GAMEPAD_ALCHEMY.reagentSlots) do		
			slot:SetItem(nil, nil, suppressSound, ignoreUsabilityRequirement)
		end
	else
		for i, slot in ipairs(ALCHEMY.reagentSlots) do		
			slot:SetItem(nil, nil, suppressSound, ignoreUsabilityRequirement)
		end
	end
	if pattern[2] ~= nil then
		if isPoison == "Poison" then
			craftLine =  "Craft " .. pattern[2] .. " Poison " .. tostring(self:SetSolventLevel(isPoison)) .. ":"
		else
			craftLine =  "Craft " .. tostring(self:SetSolventLevel(isPoison)) .. " of " ..  pattern[2] .. ":"
		end
		
		if pattern[3] ~= nil then traits[#traits + 1] = pattern[3] end
		if pattern[4] ~= nil then traits[#traits + 1] = pattern[4] end
		
		IsJustaEasyAlchemy.AlchemyHList.List = {craftLine = craftLine, traits = traits}
		local parameterList = self:GetAlchemyPanel()
		return parameterList
	end

end

function IsJustaEasyAlchemy:GetAlchemyPanel()
	GAMEPAD_ALCHEMY_CREATION_SCENE:UnregisterCallback("StateChange", IJAWH.onStateChangedCallback)
	local patternList = tostring(IsJustaEasyAlchemy.AlchemyHList.List.craftLine)
	
	local traits = IsJustaEasyAlchemy.AlchemyHList.List.traits
	if patternList ~= nil then
	
		local qName = IJAWH_CurrentWrit.qName
		local maximum, _, _, parameterList, solventLink = IJAWH:GetAlchemyDetails(nil, nil, 1, qName, patternList, 1, traits)
		local pattern = IJAWH:ConvertedJournalCondition(patternList)
		return parameterList
	end
end

function IsJustaEasyAlchemy:SetEffectList(key,data)
	IsJustaEasyAlchemy.AlchemyHList.Trait[key]:Clear()
	if data.Table ~= nil then
		for i=1, #data.Table do
			IsJustaEasyAlchemy.AlchemyHList.Trait[key]:AddEntry({trait = data.Table[i].trait, Table = data.Table[i]})
		end
		IsJustaEasyAlchemy.AlchemyHList.Trait[key]:Commit()
	end
end

function IsJustaEasyAlchemy:PurgeSelectors()
	IsJustaEasyAlchemy.AlchemyHList.pattern = {[1] = nil, [2] = nil, [3] = nil, [4] = nil, [5] = nil, [6] = nil}
	IsJustaEasyAlchemy.AlchemyHList.List = {}
	for i=1, 3 do IsJustaEasyAlchemy.AlchemyHList.Trait[i]:Clear() end
	IsJustaEasyAlchemy.AlchemyHList.solventType:Clear()
end

local function setKeyboardAnchors()
	IsJustaEasyAlchemy.AlchemyHList:ClearAnchors()
	IsJustaEasyAlchemy.AlchemyHList:SetAnchor(TOPLEFT, ZO_AlchemyTopLevelSlotContainer, TOPLEFT, -30, 35)
	IsJustaEasyAlchemy.AlchemyHList.solventControl:SetAnchor(TOPLEFT, IsJustaEasyAlchemy.AlchemyHList, TOPLEFT, 0, 0)
	IsJustaEasyAlchemy.AlchemyHList.trait1Control:SetAnchor(TOPLEFT, IsJustaEasyAlchemy.AlchemyHList.solventControl, nil, 200, 0)
	IsJustaEasyAlchemy.AlchemyHList.trait2Control:SetAnchor(TOPLEFT, IsJustaEasyAlchemy.AlchemyHList.trait1Control, nil, 200, 0)
	IsJustaEasyAlchemy.AlchemyHList.trait3Control:SetAnchor(TOPLEFT, IsJustaEasyAlchemy.AlchemyHList.trait2Control, nil, 200, 0)
	IsJustaEasyAlchemy_LoadingProgress:ClearAnchors()
	IsJustaEasyAlchemy_LoadingProgress:SetAnchor(CENTER, GuiRoot, nil, 0, 0)
end

local function setGamepadAnchors()
	-- for gamepad mode
	IsJustaEasyAlchemy.AlchemyHList:ClearAnchors()
	IsJustaEasyAlchemy.AlchemyHList:SetAnchor(TOPLEFT, ZO_GamepadAlchemyTopLevelSlotContainer, TOPLEFT, -398, -30)
	IsJustaEasyAlchemy.AlchemyHList.solventControl:SetAnchor(TOPLEFT, IsJustaEasyAlchemy.AlchemyHList, TOPLEFT, 0, 0)
	IsJustaEasyAlchemy.AlchemyHList.trait1Control:SetAnchor(TOPLEFT, IsJustaEasyAlchemy.AlchemyHList.solventControl, nil, 232, 0)
	IsJustaEasyAlchemy.AlchemyHList.trait2Control:SetAnchor(TOPLEFT, IsJustaEasyAlchemy.AlchemyHList.trait1Control, nil, 232, 0)
	IsJustaEasyAlchemy.AlchemyHList.trait3Control:SetAnchor(TOPLEFT, IsJustaEasyAlchemy.AlchemyHList.trait2Control, nil, 232, 0)
	IsJustaEasyAlchemy_LoadingProgress:ClearAnchors()
	IsJustaEasyAlchemy_LoadingProgress:SetAnchor(CENTER, ZO_GamepadAlchemyTopLevelSlotContainer, nil, 0, -300)
end

function IsJustaEasyAlchemy:OnAlchemyStation()
	if IsInGamepadPreferredMode() then
		setGamepadAnchors()
	else
		setKeyboardAnchors()
	end
	if not IsJustaEasyAlchemy.AlchemyHList.solventType then 
		self:SetupSelecters()
	end
	self:InitialiseSolventList()
	
	IJAWH.craftPanel.header:SetText(GetString(SI_IJAWH_EASYALCHEMY))
	IJAWH.craftPanel.icon:SetTexture(IJAWH.iconList[GetCraftingInteractionType()])
	
	if not IJAWH.savedVariables.tutorials.IJAWH_TUTORIAL_EASYALCHEMY then 
		IJAWH:DialogueQueue("IJAWH_TUTORIAL_EASYALCHEMY")
	end
end

function IsJustaEasyAlchemy:OnCloseAlchemyStation()
	if IsJustaEasyAlchemy.isEasyAlchemy then
		for i=1, #IJAWH.writData do
			if string.match(IJAWH.writData[i].qName, GetString(SI_IJAWH_EASYALCHEMY)) then
				table.remove(IJAWH.writData,i)
			end
		end
		
		IsJustaEasyAlchemy.AlchemyHList:ClearAnchors()
	
		table.remove(IJAWH.writData, IJAWH_WD_INDEX)
		EVENT_MANAGER:UnregisterForUpdate("IJAWH_UpdateTic")
		EVENT_MANAGER:UnregisterForUpdate("IJAWH_RepeatProgress")
		IJAWH.activeEvents.UpdateTicRegistered = false
		
		IsJustaEasyAlchemy.LoadignProgressAnimation:PlayBackward()
		IsJustaEasyAlchemy.isEasyAlchemy = false 
	end
end

function IsJustaEasyAlchemy:Initialize()
	self:CreateAlchemyPanel()
end