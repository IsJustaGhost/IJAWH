local function getAlchemyNumPerIteration(solventItemLink)
    local itemType = GetItemLinkItemType(solventItemLink)
    local skillType, skillIndex = GetCraftingSkillLineIndices(CRAFTING_TYPE_ALCHEMY)
    local abilityIndex = 4
    local abilityName, _, _, _, _, purchased, _, rankIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
    if (not purchased) then
        rankIndex = 0
    end
    if itemType == ITEMTYPE_POISON_BASE then
        rankIndex = (rankIndex * 4) + 3
    end
    return rankIndex + 1
end

function IJAWH:SetRecipeList(patternList, solventItemLink, maximum, conditionText)
	local sloventData = IJAWH:getItemDataFromLink(solventItemLink)
	local sort, recipe, canCraft, recipeData = "", "", true, {}
	local numIterations = math.ceil(maximum / getAlchemyNumPerIteration(solventItemLink))
	
	for i=1, #patternList do
		local recipeTemp = patternList[i]
		local reagent, itemName, totalStack, itemsData = {}, {}, {}, {}
		sort, recipe = "", ""
		for n=1,3 do
			reagent = recipeTemp[n+2]
			if reagent.itemId ~= 0 then
				local itemData = self:GetItemData(reagent.itemName, ITEMTYPE_REAGENT)
				local label, stackLabel, hasEnough = self:GetIngredientLabel(itemData,maximum)
				
				if not hasEnough then
					numIterations = reagent.totalStack
					canCraft = hasEnough 
				end
				
				if recipe == "" then recipe = label else recipe = recipe .. "\n" .. label end
				if self.savedVariables.priorityBy == 3 then
					if sort == "" then 
						sort = zo_strformat("|cffffffTTC |r ") .. reagent.price .. "g"
					else
						sort = sort .. "\n" .. zo_strformat("|cffffffTTC |r ") .. reagent.price .. "g"
					end
				elseif self.savedVariables.priorityBy == 2 then 
					if sort == "" then 
						sort = zo_strformat("|cffffffPriority |r ") .. reagent.priority
					else
						sort = sort .. "\n" .. zo_strformat("|cffffffPriority |r ") .. reagent.priority
					end
				else
					if sort == "" then
						sort = zo_strformat("|cffffffStock |r ") .. stackLabel
					else
						sort = sort .. "\n" .. zo_strformat("|cffffffStock |r ") .. stackLabel
					end
				end	
				local itemDataTemp = {
					bagId = itemData.bagId, slotIndex = itemData.slotIndex, 
					meetsUsageRequirement = itemData.meetsUsageRequirement
					}
				itemName[#itemName + 1] = reagent.itemName
				itemsData[#itemsData + 1] = itemDataTemp
				totalStack[#totalStack + 1] = reagent.totalStack
			end
		end
		
		if not itemsData[3] then 
			reagnet3BagId = 0
			reagnet3SlotIndex = 0
		else
			reagnet3BagId = itemsData[3].bagId
			reagnet3SlotIndex = itemsData[3].slotIndex
		end
		
		local resultLink = GetAlchemyResultingItemLink(sloventData.bagId, sloventData.slotIndex,
			itemsData[1].bagId, itemsData[1].slotIndex, itemsData[2].bagId, itemsData[2].slotIndex,
			reagnet3BagId, reagnet3SlotIndex, LINK_STYLE_DEFAULT
		)
		if resultLink == '' then
			resultLink = string.gsub(conditionText, ":.*", "")
		end
		
		recipeData[#recipeData+1] = {
			itemName = itemName, itemData = itemsData, 
			totalStack = totalStack, name = recipe, sort = sort,
			variations = i .. " of " .. #patternList, index = i,
			numIterations = numIterations,
			itemLink = resultLink,
			canCraft = canCraft
		}
		self:EnableReagentPanel(true)
	end
	IJAWH_CurrentWrit.recipeData = {}
	if IJAWH.writData[IJAWH_WD_INDEX] then
		IJAWH_CurrentWrit.recipeData = recipeData
	end
end

local function PatternSortByManual(a, b)
    -- [traitPriority]
    local traitPriorityA = a[2]
    local traitPriorityB = b[2]
    if traitPriorityA ~= traitPriorityB then
        return traitPriorityA < traitPriorityB
    end

    local reagentA1 = a[3]
    local reagentA2 = a[4]
    local reagentA3 = IJAWH:Choice(a[5].itemId ~= 0, a[5], reagentA2)
    local reagentB1 = b[3]
    local reagentB2 = b[4]
    local reagentB3 = IJAWH:Choice(b[5].itemId ~= 0, b[5], reagentB2)

    -- [minPriority]
    local lowest = 26 -- 26Kind
    local priorityA1 = reagentA1.priority
    local priorityA2 = reagentA2.priority
    local priorityA3 = reagentA3.priority

    local priorityB1 = reagentB1.priority
    local priorityB2 = reagentB2.priority
    local priorityB3 = reagentB3.priority
	
    local minA = math.min(priorityA1, priorityA2, priorityA3)
    local minB = math.min(priorityB1, priorityB2, priorityB3)
    if minA ~= minB then
        return minA < minB
    end


    -- [maxPriority]
    local maxA = math.max(priorityA1, priorityA2, priorityA3)
    local maxB = math.max(priorityB1, priorityB2, priorityB3)
    if maxA ~= maxB then
        return maxA < maxB
    end


    -- [inStack]
    local inStackA1 = math.ceil(math.sin(reagentA1.stack))
    local inStackA2 = math.ceil(math.sin(reagentA2.stack))
    local inStackA3 = math.ceil(math.sin(reagentA3.stack))

    local inStackB1 = math.ceil(math.sin(reagentB1.stack))
    local inStackB2 = math.ceil(math.sin(reagentB2.stack))
    local inStackB3 = math.ceil(math.sin(reagentB3.stack))

    local inStackA = inStackA1 + inStackA2 + inStackA3
    local inStackB = inStackB1 + inStackB2 + inStackB3
    if inStackA ~= inStackB then
        return inStackA > inStackB
    end


    -- [itemId(reagent1)]
    local itemIdA = reagentA1.itemId
    local itemIdB = reagentB1.itemId
    if itemIdA ~= itemIdB then
        return itemIdA < itemIdB
    end


    -- [itemId(reagent2)]
    itemIdA = reagentA2.itemId
    itemIdB = reagentB2.itemId
    if itemIdA ~= itemIdB then
        return itemIdA < itemIdB
    end


    -- [itemId(reagent3)]
    itemIdA = reagentA3.itemId
    itemIdB = reagentB3.itemId
    return itemIdA < itemIdB
end
local function PatternSortByPrice(a, b)    
	local traitPriorityA = a[2]
    local traitPriorityB = b[2]
    if traitPriorityA ~= traitPriorityB then
        return traitPriorityA < traitPriorityB
    end

    local reagentA1 = a[3]
    local reagentA2 = a[4]
    local reagentA3 = IJAWH:Choice(a[5].itemId ~= 0, a[5], reagentA2)
    local reagentB1 = b[3]
    local reagentB2 = b[4]
    local reagentB3 = IJAWH:Choice(b[5].itemId ~= 0, b[5], reagentB2)

    local priceA1 = reagentA1.price
    local priceA2 = reagentA2.price
    local priceA3 = reagentA3.price
    priceA1 = priceA1
    priceA2 = priceA2
    priceA3 = priceA3
    local priceB1 = reagentB1.price
    local priceB2 = reagentB2.price
    local priceB3 = reagentB3.price
    priceB1 = priceB1
    priceB2 = priceB2
    priceB3 = priceB3

    -- [maxPrice]
    local maxA = math.max(priceA1, priceA2, priceA3)
    local maxB = math.max(priceB1, priceB2, priceB3)
    if maxA ~= maxB then
        return maxA < maxB
    end

    -- [minPrice]
    local minA = math.min(priceA1, priceA2, priceA3)
    local minB = math.min(priceB1, priceB2, priceB3)
    if minA ~= minB then
        return minA < minB
    end
end
local function PatternSortByStock(a, b)
    -- [traitPriority]
    local traitPriorityA = a[2]
    local traitPriorityB = b[2]
    if traitPriorityA ~= traitPriorityB then
        return traitPriorityA < traitPriorityB
    end
	
    local reagentA1 = a[3]
    local reagentA2 = a[4]
    local reagentA3 = IJAWH:Choice(a[5].itemId ~= 0, a[5], reagentA2)
    local reagentB1 = b[3]
    local reagentB2 = b[4]
    local reagentB3 = IJAWH:Choice(b[5].itemId ~= 0, b[5], reagentB2)

    -- [minStack]
    local lowest = 0 -- 0Stack
    local stackA1 = reagentA1.totalStack
    local stackA2 = reagentA2.totalStack
    local stackA3 = reagentA3.totalStack
    local stackB1 = reagentB1.totalStack
    local stackB2 = reagentB2.totalStack
    local stackB3 = reagentB3.totalStack
    local minA = math.min(stackA1, stackA2, stackA3)
    local minB = math.min(stackB1, stackB2, stackB3)
    if minA ~= minB then
        return minA > minB
    end

    -- [maxStack]
    local maxA = math.max(stackA1, stackA2, stackA3)
    local maxB = math.max(stackB1, stackB2, stackB3)
    if maxA ~= maxB then
        return maxA > maxB
    end

    -- [itemId(reagent1)]
    local itemIdA = reagentA1.itemId
    local itemIdB = reagentB1.itemId
    if itemIdA ~= itemIdB then
        return itemIdA < itemIdB
    end


    -- [itemId(reagent2)]
    itemIdA = reagentA2.itemId
    itemIdB = reagentB2.itemId
    if itemIdA ~= itemIdB then
        return itemIdA < itemIdB
    end


    -- [itemId(reagent3)]
    itemIdA = reagentA3.itemId
    itemIdB = reagentB3.itemId
    return itemIdA < itemIdB
end
local function ReagentSortByManual(a, b)

    local priorityA = IJAWH:Choice(a.priority == 0, 26, a.priority)
    local priorityB = IJAWH:Choice(b.priority == 0, 26, b.priority)
    if priorityA ~= priorityB then
        return priorityA < priorityB
    end

    return a.itemId < b.itemId
end
local function ReagentSortByPrice(a, b)
    local priceA = a.price
    local priceB = b.price
    if priceA ~= priceB then
        return priceA < priceB
    end
    return a.itemId < b.itemId
end
local function ReagentSortByStock(a, b)
    local stackA = a.totalStack
    local stackB = b.totalStack
    if stackA ~= stackB then
        return stackA > stackB
    end
    return a.itemId < b.itemId
end

function IJAWH:GetPriority(itemId)
    if self.savedVariables.priorityBy ~= self.SI_IJAWH_PRIORITY_BY_MANUAL then
        return nil
    end
	
    if (not itemId) or (itemId == 0) then
        return #self.savedVariables.priorityByManual + 1
    end

    for key, value in ipairs(self.savedVariables.priorityByManual) do
        if value == itemId then
            return key
        end
    end
    return #self.savedVariables.priorityByManual + 1
end

function IJAWH:SortPattern(list)
    local sortFunctions = {
        [self.SI_IJAWH_PRIORITY_BY_STOCK] = PatternSortByStock,
        [self.SI_IJAWH_PRIORITY_BY_MANUAL] = PatternSortByManual,
        [self.SI_IJAWH_PRIORITY_BY_TTC] = PatternSortByPrice
    }
    table.sort(list, sortFunctions[self.savedVariables.priorityBy])
end

function IJAWH:SortReagent(list)
	    local sortFunctions = {
        [self.SI_IJAWH_PRIORITY_BY_STOCK] = ReagentSortByStock,
        [self.SI_IJAWH_PRIORITY_BY_TTC] = ReagentSortByPrice,
        [self.SI_IJAWH_PRIORITY_BY_MANUAL] = ReagentSortByManual
    }
    table.sort(list, sortFunctions[self.savedVariables.priorityBy])
    return unpack(list)
end

function IJAWH:GetAvgPrice(itemLink)

    local saveVer = self.savedVariables
    if saveVer.priorityBy == self.SI_IJAWH_PRIORITY_BY_STOCK then
        return 0
    end
	
    if TamrielTradeCentre then
        if (saveVer.priorityBy == self.SI_IJAWH_PRIORITY_BY_TTC)
        or (saveVer.priorityBy == self.SI_IJAWH_PRIORITY_BY_MANUAL and saveVer.showPriceTTC) then

            local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
            if priceInfo and priceInfo.Avg then
                return priceInfo.Avg
            end
            return 0
        end
    end
end

function IJAWH:IsValidParameter(validKeyCache, includeTraits, reagent1, reagent2, reagent3)
    local traitMinCount
    local list
    local keyList
    if reagent3 then
        if reagent1.itemId == reagent2.itemId then
            return nil
        end
        if reagent1.itemId == reagent3.itemId then
            return nil
        end
        if reagent2.itemId == reagent3.itemId then
            return nil
        end
        list = {reagent1, reagent2, reagent3}
        keyList = {reagent1.itemId, reagent2.itemId, reagent3.itemId}
 --       traitMinCount = 3
        traitMinCount = #includeTraits
    else
        if reagent2.itemId == reagent1.itemId then
            return nil
        end
        list = {reagent1, reagent2}
        keyList = {reagent1.itemId, reagent2.itemId}
 --       traitMinCount = 1
        traitMinCount = #includeTraits
    end
	
    table.sort(keyList)
    local key = tonumber(table.concat(keyList, ""))
    if validKeyCache[key] then
        return nil
    end
    validKeyCache[key] = true

    local summary = {}
    for _, reagent in ipairs(list) do
        for i, trait in ipairs(reagent.traits) do
            if summary[trait] then
                summary[trait].total = summary[trait].total + 1
            else
                summary[trait] = {}
                summary[trait].trait = trait
                summary[trait].total = 1
                summary[trait].traitPriority = reagent.traitPrioritys[i]
            end
        end
    end
    local resultTraits = {}
    local traitCount = 0
    for _, value in pairs(summary) do
        if value.total >= 2 then
            traitCount = traitCount + 1
            resultTraits[#resultTraits + 1] = value
        end
    end
    if traitCount ~= traitMinCount then
        return nil
    end
    table.sort(resultTraits, function(a, b)
        return a.traitPriority < b.traitPriority
    end)

    local traits = {}
    for _, resultTrait in pairs(resultTraits) do
        traits[#traits + 1] = resultTrait.trait
    end
    return traits, resultTraits[1].traitPriority
end

function IJAWH:CreatePatternReagentList(reagentInfoList, includeTraits, traitPiorityList, conditionText)
    local formatText = "|H0:item:<<1>>:31:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
    local reagentList = {}
    for _, reagentInfo in ipairs(reagentInfoList) do
        local itemId = tonumber(reagentInfo[1])
        local itemLink = zo_strformat(formatText, itemId)
        local itemName = GetItemLinkName(itemLink):gsub("(\|).*", ""):gsub("(\^)%a*", "")

        -- [PositiveCheck]
        local traits = {reagentInfo[2][1], reagentInfo[3][1], reagentInfo[4][1], reagentInfo[5][1]}
        local traitPrioritys = {}
        local isTarget = false

        for _, traitName in ipairs(traits) do
            if self:Equal(traitName, includeTraits) then
                isTarget = true
            end
            traitPrioritys[#traitPrioritys + 1] = traitPiorityList[traitName]

        end
		
        -- [NegativeCheck]
        if isTarget then
            local cancelTraits = {reagentInfo[2][2], reagentInfo[3][2], reagentInfo[4][2], reagentInfo[5][2]}
            for _, cancelTraitName in ipairs(cancelTraits) do
                if self:Equal(cancelTraitName, includeTraits) then
                    isTarget = false
                end
            end
        end

        if isTarget then
            local reagent = {}
            reagent.itemId         = itemId
            reagent.itemName       = itemName
            reagent.itemLink       = itemLink
            reagent.traits         = traits
            reagent.traitPrioritys = traitPrioritys
            reagent.totalStack     = (self.stackList[itemId] or 0) + (self.houseStackList[itemId] or 0)
            reagent.stack          = self.stackList[itemId] or 0
            reagent.price          = self:GetAvgPrice(itemLink)
            reagent.priority       = self:GetPriority(itemId)
            reagentList[#reagentList + 1] = reagent
        end
    end
    return reagentList
end

function IJAWH:CreatePatternList(reagentList, includeTraits)
    local pattern
    local patternList = {}
    local validKeyCache = {}
    for _, reagent1 in ipairs(reagentList) do
        for _, reagent2 in ipairs(reagentList) do
			for _, reagent3 in ipairs(reagentList) do
				local traits, traitPriority = self:IsValidParameter(validKeyCache, includeTraits, reagent1, reagent2, reagent3)
				if traits then
					if self:EqualAll(traits, includeTraits) then
						pattern = {
							traits[1],
							traitPriority,
							self:SortReagent({reagent1, reagent2, reagent3}),
							}
						patternList[#patternList + 1] = pattern
					
					end
				end
			end
			local traits, traitPriority = self:IsValidParameter(validKeyCache, includeTraits, reagent1, reagent2)
			if traits then
				local reagent3 = {}
				reagent3.itemId     = 0
				reagent3.itemLink   = nil
				reagent3.stack      = 0
				reagent3.totalStack = 0
				reagent3.price      = 0
				reagent3.priority   = self:GetPriority(reagent3.itemId)
				if #includeTraits > 1 then
					if self:EqualAll(traits, includeTraits) then
						pattern = {
							traits[1],
							traitPriority,
							self:SortReagent({reagent1, reagent2, reagent3})
						}
						patternList[#patternList + 1] = pattern
					end
				else
					if traits[1] == includeTraits[1] then
						pattern = {
							traits[1],
							traitPriority,
							self:SortReagent({reagent1, reagent2, reagent3})
							}
						patternList[#patternList + 1] = pattern
					end
				end
			end
        end
    end
    self:SortPattern(patternList)
	return patternList
end

function IJAWH:GetSolventAndTraits(conditionText, craftItemList, isPoison, otherTraits, qName)
	local isMaster 
	if qName then
		isMaster = string.match(GetString(SI_IJAWH_MASTERFUL_CONCOCTION),qName) and true or false
	end
	
    local CP150 = "308:50"
    local CP100 = "134:50"
    local CP50  = "129:50"
    local CP10  = "125:50"
    local LV40  = "30:40"
    local LV30  = "30:30"
    local LV20  = "30:20"
    local LV10  = "30:10"
    local LV3   = "30:3"
    local itemFormat = "|H0:item:<<1>>:<<2>>:0:0:0:0:0:0:0:0:0:0:0:0:<<3>>:0:0:0:0:0|h|h"

    local rankList
    if isMaster then
        skillRank = 8
        rank = CP150
    else
        skillRank = IJAWH:GetSkillRank(CRAFTING_TYPE_ALCHEMY, 1)
        rank = select(skillRank, {LV3, LV10}, LV20, LV30, LV40, CP10, CP50, CP100, CP150)
    end
	
    local solvent
	
    if isPoison then
        solvent = select(skillRank, {"75357", "75358"}, "75359", "75360", "75361", "75362", "75363", "75364", "75365")
    else
        solvent = select(skillRank, {"883", "1187"}, "4570", "23265", "23266", "23267", "23268", "64500", "64501")
    end
	
	if type(solvent) == "table" then	-- for alchemy level 1
		if IJAWH:Contains(qName,IJAWH_WRIT_TYPES[4]) then
			solvent = solvent[1]
			rank = rank[1]
		else
			local playerLevel = GetUnitLevel("player")
			solvent = playerLevel <10 and solvent[1] or solvent[2]
			rank = playerLevel <10 and rank[1] or rank[2]
		end
	end
	
    local itemLink, convertedItemNames, solventItemLink, includeTraits
	
	for _, craftItem in ipairs(craftItemList) do
		itemLink = zo_strformat(itemFormat, craftItem[1], rank, "36")
		convertedItemNames = self:ConvertedItemNames(GetItemLinkName(itemLink))
		if string.match(conditionText, convertedItemNames) then
			solventItemLink = zo_strformat(itemFormat, solvent, rank, "0")
			includeTraits = {craftItem[2]}
			break
		end
	end
		
    if (not solventItemLink) then
        return nil, nil, nil
    end
	
	if otherTraits and not isMaster then
	    for i, trait in ipairs(otherTraits) do
            includeTraits[#includeTraits + 1] = trait
		end
    end

    if (not isMaster) then
        return itemLink, solventItemLink, includeTraits
    end

    local convertedTraitNames
    includeTraits = {}
    for i, craftItem in ipairs(craftItemList) do
        convertedTraitNames = self:ConvertedItemNames(craftItem[2])
        if string.match(conditionText, convertedTraitNames) then
            includeTraits[#includeTraits + 1] = craftItem[2]
        end
    end
    if #includeTraits < 3 then
        return nil, nil, nil
    end
	
    return itemLink, solventItemLink, includeTraits
end

function IJAWH:Advice(qIndex, step, conditionText, maximum, otherTraits ,qName)
	
    local ARMOR              = GetString(SI_IJAWH_ARMOR)
    local BREACH             = GetString(SI_IJAWH_BREACH)
    local COWARDICE          = GetString(SI_IJAWH_COWARDICE)
    local DEFILE             = GetString(SI_IJAWH_DEFILE)
    local DETECTION          = GetString(SI_IJAWH_DETECTION)
    local ENERVATE           = GetString(SI_IJAWH_ENERVATE)
    local ENTRAPMENT         = GetString(SI_IJAWH_ENTRAPMENT)
    local FRACTURE           = GetString(SI_IJAWH_FRACTURE)
    local GR_RVG_HEALTH      = GetString(SI_IJAWH_GR_RVG_HEALTH)
    local HEALTH             = GetString(SI_IJAWH_HEALTH)
    local HEROISM            = GetString(SI_IJAWH_HEROISM)    -- Add:Elsweyr
    local HINDRANCE          = GetString(SI_IJAWH_HINDRANCE)
    local INVISIBLE          = GetString(SI_IJAWH_INVISIBLE)
    local LGR_HEALTH         = GetString(SI_IJAWH_LGR_HEALTH)
    local MAGICKA            = GetString(SI_IJAWH_MAGICKA)
    local MAIM               = GetString(SI_IJAWH_MAIM)
    local PROTECTION         = GetString(SI_IJAWH_PROTECTION)
    local RVG_HEALTH         = GetString(SI_IJAWH_RVG_HEALTH)
    local RVG_MAGICKA        = GetString(SI_IJAWH_RVG_MAGICKA)
    local RVG_STAMINA        = GetString(SI_IJAWH_RVG_STAMINA)
    local SPEED              = GetString(SI_IJAWH_SPEED)
    local SPELL_CRIT         = GetString(SI_IJAWH_SPELL_CRIT)
    local SPELL_POWER        = GetString(SI_IJAWH_SPELL_POWER)
    local SPELL_RESIST       = GetString(SI_IJAWH_SPELL_RESIST)
    local STAMINA            = GetString(SI_IJAWH_STAMINA)
    local TIMIDITY           = GetString(SI_IJAWH_TIMIDITY)
    local UNCERTAINTY        = GetString(SI_IJAWH_UNCERTAINTY)
    local UNSTOP             = GetString(SI_IJAWH_UNSTOP)
    local VITALITY           = GetString(SI_IJAWH_VITALITY)
    local VULNERABILITY      = GetString(SI_IJAWH_VULNERABILITY)
    local WEAPON_CRIT        = GetString(SI_IJAWH_WEAPON_CRIT)
    local WEAPON_POWER       = GetString(SI_IJAWH_WEAPON_POWER)
	
	local itemTypeList 		 = {ITEMTYPE_POTION_BASE, ITEMTYPE_POISON_BASE, ITEMTYPE_REAGENT}
	
    local isPoison = self:isPoison(conditionText)
	
    local craftItemList
    if isPoison then
        craftItemList = {
            {"76845", ENTRAPMENT, 20},      {"76827", RVG_HEALTH, 2},       {"76829", RVG_MAGICKA, 4},
            {"76831", RVG_STAMINA, 6},      {"76849", HINDRANCE, 24},       {"76844", UNSTOP, 24},
            {"76846", DETECTION, 21},       {"76847", INVISIBLE, 22},       {"76837", COWARDICE, 12},
            {"76839", MAIM, 14},            {"76841", UNCERTAINTY, 16},     {"76848", SPEED, 23},
            {"77599", VULNERABILITY, 26},   {"76836", SPELL_POWER, 11},     {"76838", WEAPON_POWER, 13},
            {"76840", SPELL_CRIT, 15},      {"76842", WEAPON_CRIT, 17},     {"76826", HEALTH, 1},
            {"76828", MAGICKA, 3},          {"76830", STAMINA, 5},          {"76832", SPELL_RESIST, 7},
            {"76834", ARMOR, 9},            {"76833", BREACH, 8},           {"76835", FRACTURE, 10},
            {"76843", ENERVATE, 18},        {"77593", LGR_HEALTH, 27},      {"77601", VITALITY, 29},
            {"77595", GR_RVG_HEALTH, 28},   {"77597", PROTECTION, 25},      {"77603", DEFILE, 30},
            -- Add:Elsweyr
            {"152151", HEROISM, 31},
            -- Add:Greymoor
            {"158309", TIMIDITY},
        }
    else
        craftItemList = {
            {"54333", ENTRAPMENT},      {"44812", RVG_HEALTH},      {"44815", RVG_MAGICKA},
            {"44809", RVG_STAMINA},     {"54335", HINDRANCE},       {"27039", UNSTOP},
            {"30142", DETECTION},       {"44715", INVISIBLE},       {"44813", COWARDICE},
            {"44810", MAIM},            {"54336", UNCERTAINTY},     {"27041", SPEED},
            {"77598", VULNERABILITY},   {"30145", SPELL_POWER},     {"44714", WEAPON_POWER},
            {"30141", SPELL_CRIT},      {"30146", WEAPON_CRIT},     {"54339", HEALTH},
            {"54340", MAGICKA},         {"54341", STAMINA},         {"44814", SPELL_RESIST},
            {"27042", ARMOR},           {"44821", BREACH},          {"27040", FRACTURE},
            {"54337", ENERVATE},        {"77592", LGR_HEALTH},      {"77600", VITALITY},
            {"77594", GR_RVG_HEALTH},   {"77596", PROTECTION},      {"77602", DEFILE},
            -- Add:Elsweyr
            {"151969", HEROISM},
            -- Add:Greymoor
            {"158308", TIMIDITY},
			
        }
    end
	
    local traitPiorityList = {}
    for i, value in ipairs(craftItemList) do
        traitPiorityList[value[2]] = i
    end
    if (not self.stackList) or (#self.stackList == 0) then
        self.stackList = self:GetStackList(itemTypeList)
    end
    if (not self.houseStackList) or (#self.houseStackList == 0) then
        self.houseStackList = self:GetHouseStackList()
    end
    local itemLink, solventItemLink, includeTraits = self:GetSolventAndTraits(conditionText, craftItemList, isPoison, otherTraits, qName)
    if (not itemLink) then
        return {}
    end
    local reagentInfoList = {
        {30148,  {RVG_MAGICKA, MAGICKA},	{COWARDICE, SPELL_POWER},		{HEALTH, RVG_HEALTH},			{INVISIBLE, DETECTION}},
        {30149,  {FRACTURE, ARMOR},			{RVG_HEALTH, HEALTH},			{WEAPON_POWER, MAIM},			{RVG_STAMINA, STAMINA}},
        {30151,  {RVG_HEALTH, HEALTH},		{RVG_MAGICKA, MAGICKA},			{RVG_STAMINA, STAMINA},			{ENTRAPMENT, UNSTOP}},
        {30152,  {BREACH, SPELL_RESIST},	{RVG_HEALTH, HEALTH},			{SPELL_POWER, COWARDICE},		{RVG_MAGICKA, MAGICKA}},
        {30153,  {SPELL_CRIT, UNCERTAINTY},	{SPEED, HINDRANCE},				{INVISIBLE, DETECTION},			{UNSTOP, ENTRAPMENT}},
        {30154,  {COWARDICE, SPELL_POWER},	{RVG_MAGICKA, MAGICKA},			{SPELL_RESIST, BREACH},			{DETECTION, INVISIBLE}},
        {30155,  {RVG_STAMINA, STAMINA},	{MAIM, WEAPON_POWER},			{HEALTH, RVG_HEALTH},			{HINDRANCE, SPEED}},
        {30156,  {MAIM, WEAPON_POWER},		{RVG_STAMINA, STAMINA},			{ARMOR, FRACTURE},				{ENERVATE, WEAPON_CRIT}},
        {30157,  {STAMINA, RVG_STAMINA},	{WEAPON_POWER, MAIM},			{RVG_HEALTH, HEALTH},			{SPEED, HINDRANCE}},
        {30158,  {SPELL_POWER, COWARDICE},	{MAGICKA, RVG_MAGICKA},			{BREACH, SPELL_RESIST},			{SPELL_CRIT, UNCERTAINTY}},
        {30159,  {WEAPON_CRIT, ENERVATE},	{HINDRANCE, SPEED},				{DETECTION, INVISIBLE},			{UNSTOP, ENTRAPMENT}},
        {30160,  {SPELL_RESIST, BREACH},	{HEALTH, RVG_HEALTH},			{COWARDICE, SPELL_POWER},		{MAGICKA, RVG_MAGICKA}},
        {30161,  {MAGICKA, RVG_MAGICKA},	{SPELL_POWER, COWARDICE},		{RVG_HEALTH, HEALTH},			{DETECTION, INVISIBLE}},
        {30162,  {WEAPON_POWER, MAIM},		{STAMINA, RVG_STAMINA},			{FRACTURE, ARMOR},				{WEAPON_CRIT, ENERVATE}},
        {30163,  {ARMOR, FRACTURE},			{HEALTH, RVG_HEALTH},			{MAIM, WEAPON_POWER},			{STAMINA, RVG_STAMINA}},
        {30164,  {HEALTH, RVG_HEALTH},		{MAGICKA, RVG_MAGICKA},			{STAMINA, RVG_STAMINA},			{UNSTOP, ENTRAPMENT}},
        {30165,  {RVG_HEALTH, HEALTH},		{UNCERTAINTY, SPELL_CRIT},		{ENERVATE, WEAPON_CRIT},		{INVISIBLE, DETECTION}},
        {30166,  {HEALTH, RVG_HEALTH},		{SPELL_CRIT, UNCERTAINTY},		{WEAPON_CRIT, ENERVATE},		{ENTRAPMENT, UNSTOP}},
        {77581,  {FRACTURE, ARMOR},			{ENERVATE, WEAPON_CRIT},		{DETECTION, INVISIBLE},			{VITALITY, DEFILE}},
        {77583,  {BREACH, SPELL_RESIST},	{ARMOR, FRACTURE},				{PROTECTION, VULNERABILITY},	{VITALITY, DEFILE}},
        {77584,  {HINDRANCE, SPEED},		{INVISIBLE, DETECTION},			{LGR_HEALTH, GR_RVG_HEALTH},	{DEFILE, VITALITY}},
        {77585,  {HEALTH, RVG_HEALTH},		{UNCERTAINTY, SPELL_CRIT},		{LGR_HEALTH, GR_RVG_HEALTH},	{VITALITY, DEFILE}},
        {77587,  {RVG_STAMINA, STAMINA},	{VULNERABILITY, PROTECTION},	{GR_RVG_HEALTH, LGR_HEALTH},	{VITALITY, DEFILE}},
        {77589,  {RVG_MAGICKA, MAGICKA},	{SPEED, HINDRANCE},				{VULNERABILITY, PROTECTION},	{LGR_HEALTH, GR_RVG_HEALTH}},
        {77590,  {RVG_HEALTH, HEALTH},		{PROTECTION, VULNERABILITY},	{GR_RVG_HEALTH, LGR_HEALTH},	{DEFILE, VITALITY}},
        {77591,  {SPELL_RESIST, BREACH},	{ARMOR, FRACTURE},				{PROTECTION, VULNERABILITY},	{DEFILE, VITALITY}},
        -- Add:Somerset
        {139020, {SPELL_RESIST, BREACH},	{HINDRANCE, SPEED},				{VULNERABILITY, PROTECTION},	{DEFILE, VITALITY}},
        {139019, {LGR_HEALTH, GR_RVG_HEALTH},{SPEED, HINDRANCE},			{VITALITY, DEFILE},				{PROTECTION, VULNERABILITY}},
        -- Add:Elsweyr
        {150731, {LGR_HEALTH, GR_RVG_HEALTH},{STAMINA, RVG_STAMINA},		{HEROISM, COWARDICE},			{DEFILE, VITALITY}}, -- Dragon's Blood
        {150789, {HEROISM, COWARDICE},		{VULNERABILITY, PROTECTION},	{INVISIBLE, DETECTION},			{VITALITY, DEFILE}}, -- Dragon's Bile
        -- Add:Dragonhold
        {150671, {MAGICKA, RVG_MAGICKA},	{ENERVATE, WEAPON_CRIT},		{HEROISM, COWARDICE},			{SPEED, HINDRANCE}}, -- Dragon Rheum
        -- Add:Greymoor
		{150669, {TIMIDITY, HEROISM},		{STAMINA, RVG_STAMINA},			{RVG_MAGICKA, MAGICKA},			{DETECTION, INVISIBLE}}, -- Chaurus Egg
		{150670, {TIMIDITY, HEROISM},		{MAGICKA, RVG_MAGICKA},			{RVG_HEALTH, HEALTH},			{PROTECTION, VULNERABILITY}}, -- Vile Coagulant
		{150672, {TIMIDITY, HEROISM},		{GR_RVG_HEALTH, LGR_HEALTH},	{SPELL_CRIT, UNCERTAINTY},		{HEALTH, RVG_HEALTH}}, -- Crimson Nirnroot
    }
	
    local reagentList = self:CreatePatternReagentList(reagentInfoList, includeTraits, traitPiorityList, conditionText)

    local patternList = self:CreatePatternList(reagentList, includeTraits)

    local itemType = IJAWH:Choice(isPoison, ITEMTYPE_POISON, ITEMTYPE_POTION)
    local solventItemId = GetItemLinkItemId(solventItemLink)
    local solventName = GetItemLinkName(solventItemLink):gsub("(\|)[%a%s%p]*", ""):gsub("(\^)%a*", "")
   
    local adviceList = {}
    for _, pattern in ipairs(patternList) do
        local advice = {}
        advice.resultLink 		= itemLink
        advice.itemId     		= GetItemLinkItemId(itemLink)
        advice.itemType  		= GetItemLinkItemType(itemLink)
        advice.solvent 			= {}
        advice.solvent.itemId 	= solventItemId
        advice.solvent.itemLink = solventItemLink
        advice.solvent.itemName = solventName
        advice.solvent.stack    = solventStack
        advice.reagent 			= {}
		
        advice.reagent[1]		= pattern[3]
        advice.reagent[2] 		= pattern[4]
        advice.reagent[3] 		= pattern[5]
		
        adviceList[#adviceList + 1] = advice	
    end
	
	self:SetRecipeList(patternList, solventItemLink, maximum, conditionText)
	
    return adviceList
end

function IJAWH:GetAlchemyDetails(qIndex, lineId, step, qName, condition, maximum, otherTraits)
	local convertedTxt = self:ConvertedJournalCondition(condition)
    local parameterList = self:Advice(qIndex, step, convertedTxt, maximum, otherTraits, qName)
	local itemTypeList 		 = {ITEMTYPE_POTION_BASE, ITEMTYPE_POISON_BASE, ITEMTYPE_REAGENT}
	local solventLabel, stackCount, hasEnough = '', 0, true
    local result, inBank, amountRequired, itemLink, solventLink = '', false, 0, {}, nil
	local solventData = ""
    for _, parameter in ipairs(parameterList) do
		if parameter.resultLink then
			table.sort(parameter.reagent, function(a,b) return a.itemId >  b.itemId end)
		
            local solvent = {parameter.solvent}
            solvent.bagId, solvent.slotIndex = self:GetFirstStack(solvent[1].itemId, itemTypeList)
			parameter.solvent.slotIndex = slotIndex
			parameter.solvent.bagId = bagId
			if parameter.solvent.itemLink then solventLink = parameter.solvent.itemLink end
			
			local itemData = self:GetItemData(solvent[1].itemName,itemTypeList)
			solventLabel, stackCount, hasEnough =  self:GetIngredientLabel(itemData,1)
			solventLabel = solventLabel .. ": " .. stackCount
			
			IJAWH.selectedSolvent = {bagId = solvent.bagId, slotIndex = solvent.slotIndex}
			if itemData then solventData = itemData end
			
            local reagent1 = parameter.reagent[1]
            local reagent2 = parameter.reagent[2]
            local reagent3 = parameter.reagent[3]
						
            local reagent1bagId, reagent1slotIndex = self:GetFirstStack(reagent1.itemId, itemTypeList)
            local reagent2bagId, reagent2slotIndex = self:GetFirstStack(reagent2.itemId, itemTypeList)
            local reagent3bagId, reagent3slotIndex = self:GetFirstStack(reagent3.itemId, itemTypeList)

            local resultTest = GetAlchemyResultingItemLink(solvent.bagId, solvent.slotIndex,
                                                           reagent1bagId, reagent1slotIndex,
                                                           reagent2bagId, reagent2slotIndex,
                                                           reagent3bagId, reagent3slotIndex,
														   LINK_STYLE_DEFAULT
									   					)
            if resultTest and resultTest ~= "" then
				parameter.resultLink = resultTest
				
				if maximum then	
					local itemLink 
					local bagId, slotIndex = IJAWH:GetBagAndSlotForCreated(resultTest)
					if bagId then
						itemLink = GetItemLink(bagId, slotIndex)
						if not IsJustaEasyAlchemy.isEasyAlchemy then
							inBank, amountRequired = self:IsRequieredInBank(qIndex, qName, lineId, itemLink, maximum)
						end
					end
					if inBank then
						parameter.resultLink = itemLink
						result = parameter
						break
					end
					parameter.resultLink = itemLink
					result = parameter
				end
            end
        end
    end
	
	if result then
		IJAWH_CurrentSolvent = solventData
		IJAWH.writData[IJAWH_WD_INDEX].solvent = solventData
		IJAWH:UpdateSolvent()
		
		if not IJAWH.writData[IJAWH_WD_INDEX].ingredients[step] then IJAWH.writData[IJAWH_WD_INDEX].ingredients[step] = {} end
		IJAWH.writData[IJAWH_WD_INDEX].ingredients[step] = {
			[1] = solventLink,
			func = function(params)
				local itemLink = params[1]
				local yPos = 25
				local itemData = IJAWH:getItemDataFromLink(itemLink)
				local label, stackLabel, hasEnough = IJAWH:GetIngredientLabel(itemData,1)
				local ingredList = label .. ": " .. stackLabel
				return ingredList, yPos
			end
		}
		return maximum, result.resultLink, inBank, parameter, solventLink
	end
end

function IJAWH:ParseAlchemyQuest(qName, qIndex, lineId)
	local withdrawText, step = {}, 0
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
					amountRequired, itemLink, inBank = IJAWH:GetAlchemyDetails(qIndex, lineId, step, qName, condition, maximum, nil)
				end
			end
		end
		if inBank == true then 
			withdrawText[#withdrawText + 1] = zo_strformat(SI_IJAWH_WITHDRAW_FROM_BANK_ITEMS, "E6E93C", amountRequired, itemLink)
		end
	end
	return withdrawText
end