<<<<<<< HEAD
=======

local isGamepadMode = IJA_WRITHELPER.isGamepadMode
>>>>>>> 24e0d3fce82455052f34b6c61351b5ef86aa7008
--------------ZO Writ Advisor--------------
local function GetMissingMessage(questInfo, conditionInfo, currentCount, maxCount)
    --If we have already met the condition requirements, we no longer care about what components we have
    if currentCount < maxCount then
		local currentRecipe, CurrentRecipe_Object
		if IJA_WRITHELPER.currentWrit and IJA_WRITHELPER.currentWrit.currentRecipe then
			CurrentRecipe_Object = IJA_WRITHELPER.currentWrit.currentRecipe
		end

        if conditionInfo.craftingType == CRAFTING_TYPE_ENCHANTING then
            local potencyRune, essenceRune, aspectRune = GetRunesForItemIdIfKnown(conditionInfo.itemId, conditionInfo.materialItemId, conditionInfo.itemFunctionalQuality)
            --GetRunesForItemIdIfKnown will return nil for all values if any of the runes are unknown
            --Therefore, checking any of them for nil would be sufficient, it doesn't have to be potency
            if potencyRune == nil then
                return GetString(SI_ENCHANTING_UNKNOWN_RUNES), GetString(SI_CRAFT_ADVISOR_UNKNOWN_RUNES_TOOLTIP)
            elseif not DoesPlayerHaveRunesForEnchanting(aspectRune, essenceRune, potencyRune) then
                return GetString(SI_CRAFTING_MISSING_ITEMS), GetString(SI_CRAFT_ADVISOR_ENCHANTING_MISSING_ITEMS_TOOLTIP)
            end
        elseif conditionInfo.craftingType == CRAFTING_TYPE_PROVISIONING then
            local recipeLists = PROVISIONER_MANAGER:GetRecipeListData(conditionInfo.craftingType)
            --Look for a matching recipe
            for listIndex, recipeList in pairs(recipeLists) do
                for _, recipe in ipairs(recipeList.recipes) do
                    --If we have a match, then we're done, return early
                    if recipe.resultItemId == conditionInfo.itemId then
                        return
                    end
                end
            end
            --If we get here, that means we are missing the recipe
            return GetString(SI_PROVISIONER_MISSING_RECIPE), GetString(SI_CRAFT_ADVISOR_PROVISIONING_MISSING_RECIPE_TOOLTIP)
        elseif conditionInfo.craftingType == CRAFTING_TYPE_ALCHEMY then
            local validCombinationFound = false
            local needsThirdSlot = conditionInfo.isMasterWrit and GetNonCombatBonus(NON_COMBAT_BONUS_ALCHEMY_THIRD_SLOT) == 0
            --Check and see if the alchemy logic has found any valid combinations
<<<<<<< HEAD
            if IsInGamepadPreferredMode() then   
=======
            if isGamepadMode then   
>>>>>>> 24e0d3fce82455052f34b6c61351b5ef86aa7008
                validCombinationFound = GAMEPAD_ALCHEMY:HasValidCombinationForQuest()
            else
                validCombinationFound = ALCHEMY:HasValidCombinationForQuest()
            end
            if needsThirdSlot then
                return GetString(SI_ALCHEMY_REQUIRES_THIRD_SLOT), GetString(SI_CRAFT_ADVISOR_ALCHEMY_REQUIRES_THIRD_SLOT_TOOLTIP)
            elseif not validCombinationFound then
                return GetString(SI_ALCHEMY_MISSING_OR_UNKNOWN), GetString(SI_CRAFT_ADVISOR_ALCHEMY_MISSING_OR_UNKNOWN_TOOLTIP)
            end
		elseif IsSmithingCraftingType(conditionInfo.craftingType) and conditionInfo.craftingType == GetCraftingInteractionType() then
			-- ZOS did not add a method for missing smithing items
			local totalMaterial, totalItems, itemStyleId = 0, 0, 0
			local missingMessage = ''
--			local patternIndex, materialIndex = GetSmithingPatternInfoForItemId(conditionInfo.itemId, conditionInfo.materialItemId, conditionInfo.craftingType)
		
			if CurrentRecipe_Object ~= nil then
				local patternIndex, materialIndex, materialQuantity, itemStyleId, itemTraitType = CurrentRecipe_Object:GetCraftingParametersWithoutIterations()
				for itemId, recipeObject in pairs(IJA_WRITHELPER.currentWrit.conditions) do
					local condition, current, maximum = recipeObject:GetUpdateConditionAndCounts()
					-- build material quantity that will be used by all items to be crafted
					if recipeObject.condition ~= '' and current ~= maximum then
						local iterations = recipeObject:GetRequiredIterations()
						local materialQuantity = select(3, recipeObject:GetCraftingParametersWithoutIterations())
						totalMaterial = totalMaterial + materialQuantity * iterations
						totalItems = totalItems + iterations
					end
				end
	
				if totalMaterial > GetCurrentSmithingMaterialItemCount(patternIndex, materialIndex) then
					missingMessage = "     " .. GetString(SI_TRADESKILLRESULT141)
				end
				
				if itemStyleId == 0 then 
					if missingMessage == '' then
						missingMessage = "     " .. GetString(SI_TRADESKILLRESULT142)
					else
						missingMessage = missingMessage .. "\n"  .. "     " .. GetString(SI_TRADESKILLRESULT142)
					end
				end

				if itemTraitType > 0 and totalItems > GetCurrentSmithingTraitItemCount(itemTraitType) then
					if missingMessage == '' then
						missingMessage = "     " .. GetString(SI_TRADESKILLRESULT143)
					else
						missingMessage = missingMessage .. "\n"  .. "     " .. GetString(SI_TRADESKILLRESULT143)
					end
				end
				return missingMessage, GetString(SI_IJAWH_CRAFT_ADVISOR_SMITHING_MISSING_TOOLTIP)
				--	GetString(SI_TRADESKILLRESULT141), GetString(SI_IJAWH_CRAFT_ADVISOR_SMITHING_MISSING_MATERIAL_TOOLTIP)
			end
		end
    end
end

ZO_PreHook(ZO_WRIT_ADVISOR_GAMEPAD, "RebuildConditions", function(self, questInfo)
	zo_callLater(function()
		self.questConditionControlPool:ReleaseAllObjects()
		if questInfo then
			local _, _, _, _, conditionCount = GetJournalQuestStepInfo(questInfo.questIndex, QUEST_MAIN_STEP_INDEX)
			local previousControl = nil
			--Add the conditions
			for conditionIndex = 1, conditionCount do
				local conditionText, curCount, maxCount, isFailCondition, isComplete, _, isVisible, conditionType = GetJournalQuestConditionInfo(questInfo.questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex)
				if (not isFailCondition) and (conditionText ~= "") and not isComplete and isVisible then
					if curCount == maxCount or string.find(conditionText, GetString(SI_IJAWH_DELIVER)) then
						conditionText = zo_strformat("|c<<1>><<2>>|r","00cc00",conditionText)
					end
						
					local control = self.questConditionControlPool:AcquireObject()
					control:ClearAnchors()
					control:SetText(conditionText)
					control:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))

					--Determine if we need to anchor to the header or to a previous condition
					if previousControl ~= nil then
						control:SetAnchor(TOPRIGHT, previousControl, BOTTOMRIGHT, 0, 16)
					else
						control:SetAnchor(TOPRIGHT, self.questHeader, BOTTOMRIGHT, 0, 16)
					end
					previousControl = control
					--Check if we need to add an error message underneath this condition
					if questInfo.conditionData[conditionIndex] and questInfo.conditionData[conditionIndex].conditionIndex == conditionIndex then
						local missingMessage = GetMissingMessage(questInfo, questInfo.conditionData[conditionIndex], curCount, maxCount)
						if missingMessage then
							local missingControl = self.questConditionControlPool:AcquireObject()
							missingControl:ClearAnchors()
							missingControl:SetText(missingMessage)
							missingControl:SetColor(ZO_ERROR_COLOR:UnpackRGBA())
							missingControl:SetAnchor(TOPRIGHT, previousControl, BOTTOMRIGHT)
							previousControl = missingControl
						end
					end
				end
			end      
		end
	end, 50)
end)

ZO_PreHook(ZO_WRIT_ADVISOR_WINDOW, "RefreshQuestList", function(self)
	zo_callLater(function()
		if WRIT_ADVISOR_FRAGMENT:IsShowing() and not ZO_CraftingUtils_IsPerformingCraftProcess() then
			local quests = self.questMasterList
			self.questIndexToTreeNode = {}
			-- Add items to the tree
			self.navigationTree:Reset()
			local questNodes = {}
			local firstNode = nil
			local previousNode = nil 
			local assistedNode = nil
			
			for i, questInfo in ipairs(quests) do
				--First, add the quest name
				questNodes[questInfo] = self.navigationTree:AddNode("ZO_ActiveWritHeader", questInfo)
				self.questIndexToTreeNode[questInfo.questIndex] = questNodes[questInfo]
				local _, _, _, _, conditionCount = GetJournalQuestStepInfo(questInfo.questIndex, QUEST_MAIN_STEP_INDEX)
				local conditionInfoIndex = 1;
				--Add the conditions for the quest
				for conditionIndex = 1, conditionCount do
					local conditionText, curCount, maxCount, isFailCondition, isComplete, _, isVisible, conditionType = GetJournalQuestConditionInfo(questInfo.questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex)

					if (not isFailCondition) and (conditionText ~= "") and not isComplete and isVisible then
						if curCount == maxCount or string.find(conditionText, GetString(SI_IJAWH_DELIVER)) then
							conditionText = zo_strformat("|c<<1>><<2>>|r","00cc00",conditionText)
						else
	--						conditionText = 
						end
						local taskNode = self.navigationTree:AddNode("ZO_ActiveWritNavigationEntry", {name = conditionText}, questNodes[questInfo])
						firstNode = firstNode or taskNode
						if previousNode then
							previousNode.nextNode = taskNode
						end
						if i == #quests and conditionIndex == conditionCount then
							taskNode.nextNode = firstNode
						end
						--Select the first quest in the list that has incomplete crafting tasks
						if assistedNode == nil and curCount < maxCount then
							local questNode = questNodes[questInfo]
							assistedNode = questNode
						end
						previousNode = taskNode
						--There are certain cases where we want to defer adding the missing text, so don't do it here in that case
						if not CRAFT_ADVISOR_MANAGER:ShouldDeferRefresh() then
							--Determine if we need to add an error message after this condition
							if questInfo.conditionData[conditionInfoIndex] and questInfo.conditionData[conditionInfoIndex].conditionIndex == conditionIndex then
								local missingMessage, missingDescription = GetMissingMessage(questInfo, questInfo.conditionData[conditionInfoIndex], curCount, maxCount)
								if missingMessage then
									local missingNode = self.navigationTree:AddNode("ZO_ActiveWritNavigationEntry", {errorHeader = missingMessage, errorText = missingDescription, missing = true}, questNodes[questInfo])
									previousNode.nextNode = missingNode
									if i == #quests and conditionIndex == conditionCount then
										missingNode.nextNode = firstNode
									end
									previousNode = missingNode
								end
								conditionInfoIndex = conditionInfoIndex + 1
							end
					   end
					end
				end
			end
			self.navigationTree:Commit(assistedNode)
			self.dirtyFlag = false
		else
			self.dirtyFlag = true
		end
	end, 50)
	return true
end)