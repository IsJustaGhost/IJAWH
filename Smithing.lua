local indexRanges = {
	[1] = 1,
	[2] = 8,
	[3] = 13,
	[4] = 18,
	[5] = 23,
	[6] = 26,
	[7] = 29,
	[8] = 32,
	[9] = 34,
	[10] = 40,
	[11] = 1,
	[12] = 8,
	[13] = 13,
	[14] = 18,
	[15] = 23,
	[16] = 26,
	[17] = 29,
	[18] = 32,
	[19] = 34,
	[20] = 40,
}
local jewelryIndexRanges = {
	[1] = 1,
	[2] = 13,
	[3] = 26,
	[4] = 33,
	[5] = 40,
}

function IJAWH:SetSmithingResultTooltip(recipeData)
	local _, _, icon = GetSmithingPatternInfo(IJAWH:GetAllCraftingParametersWithoutIteration(recipeData))
	local itemLink = GetSmithingPatternResultLink(IJAWH:GetAllCraftingParametersWithoutIteration(recipeData))
	if itemLink and itemLink ~= "" then
		if IsInGamepadPreferredMode() then
			ZO_GamepadSmithingTopLevelCreationResultTooltipContainerTip:ClearLines()
			ZO_GamepadSmithingTopLevelCreationResultTooltipIcon:SetTexture(icon)
			ZO_GamepadSmithingTopLevelCreationResultTooltipIcon:SetHidden(false)
			ZO_GamepadSmithingTopLevelCreationResultTooltipContainerTip:LayoutItem(itemLink, NOT_EQUIPPED)
		else
			ZO_SmithingTopLevelCreationPanelResultTooltip:ClearLines()		
			ZO_SmithingTopLevelCreationPanelResultTooltipIcon:SetTexture(icon)
			ZO_SmithingTopLevelCreationPanelResultTooltipIcon:SetHidden(false)
			ZO_SmithingTopLevelCreationPanelResultTooltip:SetPendingSmithingItem(IJAWH:GetAllCraftingParametersWithoutIteration(recipeData))
		--[[
			--]]
		end
	end
end

local function GetItemDataFilterComparator(itemType)
	return function(itemData)
		if itemData.itemType == itemType then
			return true
		end
	end
end

local function getStyleIndex(patternIndex)
	local comparator = GetItemDataFilterComparator(ITEMTYPE_STYLE_MATERIAL)
	local styleList = {}
	local bagCache = SHARED_INVENTORY:GenerateFullSlotData(comparator, BAG_BACKPACK, BAG_BANK, BAG_VIRTUAL)
	for slotId, itemData in pairs(bagCache) do
		for i = 1, GetNumValidItemStyles() do
--		for i = 1, 35 do
			local styleIndex = GetValidItemStyleId(i)
			local styleName = GetItemStyleName(styleIndex)
			local itemName = GetSmithingStyleItemInfo(styleIndex)
			if styleIndex ~=36 and IJAWH:Contains(itemData.name, itemName) and IsSmithingStyleKnown(styleIndex, patternIndex) then
				table.insert(styleList,
					{	
						stackCount = itemData.stackCount, 
						styleIndex = styleIndex,
						styleItem = itemName
					}
				)
			end
		end
	end
	table.sort(styleList, function(a,b)return a.stackCount > b.stackCount end)
	return styleList
end

local function getSmithingMaterialAndPattern(qIndex, lineId, traitIndex, maximum)
	local indexTableToUse
	if GetCraftingInteractionType() == CRAFTING_TYPE_JEWELRYCRAFTING then
		indexTableToUse = jewelryIndexRanges
	else
		indexTableToUse = indexRanges
	end
	
	for i = 1, #indexTableToUse do
		local materialIndex = indexTableToUse[i]
		for patternIndex = 1, GetNumSmithingPatterns() do
			local _,_, materialQuantity = GetSmithingPatternMaterialItemInfo(patternIndex, materialIndex)
			itemLink = GetSmithingPatternResultLink(patternIndex, materialIndex,materialQuantity,GetFirstKnownStyleIndex(),traitIndex,maximum)
			if DoesItemLinkFulfillJournalQuestCondition(itemLink, qIndex, 1, lineId) then
				return patternIndex, materialIndex, materialQuantity, itemLink
			end
		end
	end
end

function IJAWH:UpdateSmithingStyleIndex(patternIndex)
	local styleList = getStyleIndex(patternIndex)
	return styleList[1].styleIndex
end

function IJAWH:GetSmithingDetails(qIndex, lineId, step, qName, styleListIndex, maximum, totalMaterialQuantity, totalItems, condition)
	local traitIndex, styleIndex, itemLink, canCraft = 1, 0, nil, true
	totalItems = totalItems + maximum
	local patternIndex, materialIndex, materialQuantity, itemLink = getSmithingMaterialAndPattern(qIndex, lineId, traitIndex, maximum)

	if itemLink ~= nil then
		local styleList = getStyleIndex(patternIndex)
		if IJAWH.savedVariables.useMostStyle then 
			if styleList[styleListIndex].stackCount < totalItems then
				styleListIndex = styleListIndex + 1
			end
			styleIndex = styleList[styleListIndex].styleIndex
		else
			styleIndex = GetFirstKnownStyleIndex()
		end
		
		local stackCount = GetCurrentSmithingMaterialItemCount(patternIndex, materialIndex)

		totalMaterialQuantity = totalMaterialQuantity + materialQuantity
	
		if totalMaterialQuantity > stackCount then
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(SI_TRADESKILLRESULT141))
			canCraft = false	-- "Missing Crafting Material"
		end
		if totalItems > GetCurrentSmithingStyleItemCount(styleIndex) then
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(SI_TRADESKILLRESULT142))
			canCraft = false	-- "Missing Style Material"
		end
		if traitIndex > 1 and totalItems >  GetCurrentSmithingTraitItemCount(traitIndex) then
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(SI_TRADESKILLRESULT143))
			canCraft = false	-- "Missing Trait Material"
		end
		
		if not CheckInventorySpaceSilently(totalItems) then
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(SI_ACTIONRESULT3430))
			canCraft = false	-- "You do not have enough inventory space."
		end
	
		local maxIterations = GetMaxIterationsPossibleForSmithingItem(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
--		if maxIterations >= maximum and totalMaterialQuantity <= stackCount then
			if not IJAWH.writData[IJAWH_WD_INDEX].recipeData[step] then IJAWH.writData[IJAWH_WD_INDEX].recipeData[step] = {} end

			IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData] = {
				patternIndex 		= patternIndex,
				materialIndex 		= materialIndex, 
				materialQuantity 	= materialQuantity, 
				styleIndex			= styleIndex,
				traitIndex 			= traitIndex,
				numIterations 		= maximum,
				itemLink			= itemLink,
				canCraft 			= canCraft
			}
			
			return totalMaterialQuantity, totalItems, styleListIndex, traitIndex, itemLink
--		end
	end
	return totalMaterialQuantity, totalItems, styleListIndex, traitIndex, itemLink
end

function IJAWH:ParseSmithingQuest(qName, qIndex, lineId)
	local totalMaterialQuantity, totalItems, styleListIndex = 0, 0, 1
	local step, traitIndex = 0, 0
	IJAWH_CurrentWrit.recipeData = {}
	for lineId = 1, GetJournalQuestNumConditions(qIndex,1) do
		local inBank, itemLink, amountRequired = false,'',''
		local condition,current,maximum,_,complete = GetJournalQuestConditionInfo(qIndex,1,lineId)
		if condition ~= '' then
			if IJAWH:Contains(condition, IJAWH:AcquireConditions()) then
				if current ~= maximum then
					inBank, itemLink, amountRequired = IJAWH:GetAcquireItem(qName, lineId, condition, maximum)
				end
			elseif IJAWH:Contains(condition, IJAWH:CraftingConditions()) then
				if current ~= maximum then
					step = step + 1
					totalMaterialQuantity, totalItems, styleListIndex, traitIndex, itemLink = self:GetSmithingDetails(qIndex, lineId, step, qName, styleListIndex,maximum, totalMaterialQuantity, totalItems, condition)
				end
			end
		end
	end
--	error( "ParseSmithingQuest")
end