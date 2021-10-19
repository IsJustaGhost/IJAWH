function IJAWH:SetProvisioningResultTooltip(recipeData)
    if recipeData then
		local recipeListIndex = recipeData.recipeListIndex
		local recipeIndex = recipeData.recipeIndex
		local numIngredients = recipeData.numIngredients
		
		if IsInGamepadPreferredMode() then
			ZO_GamepadProvisionerTopLevelTooltip["tip"]:ClearLines()
			ZO_GamepadProvisionerTopLevelTooltip["tip"]:SetProvisionerResultItem(recipeListIndex, recipeIndex)
		
			-- populate gamepad ingredients bar
			GAMEPAD_PROVISIONER.ingredientsBar:Clear()
			for i = 1, numIngredients do
				local newData = {
					recipeListIndex = recipeListIndex,
					recipeIndex = recipeIndex,
					ingredientIndex = i,
				}
				GAMEPAD_PROVISIONER.ingredientsBar:AddEntry("ZO_ProvisionerIngredientBarSlotTemplate", newData)
			end
			GAMEPAD_PROVISIONER.ingredientsBar:Commit()
		else
			ZO_ProvisionerTopLevelTooltip:ClearLines()
			ZO_ProvisionerTopLevelTooltip:SetProvisionerResultItem(recipeListIndex, recipeIndex)
			
			-- populate keyboard ingredients bar
			for ingredientIndex, ingredientSlot in ipairs(PROVISIONER.ingredientRows) do
				if ingredientIndex > numIngredients then
					ingredientSlot:ClearItem()
				else
					local name, icon, requiredQuantity, _, displayQuality = GetRecipeIngredientItemInfo(recipeListIndex, recipeIndex, ingredientIndex)
					local numIterations = PROVISIONER:GetMultiCraftNumIterations()
					if numIterations > 1 then
						requiredQuantity = requiredQuantity * numIterations
					end
					local ingredientCount = GetCurrentRecipeIngredientCount(recipeListIndex, recipeIndex, ingredientIndex)
					ingredientSlot:SetItem(name, icon, ingredientCount, displayQuality, requiredQuantity)
					ingredientSlot:SetItemIndices(recipeListIndex, recipeIndex, ingredientIndex)
				end
			end
			
		end	
    end
end

function IJAWH:ResetProvisioningResultTooltip()
	for recipeListIndex = 1, GetNumRecipeLists() do -- parse all recipes
		local recipeListName, numRecipes, upIcon, downIcon, overIcon, _, recipeListCreateSound = GetRecipeListInfo(recipeListIndex)
		for recipeIndex = 1, numRecipes do
			local known, recipeName, numIngredients = GetRecipeInfo(recipeListIndex,recipeIndex)
			if known then
				local recipeData = {recipeListIndex = recipeListIndex, recipeIndex = recipeIndex, numIngredients = numIngredients}
				self:SetProvisioningResultTooltip(recipeData)
				return
			end
		end
	end
end
local function getProvisioningNumPerIteration(recipeListIndex,recipeIndex)
    local recipeLink = GetRecipeResultItemLink(recipeListIndex,recipeIndex)
    local itemType = GetItemLinkItemType(recipeLink)
	
    local skillType, skillIndex = GetCraftingSkillLineIndices(CRAFTING_TYPE_PROVISIONING)
    local abilityIndex = 5
    if itemType == ITEMTYPE_DRINK then
        abilityIndex = 6
    end
    local abilityName, _, _, _, _, purchased, _, rankIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
    if (not purchased) then
        rankIndex = 0
    end

    abilityName = abilityName:gsub("(\^)%a*", "")
    return 1 + rankIndex
end

function IJAWH:GetProvisioningDetails(qIndex, lineId, step, qName, condition, maximum)
	local recipeTypes = {ITEMTYPE_DRINK,ITEMTYPE_FOOD}
	local addDetails, stocklist = '', ''
	local ingredients = {}
	
	local isMaster 
	if qName then
		isMaster = string.find(qName, "Provisioner") and false or true
	end
	
	local canCraft = true
	for recipeListIndex = 1, GetNumRecipeLists() do
		local recipeListName, numRecipes, upIcon, downIcon, overIcon, _, recipeListCreateSound = GetRecipeListInfo(recipeListIndex)

		for recipeIndex = 1, numRecipes do -- parse all recipes in list
			local known, recipeName, numIngredients, _, specialIngredientType = GetRecipeInfo(recipeListIndex,recipeIndex)

			if condition ~= "progress" then
				local convertedQuestCondition = self:ConvertedJournalCondition(condition)
				local convertedRecipeName = self:ConvertedJournalCondition(recipeName)
				local itemLink = GetRecipeResultItemLink(recipeListIndex, recipeIndex)
				if DoesItemLinkFulfillJournalQuestCondition(itemLink, qIndex, 1, lineId) or (isMaster and string.match(convertedQuestCondition, recipeName))then

					if itemLink == '' then
						itemLink = string.gsub(condition, ":.*", ""):gsub("^[%w]+%s","")
					end
					local inBank, amountRequired = self:IsRequieredInBank(qIndex, qName, lineId, itemLink, maximum)
					if not known then
						ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(SI_TRADESKILLRESULT100) .. " " .. recipeName)
						canCraft = false
					end
				
					if not IJAWH.writData[IJAWH_WD_INDEX].recipeData[step] then IJAWH.writData[IJAWH_WD_INDEX].recipeData[step] = {} end
					if not IJAWH.writData[IJAWH_WD_INDEX].ingredients[step] then IJAWH.writData[IJAWH_WD_INDEX].ingredients[step] = {} end
	
					local numIterations = math.ceil(maximum / getProvisioningNumPerIteration(recipeListIndex,recipeIndex))
					
					if numIterations == 0 then canCraft = false end
					IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData] = {
						resultName = recipeName, 
						recipeListIndex = recipeListIndex, 
						recipeIndex = recipeIndex, 
						listIndex = listIndex, 
						numIngredients = numIngredients, 
						createSound = recipeListCreateSound, 
						numIterations = numIterations,
						specialIngredientType = specialIngredientType,
						hasOther = hasOther,
						itemLink = itemLink,
						canCraft = canCraft
					}
						
					IJAWH.writData[IJAWH_WD_INDEX].ingredients[step] = {
						[1] = recipeListIndex,
						[2] = recipeIndex,
						[3] = numIterations,
						[4] = maximum,
						func = function(params)
							local recipeListIndex, recipeIndex, numIterations, maximum = params[1], params[2], params[3], params[4]
							local known, recipeName, numIngredients, _, specialIngredientType = GetRecipeInfo(recipeListIndex,recipeIndex)
							if known then
								local ingredList = ''
								local yPos = 25
								for z = 1, numIngredients do
									local numNeeded = numIterations and (GetRecipeIngredientRequiredQuantity(recipeListIndex,recipeIndex,z) * numIterations) or maximum
									local itemLink = GetRecipeIngredientItemLink(recipeListIndex,recipeIndex,z)
									local itemData = IJAWH:getItemDataFromLink(itemLink)
									local label, stackLabel, hasEnough = IJAWH:GetIngredientLabel(itemData,numNeeded)
									if z==3 then 
										ingredList = ingredList .. "\n"
										yPos = yPos + 25
									end
									if ingredList == '' then ingredList = label .. ": " .. stackLabel .. ", "  else ingredList = ingredList.. label .. ": " .. stackLabel .. ", "  end
								end
								ingredList = string.gsub(ingredList, ",$", "")
								return ingredList, yPos
							else
								return zo_strformat("|c<<1>><<2>>|r","E93C3C",GetString(SI_ITEM_FORMAT_STR_UNKNOWN_RECIPE)), 25
							end
						end
					}
					return amountRequired, itemLink, inBank
				end
			end
		end
	end
end

function IJAWH:ParseProvisioningQuest(qName, qIndex, lineId)
	local withdrawText, step = {}, 0
	IJAWH_CurrentWrit.recipeData = {}
	for lineId = 1, GetJournalQuestNumConditions(qIndex,1) do
		local inBank, itemLink, amountRequired = false,'',''
		local condition,current,maximum,_,complete = GetJournalQuestConditionInfo(qIndex,1,lineId)
		if condition ~= '' then
			if IJAWH:Contains(condition, IJAWH:AcquireConditions()) then
				if current ~= maximum then
					inBank, itemLink, amountRequired = IJAWH:GetAcquireItem(qIndex, qName, lineId, condition, maximum)
				end
			elseif IJAWH:Contains(condition, IJAWH:CraftingConditions()) then
				if current ~= maximum then
					step = step + 1
					amountRequired, itemLink, inBank = self:GetProvisioningDetails(qIndex, lineId, step, qName, condition, maximum)
				end
			end
		end
		if inBank == true then 
			withdrawText[#withdrawText + 1] = zo_strformat(SI_IJAWH_WITHDRAW_FROM_BANK_ITEMS, "E6E93C", amountRequired, itemLink)
		end
	end
	return withdrawText
end