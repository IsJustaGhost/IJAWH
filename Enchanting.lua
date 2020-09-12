function IJAWH:addRunesToCraft(recipeData)
	for i=1, #recipeData do
		if recipeData[i].meetsUsageRequirement then
			local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(recipeData[i])
			if IsInGamepadPreferredMode() then
				GAMEPAD_ENCHANTING:AddItemToCraft(bagId, slotIndex)
			else
				ENCHANTING:AddItemToCraft(bagId, slotIndex)
			end
		end
	end
	if IsInGamepadPreferredMode() then
		GAMEPAD_ENCHANTING:UpdateSelection()
--		GAMEPAD_CRAFTING_RESULTS:SetTooltipAnimationSounds(nil)
	else
		ENCHANTING.inventory:HandleDirtyEvent()
--		CRAFTING_RESULTS:SetTooltipAnimationSounds(nil)

	end
end

local function getLinkLevel(skillImprovment,aspectIndex)
	return (skillImprovment[1] + aspectIndex - 1),skillImprovment[2]
end
local function getUsageRequirment(itemlink)
	local _, _, meetsUsageRequirement, _, _ = GetItemLinkInfo(itemlink)
	return meetsUsageRequirement
end
local function DoesItemLinkFulfillWritCondition(itemLink, condition)
	local qualityList = {
		["Common"] 		= 1, ["Ta"] 		= 1,
		["Fine"] 		= 2, ["Jejota"] 	= 2,
		["Superior"] 	= 3, ["Denata"] 	= 3,
		["Epic"] 		= 4, ["Rekuta"] 	= 4,
		["Legendary"] 	= 5, ["Kuta"] 		= 5
	}
	local qualtyConvert = {
		{"Craft%sa%s.*%c.*:%s(.*)%c.*", 	"%1"}, 	-- enchanting master writ
		{"Craft.*With%s(.*):.*",			"%1"}	-- daily writ
	}
	local nameConvert = {
		{"Craft%sa%s(.*)%c.*%c.*", 			"%1"}, 	-- enchanting master writ
		{"Craft%s(.*)%sWith.*",				"%1"}	-- daily writ
	}
	local function getQualityIndex()
		local level = condition
		for k,value in pairs(qualtyConvert) do
			level = string.gsub(level, value[1], value[2])
		end
		return qualityList[level]
	end
	
	local name = condition
	for k,value in pairs(nameConvert) do
		name = string.gsub(name, value[1], value[2])
	end
    name = string.lower(name)
	
	local quality = getQualityIndex()
	local itemLinkName = GetItemLinkName(itemLink):lower()
	if string.match(itemLinkName, name) then
		if quality == GetItemLinkQuality(itemLink) then
			return true
		end
	end
end

local function getRuneCombination(condition, potencyRunesList, skillImprovment)
	local aspectRunes = {[1] = 45850, [2] = 45851, [3] = 45852, [4] = 45853, [5] = 45854}
	
	-- {additive glyph, subtractive glyph, essence rune}
	local essenceRunes = {
		[1]  = {26580,43573,45831}, [2]  = {26582,45868,45832}, [3]  = {26588,45867,45833},
		[4]  = {26581,45869,45834}, [5]  = {26583,45870,45835}, [6]  = {26589,45871,45836},
		[7]  = {0,26586,45837}, 	[8]  = {26848,26849,45838}, [9]  = {5365,5364,45839},
		[10] = {26844,43570,45840}, [11] = {26841,26847,45841}, [12] = {5366,26845,45842},
		[13] = {54484,26591,45843}, [14] = {45874,45875,45846}, [15] = {45883,45885,45847},
		[16] = {45884,45886,45848}, [17] = {45872,45873,45849},
		[18] = {68343,68344,68342}, [19] = {166047,166046,166045}
    }
	local runeData, runeItemLinks, canCraft = {}, {}, true
	local potencyBagId, potencySlotIndex, essenceBagId, essenceSlotIndex, aspectBagId, aspectSlotIndex
	for aspectIndex,aspectItemId in pairs(aspectRunes) do
		for runeType,potencyItemId in pairs(potencyRunesList) do
			for _,essenceItemId in pairs(essenceRunes) do
				if essenceItemId[runeType] ~= 0 then
					local subLevel, level = getLinkLevel(skillImprovment,aspectIndex)
					local enchantingResultItemLink = IJAWH:GetItemLink(essenceItemId[runeType], subLevel, level, "0")

					if DoesItemLinkFulfillWritCondition(enchantingResultItemLink, condition) then
						local potencyLink = IJAWH:GetItemLink(potencyItemId)
						local essenceLink = IJAWH:GetItemLink(essenceItemId[3])
						local aspectLink = IJAWH:GetItemLink(aspectItemId)
						
						local potencyData = IJAWH:getItemDataFromLink(potencyLink)
						local _, _, hasEnough = IJAWH:GetIngredientLabel(potencyData,1)
						if not hasEnough then canCraft = hasEnough end
						local essenceData = IJAWH:getItemDataFromLink(essenceLink)
						local _, _, hasEnough = IJAWH:GetIngredientLabel(essenceData,1)
						if not hasEnough then canCraft = hasEnough end
						local aspectData = IJAWH:getItemDataFromLink(aspectLink)
						local _, _, hasEnough = IJAWH:GetIngredientLabel(aspectData,1)
						if not hasEnough then canCraft = hasEnough end
						
						local potencyBagId, potencySlotIndex = potencyData.bagId, potencyData.slotIndex
						local essenceBagId, essenceSlotIndex = essenceData.bagId, essenceData.slotIndex
						local aspectBagId, aspectSlotIndex = aspectData.bagId, aspectData.slotIndex
						
						runeData[1] = {bagId = potencyBagId, slotIndex = potencySlotIndex, stackCount = potencyData.stackCount, meetsUsageRequirement = getUsageRequirment(potencyLink)}
						runeData[2] = {bagId = essenceBagId, slotIndex = essenceSlotIndex, stackCount = essenceData.stackCount, meetsUsageRequirement = getUsageRequirment(essenceLink)}
						runeData[3] = {bagId = aspectBagId, slotIndex = aspectSlotIndex, stackCount = aspectData.stackCount, meetsUsageRequirement = getUsageRequirment(aspectLink)}
						runeItemLinks[1] = potencyLink
						runeItemLinks[2] = essenceLink
						runeItemLinks[3] = aspectLink
						return runeData, enchantingResultItemLink, runeItemLinks, canCraft
					end
				end
			end
		end
	end
	return nil, nil, nil
end
function IJAWH:GetEnchantingDetails(qIndex, lineId, step, qName, condition, maximum)
	local ingredList, recipeList = '', {}
	-- {additive rune, subtractive rune}
	local potencyRunes = {
		{45855,45817}, {45857,45819}, {45807,45821},
		{45809,45823}, {45811,45825}, {45813,45827},
		{45814,45828}, {45815,45829}, {45816,45830},
		{64509,64508}, {68341,68340}
    }
	
    local CP160 	= {366,50}  -- truly superb
    local CP150 	= {308,50}  -- superb
    local CP100 	= {134,50}	-- monumental
    local CP70 		= {131,50}  -- splendid
    local CP50 		= {129,50}	-- grand
	local CP30 		= {127,50}  -- greater
    local LV41 		= {20,41}	-- strong
    local CP31  	= {20,31}	-- moderate
    local LV21  	= {20,21}   -- minor
    local LV11  	= {20,11}   -- petty
    local LV1   	= {30,1}	-- trifling
	
	local isMaster = string.match(GetString(SI_IJAWH_MASTERFUL_GLYPH),qName) and true or false
	
	local skillRank
	local skillImprovment
	
    if isMaster then
		if string.find(condition, "Truly Superb") then
			skillRank = 11
			skillImprovment = CP160
		else
			skillRank = 10
			skillImprovment = CP150
		end
    else
        skillRank = IJAWH:GetSkillRank(CRAFTING_TYPE_ENCHANTING, 2)
		skillImprovment = skillRank > 0 and select(skillRank , LV1, LV11, LV21, LV31, LV41, CP30, CP50, CP70, CP100, CP150) or {0,0} or {0,0}
    end
	
	local potencyList = potencyRunes[skillRank]
    local potencyRunesList = {}
	if skillRank == 0 then
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, zo_strformat(SI_ENCHANTING_REQUIRES_POTENCY_IMPROVEMENT,""))
		return 0, nil, false
	else
		for i=1, #potencyList do
			potencyRunesList[#potencyRunesList +1] = potencyList[i]
		end
	end

	local canCraft
	
	local runeData, enchantingResultItemLink, runeItemLinks, canCraft = getRuneCombination(condition, potencyRunesList, skillImprovment)
	local inBank, amountRequired = self:IsRequieredInBank(qIndex, qName, lineId, enchantingResultItemLink, maximum)

	if not IJAWH.writData[IJAWH_WD_INDEX].recipeData[step] then IJAWH.writData[IJAWH_WD_INDEX].recipeData[step] = {} end
	if not IJAWH.writData[IJAWH_WD_INDEX].ingredients[step] then IJAWH.writData[IJAWH_WD_INDEX].ingredients[step] = {} end
	IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData] = {
		itemLink = enchantingResultItemLink, 
		runeData = runeData,
		canCraft = canCraft	
	}

	IJAWH.writData[IJAWH_WD_INDEX].ingredients[step] = {
		[1] = runeItemLinks,
		func = function(params)
			local ingredList, runeItemLinks = '', params[1]
			local yPos = 0
			for i=1, #runeItemLinks do
				yPos = yPos + 25
				local itemData = IJAWH:getItemDataFromLink(runeItemLinks[i])
				local label, stackLabel, hasEnough = IJAWH:GetIngredientLabel(itemData,1)
				if ingredList == '' then ingredList = label .. ": " .. stackLabel else ingredList = ingredList .. "\n" .. label .. ": " .. stackLabel end
			end
			return ingredList, yPos + 10
		end
	}
	
	return amountRequired, enchantingResultItemLink, inBank
end

function IJAWH:ParseEnchantingQuest(qName, qIndex, lineId)
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
					amountRequired, itemLink, inBank = self:GetEnchantingDetails(qIndex, lineId, step, qName, condition, maximum)
				end
			end
		end
		if inBank == true then 
			withdrawText[#withdrawText + 1] = zo_strformat(SI_IJAWH_WITHDRAW_FROM_BANK_ITEMS, "E6E93C", amountRequired, itemLink)
		end
	end
	return withdrawText
end

--[[

SI_ENCHANTING_REQUIRES_ASPECT_IMPROVEMENT = 4962 = "Requires Aspect Improvement <<1>>"

SI_ENCHANTING_REQUIRES_POTENCY_IMPROVEMENT = 4961 = "Requires Potency Improvement <<1>>"

zo_strformat(SI_ENCHANTING_REQUIRES_POTENCY_IMPROVEMENT,skillRank)


--]]