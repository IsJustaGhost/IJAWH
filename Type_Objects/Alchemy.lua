-------------------------------------
-- Alchemy
-------------------------------------
local Alchemy_Writ_Object = IJA_WritHelper_Shared_Writ_Object:Subclass()

function Alchemy_Writ_Object:GetRecipeData(conditionInfo)
	local itemId = conditionInfo.itemId
	local traitIds = {}
	if conditionInfo.isMasterWrit then
		--If this is a master writ, we need different alchemy information than for normal writs
		if ZO_Alchemy_IsThirdAlchemySlotUnlocked() and conditionInfo.encodedAlchemyTraits then
			local traits = self:GetTraitsFromEncodedAlchemyTraits(conditionInfo.encodedAlchemyTraits)
			for key,trait in pairs(traits) do
				table.insert(traitIds, trait)
			end
		end
	else
		local traitId = GetTraitIdFromBasePotion(conditionInfo.itemId)
		table.insert(traitIds, traitId)
		conditionInfo.encodedAlchemyTraits = self:GetEncodedAlchemyTraits(traitIds)
	end
	
	local resultType = conditionInfo.isPoison and 2 or 1
	local solventData = self:GetSolventForWrit()
	
	if not solventData then return end
	local recipeData = {
		["solventData"] = solventData,
		["traitIds"]	= traitIds,
		["type"]		= resultType,
	}
	
	local function OnScanComplete(data)
		self.alchemyRecipeData = data[1]
		self.alchemyRecipeData.solventData = solventData
		CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
	end

	self:GetAlchemyRecipes(resultType, traitIds, solventData, OnScanComplete)

	local itemLink = self:GetResultItemLink(recipeData)
	return recipeData, itemId, itemLink
end

function Alchemy_Writ_Object:AutoCraft()
	local solventBagId, solventSlotIndex, reacgent1BagId, reacgent1Slot, reacgent2BagId, reacgent2Slot, reacgent3BagId, reacgent3Slot = self:GetAllCraftingBagAndSlots()

	local maxIterations, craftingResult = GetMaxIterationsPossibleForAlchemyItem(solventBagId, solventSlotIndex, reacgent1BagId, reacgent1Slot, reacgent2BagId, reacgent2Slot, reacgent3BagId, reacgent3Slot)
	local numIterations = self:GetRequiredIterations()
	-- numIterations = no more than the maximum amount that can be crafted
		numIterations = maxIterations < numIterations and maxIterations or numIterations
	if maxIterations >= numIterations then
		zo_callLater(function()
--d( solventBagId, solventSlotIndex, reacgent1BagId, reacgent1Slot, reacgent2BagId, reacgent2Slot, reacgent3BagId, reacgent3Slot)
--			CraftAlchemyItem(solventBagId, solventSlotIndex, reacgent1BagId, reacgent1Slot, reacgent2BagId, reacgent2Slot, reacgent3BagId, reacgent3Slot, numIterations)
			self:TryCraftItem(CraftAlchemyItem, solventBagId, solventSlotIndex, reacgent1BagId, reacgent1Slot, reacgent2BagId, reacgent2Slot, reacgent3BagId, reacgent3Slot, numIterations)
		end, 100)
	else
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString("SI_TRADESKILLRESULT", craftingResult))
	end
end

function Alchemy_Writ_Object:GetPerIteration()
    local skillType, skillIndex = GetCraftingSkillLineIndices(CRAFTING_TYPE_ALCHEMY)
    local abilityIndex = 4
    local abilityName, _, _, _, _, purchased, _, rankIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
    if (not purchased) then
        rankIndex = 0
    end
	
    if self.isPoison then
        rankIndex = (rankIndex * 4) + 3
    end
    return rankIndex + 1
end

function Alchemy_Writ_Object:GetMissingMessage()
	local missingMessage = {}
	
	if (self.isMasterWrit and not ZO_Alchemy_IsThirdAlchemySlotUnlocked()) then
		table.insert(missingMessage, GetString("SI_TRADESKILLRESULT", 16))
	end
	
	local skillType, skillIndex = GetCraftingSkillLineIndices(CRAFTING_TYPE_ALCHEMY)
	local abilityIndex = 1
	local rankIndex = select(8, GetSkillAbilityInfo(skillType, skillIndex, abilityIndex))
	if rankIndex < GetItemLinkRequiredCraftingSkillRank(self.itemLink) then
		table.insert(missingMessage, GetString("SI_TRADESKILLRESULT", 16))
	end
	
	local solventBagId, solventSlot, reacgent1BagId, reacgent1Slot, reacgent2BagId, reacgent2Slot, reacgent3BagId, reacgent3Slot = self:GetAllCraftingBagAndSlots()
	local numIterations = self:GetRequiredIterations()
	if solventSlot then
		IJA_WRITHELPER:AddCraftItemUsed(GetItemId(solventBagId, solventSlot), self.conditionId, numIterations)
	end
	if reacgent1Slot then
		IJA_WRITHELPER:AddCraftItemUsed(GetItemId(reacgent1BagId, reacgent1Slot), self.conditionId, numIterations)
	end
	if reacgent2Slot then
		IJA_WRITHELPER:AddCraftItemUsed(GetItemId(reacgent2BagId, reacgent2Slot), self.conditionId, numIterations)
	end
	if reacgent3Slot then
		IJA_WRITHELPER:AddCraftItemUsed(GetItemId(reacgent3BagId, reacgent3Slot), self.conditionId, numIterations)
	end

	local maxIterations, limitReason = self:GetMaxIterations()
	if numIterations > maxIterations then
		table.insert(missingMessage, GetString("SI_TRADESKILLRESULT", limitReason))
	end
	
	return missingMessage
end

--					-----------------------------------------------------------
function Alchemy_Writ_Object:SetStation()
	self:SetResultPanelHeader(self.parent.name)

	if not IsJustaEasyAlchemy then
		local resultType, traitIds, solventData = self:GetScanData()
		self:TryAddSolventToCraft(solventData, true, false)
		local function OnScanComplete(data)
			if data == nil then d( 'no recipe data') return end
			self.alchemyRecipeData = data[1]
			self.alchemyRecipeData.solventData = solventData
		end

		self:GetAlchemyRecipes(resultType, traitIds, solventData, OnScanComplete)
	else
		-- reset lists for Easy Alchemy to select the solvent and traits needed
		IJA_EASYALCHEMY:RefreshAllLists()
	end
end

function Alchemy_Writ_Object:SelectMode()
	if SCENE_MANAGER:GetPreviousSceneName() == 'hud' then
		if IJA_WRITHELPER.isGamepadMode then
			if IsJustaEasyAlchemy then
				SCENE_MANAGER:Push("ija_gamepad_alchemy_creation")
			else
				SCENE_MANAGER:Push("gamepad_alchemy_creation")
			end
		else
			ALCHEMY:SetMode(ZO_ALCHEMY_MODE_CREATION)
		end
	end
end

function Alchemy_Writ_Object:GetTooltipData(recipeData)
	return recipeData.traitIds, recipeData.solventData.itemId
end

function Alchemy_Writ_Object:GetScanData()
	return self.recipeData.type, self.recipeData.traitIds, self.recipeData.solventData
end

function Alchemy_Writ_Object:GetSolventForWrit()
	local conditionInfo = self.conditionInfo
	
	local list = self:GetAlchemyItems()
	if list then
		for _, data in pairs(list) do
			--If this is a valid solvent for the item and material id, then add it to the list of potential solvents
			if conditionInfo.itemId and conditionInfo.materialItemId and IsAlchemySolventForItemAndMaterialId(data.bagId, data.slotIndex, conditionInfo.itemId, conditionInfo.materialItemId) then
				
				local itemLink = GetItemLink(data.bagId, data.slotIndex)
				local icon, _, meetsUsageRequirement = GetItemLinkInfo(itemLink)
					
				local itemData = {
					name = data.name,
					itemId = GetItemId(data.bagId, data.slotIndex),
					bagId = data.bagId,
					slotIndex = data.slotIndex,
					
					itemType = data.itemType,
					
					stackCount = data.stackCount or 0,
					sellPrice = data.sellPrice,
					
					itemLink = itemLink,
					icon = icon,
					meetsUsageRequirement = meetsUsageRequirement or false,
				}
					
				return itemData
			end
		end
	end
end

function Alchemy_Writ_Object:GetMaxIterations()
	local maxIterations, craftingResult = GetMaxIterationsPossibleForAlchemyItem(self:GetAllCraftingBagAndSlots(true))
	return maxIterations, craftingResult
end

function Alchemy_Writ_Object:GetAllCraftingBagAndSlots(checkCraftingSlots)
	local zo_Object = IJA_WRITHELPER.isGamepadMode and GAMEPAD_ALCHEMY or ALCHEMY
	
	local solventBagId, solventSlotIndex, reacgent1BagId, reacgent1Slot, reacgent2BagId, reacgent2Slot, reacgent3BagId, reacgent3Slot
	if checkCraftingSlots then
		solventBagId, solventSlotIndex, reacgent1BagId, reacgent1Slot, reacgent2BagId, reacgent2Slot, reacgent3BagId, reacgent3Slot = zo_Object:GetAllCraftingBagAndSlots()
	end
	
	if solventSlotIndex == nil or reacgent1Slot == nil or reacgent2Slot == nil then
		local recipeData = self.alchemyRecipeData
		if recipeData == nil then return end
		
		local solventData, reagentData_1, reagentData_2, reagentData_3 = recipeData.solventData, recipeData.reagents[1], recipeData.reagents[2], recipeData.reagents[3]
--d( '--	-', solventData, reagentData_1, reagentData_2, reagentData_3)
		if solventData and reagentData_1 and reagentData_2 then
			solventBagId, solventSlotIndex = ZO_Inventory_GetBagAndIndex(solventData)
			reacgent1BagId, reacgent1Slot = ZO_Inventory_GetBagAndIndex(reagentData_1)
			reacgent2BagId, reacgent2Slot = ZO_Inventory_GetBagAndIndex(reagentData_2)
		end
		if reagentData_3 then
			reacgent3BagId, reacgent3Slot = ZO_Inventory_GetBagAndIndex(reagentData_3)
		else
			reacgent3BagId, reacgent3Slot = nil, nil
		end
	end
	
	return solventBagId, solventSlotIndex, reacgent1BagId, reacgent1Slot, reacgent2BagId, reacgent2Slot, reacgent3BagId, reacgent3Slot
end

function Alchemy_Writ_Object:GetResultItemLink(recipeData)
	local recipeData = recipeData ~= nil and recipeData or self.recipeData
	return self:GetAlchemyResultLink(self:GetTooltipData(recipeData))
end

IJA_WritHelper_Alchemy_Object = Alchemy_Writ_Object


--[[
	
function Smithing_Writ_Object:GetLinkLevel(recipeData)
	if recipeData == nil then recipeData = self.recipeData end
	local materialToLinkLevel ={
		[1]		= "30:1",		-- 
		[8]		= "20:16",		-- 
		[13]	= "20:26",		-- 
		[18] 	= "20:36",		-- 
		[23] 	= "20:46",		-- 
		[26] 	= "125:50",		-- 
		[29] 	= "128:50",		-- 
		[32] 	= "131:50",		-- 
		[34] 	= "133:50",		-- 
		[40] 	= "308:50",		-- 
	}
	
	return materialToLinkLevel[recipeData.materialIndex]
end

function Smithing_Writ_Object:UpdateLinkLevel(itemLink, recipeData)
	local linkString = "(|H0:item:[%d]+:)[%d]+:[%d]+(:[%d:{18}]+|h|h)"
	
	local linkLevel = self:GetLinkLevel(recipeData)
	return itemLink:gsub(linkString, '%1' .. linkLevel  .. '%2')
end
]]