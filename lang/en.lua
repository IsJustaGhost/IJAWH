------------------------------------------------
-- English localization for IsJustaWritHelper
------------------------------------------------
ZO_CreateStringId("SI_IJAWH_WRIT",							"Writ")
ZO_CreateStringId("SI_IJAWH_MASTERFUL",						"Masterful")

ZO_CreateStringId("SI_IJAWH_MASTERFUL_GLYPH",				"A Masterful Glyph")
ZO_CreateStringId("SI_IJAWH_MASTERFUL_CONCOCTION",			"A Masterful Concoction")

ZO_CreateStringId("IJAWH_ACQUIRE_STRING",					"Acquire")

ZO_CreateStringId("SI_IJAWH_CRAFT_WRIT",					"Craft for Writ") 	-- "Craft Button" text
ZO_CreateStringId("SI_IJAWH_EASYALCHEMY",					"Easy Alchemy") 	-- qName header text

ZO_CreateStringId("SI_IJAWH_WRIT_ITEM_IN_BANK",				"You have <<1>> x<<2>> in the bank.")
ZO_CreateStringId("SI_IJAWH_ADDED_TO_WTHDRAW_LIST",			"<<1>> x<<2>> added to be withdrawn from bank.")
ZO_CreateStringId("SI_IJAWH_IN_WTHDRAW_LIST",				"Go to the bank to auto withdraw items for writs.")
ZO_CreateStringId("SI_IJAWH_WITHDRAW_FROM_BANK",			"|c<<1>>Withdraw from bank|r")
ZO_CreateStringId("SI_IJAWH_WITHDRAW_FROM_BANK_ITEMS",		"|c<<1>>(|r <<2>> |c<<1>>)|r  <<3>>")

--ZO_CreateStringId("SI_IJAWH_TOTAL_WRITS",					"|c<<1>>Completed Writs\: <<2>>/<<3>>|r")
ZO_CreateStringId("SI_IJAWH_TOTAL_WRITS",					"Completed Writs\: <<1>>/<<2>>")
ZO_CreateStringId("SI_IJAWH_WRIT_NAME",						"|c<<1>><<2>>|r")
ZO_CreateStringId("SI_IJAWH_DELIVER",						"Deliver")


--[[
IJAWH_WRIT_TYPES = {
    [1] = {"Blacksmith Writ", "A Masterful Plate", "A Masterful Weapon"},
    [2] = {"Clothier Writ", "Masterful Leatherwear", "Masterful Tailoring"},
    [3] = {"Enchanter Writ", "A Masterful Glyph"},
    [4] = {"Alchemist Writ", "A Masterful Concoction"},
    [5] = {"Provisioner Writ", "A Masterful Feast", "Witches Festival Writ"},
    [6] = {"Woodworker Writ", "A Masterful Shield", "A Masterful Weapon"},
    [7] = {"Jewelry Crafting Writ", "Masterful Jewelry"}
}
--]]

IJAWH_WRIT_STRINGS = {
	[1] = ".* Writ",
	[2] = "A Masterful .*"
}

IJAWH_WRIT_TYPES = {
    [1] = {""},
    [2] = {""},
    [3] = {"Enchanter Writ", "A Masterful Glyph"},
    [4] = {"Alchemist Writ", "A Masterful Concoction"},
    [5] = {"Provisioner Writ", "A Masterful Feast", "Witches Festival Writ"},
    [6] = {""},
    [7] = {""}
}
IJAWH_CONSUMABEL_WRIT = {
    ["Enchanter Writ"] = 3,
    ["A Masterful Glyph"] = 3,
    ["Alchemist Writ"] = 4,
    ["A Masterful Concoction"] = 4,
    ["Provisioner Writ"] = 5,
    ["A Masterful Feast"] = 5,
    ["Witches Festival Writ"] = 5,
}

IJAWH_WRIT_TYPES_BY_INDEX = {
    [1] = {"Blacksmith Writ", "A Masterful Plate", "A Masterful Weapon"},
    [2] = {"Clothier Writ", "Masterful Leatherwear", "Masterful Tailoring"},
    [3] = {"Enchanter Writ", "A Masterful Glyph"},
    [4] = {"Alchemist Writ", "A Masterful Concoction"},
    [5] = {"Provisioner Writ", "A Masterful Feast", "Witches Festival Writ"},
    [6] = {"Woodworker Writ", "A Masterful Shield", "A Masterful Weapon"},
    [7] = {"Jewelry Crafting Writ", "Masterful Jewelry"}
}
IJAWH_CRAFTING_TYPE_SMITHING = {CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING, CRAFTING_TYPE_JEWELRYCRAFTING}

IJAWH_SmithingMaterialList = {
"Rubedite", "Voidstone", "Quicksilver", "Galadite", "Calcinium", "Ebony", "Dwarven", "Orichalcum", "Steal", "Iron",
"Ancestor silk", "Shadowspawn", "Silverweave", "Ironthread", "Kresh", "Ebonthread", "Spidersilk", "Cotton", "Flax", "Jute",
"Rubedo", "Shadowhide", "Superb", "Ironhide", "Brigandine", "Fell", "Full-leather", "Leather", "Hide", "Rawhide",
"Ruby Ash", "Nightwood", "Mahogany", "Ash", "Birch", "Yew", "Hickory", "Beech", "Oak", "Maple",
"Platinum", "Electrum", "Silver", "Copper", "Pewter"
}
------------------------------------------------
-- Settings
------------------------------------------------

ZO_CreateStringId("SI_IJAWH_HEADER_WRIT",					"Writ Panel Options")

ZO_CreateStringId("SI_IJAWH_SETTING_HIDEMOUNTED",			"Hide while mounted")
ZO_CreateStringId("SI_IJAWH_SETTING_HIDEMOUNTED_TOOLTIP", 	"Enabled: hides the writ panel while mounted")

ZO_CreateStringId("SI_IJAWH_HEADER_CRAFT",					"Craft Panel Options")
ZO_CreateStringId("SI_IJAWH_SETTING_SHOWCRAFTFORWRIT",		"Show \"Craft for Writ\" button")
ZO_CreateStringId("SI_IJAWH_SETTING_SHOWCRAFTFORWRIT_TOOLTIP", "Enabled: the \"Craft for Writ\" button replaces the \"Craft\" button if all crafting parameters have been met. Auto-crafts all needed items from current station.")
ZO_CreateStringId("SI_IJAWH_SETTING_USEMOSTSTYLE",			"Use Most Style")
ZO_CreateStringId("SI_IJAWH_SETTING_USEMOSTSTYLE_TOOLTIP",	"Enabled: locks smithing writs to use the style material you have the most of.")
ZO_CreateStringId("SI_IJAWH_SETTING_HANDLEWITHDRAW",			"Auto-Withdraw From Bank")
ZO_CreateStringId("SI_IJAWH_SETTING_HANDLEWITHDRAW_TOOLTIP",	"Enabled: when a writ requires an item to be crafted that is already in the bank, the item will be added to a list and be auto withdrawn from the bank the next time the bank is accessed")

ZO_CreateStringId("SI_IJAWH_HEADER_OTHER",					"Other Options")
ZO_CreateStringId("SI_IJAWH_SETTING_SAVEPERCHARACTER",		"Save settings as Character")
ZO_CreateStringId("SI_IJAWH_SETTING_SAVEPERCHARACTER_TOOLTIP",		"Disabled: settings are saved for the account.\nEnabled: settings will be saved separately for each character.")
ZO_CreateStringId("SI_IJAWH_SETTING_EASYALCHEMY",			"Enable Easy Alchemy")
ZO_CreateStringId("SI_IJAWH_SETTING_EASYALCHEMY_TOOLTIP",	"Easy Alchemy allows the creation of potions/poisons by effects. Disable if using another addon for alchemy creations")

ZO_CreateStringId("SI_IJAWH_HEADER_ALERTS",						"Chat Notifications")
ZO_CreateStringId("SI_IJAWH_SETTING_SHOWWRITITEMALERT",			"Show Result Item In Bank Alert")
ZO_CreateStringId("SI_IJAWH_SETTING_SHOWWRITITEMALERT_TOOLTIP",	"Enabled: shows alerts if an item needed to be crafted for the writ is in the player bank.")
ZO_CreateStringId("SI_IJAWH_SETTING_SHOWWITHDRAWINCHAT",			"Show \"to be withdrawn\" in chat")
ZO_CreateStringId("SI_IJAWH_SETTING_SHOWWITHDRAWINCHAT_TOOLTIP",	"Enabled: shows in chat when an item has been added to be auto-withdrawn from the player bank or if it is already on the list.")

ZO_CreateStringId("SI_IJAWH_SETTING_RESETTUTORIALS",			"Reset Tutorials")
ZO_CreateStringId("SI_IJAWH_SETTING_RESETTUTORIALS_TOOLTIP",	"Will make all tutorials show again.")

------------------------------------------------
-- 
------------------------------------------------
ZO_CreateStringId("SI_IJAWH_TTC_INSTALL",			"To sort Reagents by price, install the Tamriel Trade Centre addon and run the TamrielTradeCentre client to update the price list.")
ZO_CreateStringId("SI_IJAWH_TTC_UPDATE",			"To sort Reagents by price, run the Tamriel Trade Centre client to update the price list.")

ZO_CreateStringId("SI_IJAWH_PRIORITY_HEADER",		"Reagent priority")
ZO_CreateStringId("SI_IJAWH_PRIORITY_BY",			"Priority of reagent to be used")
ZO_CreateStringId("SI_IJAWH_PRIORITY_BY_STOCK",		"Highest quantity")
ZO_CreateStringId("SI_IJAWH_PRIORITY_BY_TTC",		"Lowest average price from [TamrielTradeCentre]")
ZO_CreateStringId("SI_IJAWH_PRIORITY_BY_MANUAL",	"Set manually")
ZO_CreateStringId("SI_IJAWH_SHOW_PRICE_MANUAL",		"Show price[<<1>>]")
ZO_CreateStringId("SI_IJAWH_PRIORITY_CHANGED",		"The add-on setting [<<1>>] has been changed because the <<2>> is turned off")

ZO_CreateStringId("SI_IJAWH_HEALTH",		  	 	"Restore Health")		 -- Restore Health	   [en.lang.csv] "156152165","0","1","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_RVG_HEALTH",			"Ravage Health")		  -- Ravage Health	    [en.lang.csv] "156152165","0","2","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_MAGICKA",				"Restore Magicka")		-- Restore Magicka	  [en.lang.csv] "156152165","0","3","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_RVG_MAGICKA",			"Ravage Magicka")		 -- Ravage Magicka	   [en.lang.csv] "156152165","0","4","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_STAMINA",				"Restore Stamina")		-- Restore Stamina	  [en.lang.csv] "156152165","0","5","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_RVG_STAMINA",			"Ravage Stamina")		 -- Ravage Stamina	   [en.lang.csv] "156152165","0","6","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_SPELL_RESIST",			"Increase Spell Resist")    -- Increase Spell Resist [en.lang.csv] "156152165","0","7","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_BREACH",				"Breach")			    -- Breach			 [en.lang.csv] "156152165","0","8","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_ARMOR",					"Increase Armor")		 -- Increase Armor	   [en.lang.csv] "156152165","0","9","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_FRACTURE",				"Fracture")			  -- Fracture		    [en.lang.csv] "156152165","0","10","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_SPELL_POWER",			"Increase Spell Power")	-- Increase Spell Power  [en.lang.csv] "156152165","0","11","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_COWARDICE",				"Cowardice")			 -- Cowardice		   [en.lang.csv] "156152165","0","12","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_WEAPON_POWER",			"Increase Weapon Power")    -- Increase Weapon Power [en.lang.csv] "156152165","0","13","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_MAIM",					"Maim")				 -- Maim			   [en.lang.csv] "156152165","0","14","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_SPELL_CRIT",			"Spell Critical")		 -- Spell Critical	   [en.lang.csv] "156152165","0","15","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_UNCERTAINTY",			"Uncertainty")		    -- Uncertainty		 [en.lang.csv] "156152165","0","16","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_WEAPON_CRIT",			"Weapon Critical")		-- Weapon Critical	  [en.lang.csv] "156152165","0","17","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_ENERVATE",				"Enervation")			-- Enervation		  [en.lang.csv] "156152165","0","18","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_UNSTOP",				"Unstoppable")		    -- Unstoppable		 [en.lang.csv] "156152165","0","19","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_ENTRAPMENT",			"Entrapment")			-- Entrapment		  [en.lang.csv] "156152165","0","20","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_DETECTION",				"Detection")			 -- Detection		   [en.lang.csv] "156152165","0","21","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_INVISIBLE",				"Invisible")			 -- Invisible		   [en.lang.csv] "156152165","0","22","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_SPEED",					"Speed")				-- Speed			  [en.lang.csv] "156152165","0","23","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_HINDRANCE",				"Hindrance")			 -- Hindrance		   [en.lang.csv] "156152165","0","24","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_PROTECTION",			"Protection")			-- Protection		  [en.lang.csv] "156152165","0","25","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_VULNERABILITY",			"Vulnerability")		  -- Vulnerability	    [en.lang.csv] "156152165","0","26","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_LGR_HEALTH",			"Lingering Health")	    -- Lingering Health	 [en.lang.csv] "156152165","0","27","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_GR_RVG_HEALTH",			"Gradual Ravage Health")    -- Gradual Ravage Health [en.lang.csv] "156152165","0","28","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_VITALITY",				"Vitality")			  -- Vitality		    [en.lang.csv] "156152165","0","29","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_DEFILE",				"Defile")			    -- Defile			 [en.lang.csv] "156152165","0","30","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_HEROISM",				"Heroism")			   -- Heroism			[en.lang.csv] "156152165","0","31","xxxxxxxx"
ZO_CreateStringId("SI_IJAWH_TIMIDITY",				"Timidity")			  -- Timidity			[en.lang.csv] "156152165","0","31","xxxxxxxx"

------------------------------------------------
-- Dialogues
------------------------------------------------
ZO_CreateStringId("SI_IJAWH_TUTORIAL_CRAFT_WRIT_TITLE", zo_strformat("|c00FF00<<1>>|r",GetString(SI_IJAWH_CRAFT_WRIT)) .. "  button")
ZO_CreateStringId("SI_IJAWH_TUTORIAL_CRAFT_WRIT_TEXT","The " .. zo_strformat("|c00FF00<<1>>|r",GetString(SI_IJAWH_CRAFT_WRIT)) .. " button is enabled when all crafting parameters are met.\nIn order to craft other times, you must first meet the writ conditions by crafting or acquiring the needed items.\n\nYou can disable this feature by unchecking " .. zo_strformat("|c00FF00<<1>>|r",GetString(SI_IJAWH_SETTING_SHOWCRAFTFORWRIT)) .. " in the settings.")

ZO_CreateStringId("SI_IJAWH_TUTORIAL_EASYALCHEMY_TITLE", zo_strformat("|c00FF00<<1>>|r",GetString(SI_IJAWH_EASYALCHEMY)))
ZO_CreateStringId("SI_IJAWH_TUTORIAL_EASYALCHEMY_TEXT", zo_strformat("|c00FF00<<1>>|r",GetString(SI_IJAWH_EASYALCHEMY)) .. " allows you to create potions/poisons by the effects you want, even if you do not \"know\" the traits.\nUse the 4 arrow sets above the crafting slots to select the type of potion/poison you want to create by effects.\nFor speed, you can scroll with the mouse wheel, or touchpad, while over each selection.\n\nYou can disable " .. zo_strformat("|c00FF00<<1>>|r",GetString(SI_IJAWH_EASYALCHEMY)) .. " by unchecking " .. zo_strformat("|c00FF00<<1>>|r",GetString(SI_IJAWH_SETTING_EASYALCHEMY)) .. " in the settings.")

ZO_CreateStringId("SI_IJAWH_TUTORIAL_ALCHEMY_TITLE","Alchemy Recipes")
ZO_CreateStringId("SI_IJAWH_TUTORIAL_ALCHEMY_TEXT","Many alchemy results have more than one recipe that can create it.\nThose recipes can be selected by using the arrows on the sides of the info box.\nThe selected reagents will change to the ones for the currently selected recipe.\n\nAlchemy recipes are sorted by the reagents used to make it.\n1: By stock on hand. (if " .. zo_strformat("|c00FF00<<1>>|r",GetString(SI_IJAWH_PRIORITY_BY_STOCK)) .. " is checked in the settings.)\n2: By manually selected order. (set in a list in the settings if " .. zo_strformat("|c00FF00<<1>>|r",GetString(SI_IJAWH_PRIORITY_BY_MANUAL)) .. " is checked in the settings.)\n3: By Tamriel Trade Centre lowest average price. (if " .. zo_strformat("|c00FF00<<1>>|r",GetString(SI_IJAWH_PRIORITY_BY_TTC)) .. " is checked in the settings)\nThe sort mode is selected in the settings.\n\n" .. zo_strformat("|c00FF00<<1>>|r",GetString(SI_IJAWH_TTC_INSTALL)))

ZO_CreateStringId("SI_IJAWH_TUTORIAL_STYLEMATERIALS_TITLE","Style Material")
ZO_CreateStringId("SI_IJAWH_TUTORIAL_STYLEMATERIALS_TEXT","The default style material used in smithing auto-crafting with \"Craft For Writ\", is the style material you have the most of.\nDisabled: \"Craft For Writ\" will use the style material you select.\n\nYou can disable this feature by unchecking " .. zo_strformat("|c00FF00<<1>>|r",GetString(SI_IJAWH_SETTING_USEMOSTSTYLE)) .. " in the settings.")

ZO_CreateStringId("SI_IJAWH_TUTORIAL_WITHDRAW_TITLE","Have an item that needs to be crafted already in the bank?")
ZO_CreateStringId("SI_IJAWH_TUTORIAL_WITHDRAW_TEXT","If you already have an item in the bank that the writ requires, you will receive an alert and that item will be added to a list to be auto-withdrawn the next time you access the bank.\nThe \"withdraw list\" will add items from all crafting stations you access so you can withdraw them all in one stop.\n\nYou can disable this feature by unchecking " .. zo_strformat("|c00FF00<<1>>|r",GetString(SI_IJAWH_SETTING_HANDLEWITHDRAW)) .. " in the settings.")


------------------------------------------------
-- 
------------------------------------------------
function IJAWH:ConvertedItemNames(itemName)
    local list = {
	   {"(\-)",	"(\-)"},
	   {" IX$",	" Ⅸ"},
	   {" VIII$",   " Ⅷ"},
	   {" VII$",    " Ⅶ"},
	   {" VI$",	" Ⅵ"},
	   {" IV$",	" Ⅳ"},
	   {" V$",	 " Ⅴ"},
	   {" III$",    " Ⅲ"},
	   {" II$",	" Ⅱ"},
	   {" I$",	 " Ⅰ"},
	   {"panacea ", "Panacea "},   -- Some users have string.lower() disabled?
	   {" health",  " Health"},    -- Some users have string.lower() disabled?
	   {" stamina", " Stamina"},   -- Some users have string.lower() disabled?
	   {"%p",	    ""},
	   {"^[%a]",  string.upper},
    }

    local convertedItemName = itemName
    for _, value in ipairs(list) do
	   convertedItemName = string.gsub(convertedItemName, value[1], value[2])
    end
    return convertedItemName
end

function IJAWH:ConvertedJournalCondition(journalCondition)
    local list = {
		{" IX([:%s])",   " Ⅸ%1"},
		{" VIII([:%s])", " Ⅷ%1"},
		{" VII([:%s])",  " Ⅶ%1"},
		{" VI([:%s])",   " Ⅵ%1"},
		{" IV([:%s])",   " Ⅳ%1"},
		{" V([:%s])",    " Ⅴ%1"},
		{" III([:%s])",  " Ⅲ%1"},
		{" II([:%s])",   " Ⅱ%1"},
		{" I([:%s])",    " Ⅰ%1"},
		{"panacea ",	"Panacea "},	-- Some users have string.lower() disabled?
		{" health",	 " Health"},	-- Some users have string.lower() disabled?
		{" stamina",	" Stamina"},	-- Some users have string.lower() disabled?

		{"(Craft.*)with.*Traits:%c•(.*)%c•(.*)%c•(.*)%c•.*",  	"%1...%2, %3, %4"},
		{".*(Craft.*)with.*properties:(.*)",			   				"%1...%2"},
		{"Craft a (.*)%c•.*:%s(.*)%c• Progress:(.*)",			 "Craft %2 %1:%3"},
		{"Craft (.*)%c• Progress.*",									     "%1"},
		{"Craft (.*)",			  											 "%1"},
		{"^a ",			  													   ""},
		{"^an ",			   												   ""},
--		{":.*",			   													   ""},
		{"-",			   													  " "}
	}

    local convertedCondition = journalCondition
    for _, value in ipairs(list) do
	   convertedCondition = string.gsub(convertedCondition, value[1], value[2])
    end
    return convertedCondition
end


function IJAWH:ConvertedCondition(journalCondition)
    local list = {
--		{"(Craft).*Progress%:(.*)",  						"%1 <<1>>: %|c<<2>>%2%|r"},	-- enchanting master
		{"(Craft).*Progress%:(.*)",  						"%|c<<1>>%1 <<2>>: %2%|r"},	-- enchanting master
--		{"(Craft).*%:(.*)",  								"%1 <<1>>: %|c<<2>>%2%|r"}	-- enchanting master
		{"(Craft).*%:(.*)",  								"%|c<<1>>%1 <<2>>: %2%|r"}	-- enchanting master
	}
	
    local convertedCondition = journalCondition
    for _, value in ipairs(list) do
	   convertedCondition = string.gsub(convertedCondition, value[1], value[2])
    end
    return convertedCondition
end

function IJAWH:AcquireItemName(condition)
    local list = {
	   {"Acquire%s(.*):.*", "%1"},
	   {"(.*)%s.*%sRune.*", "%1"},
    }

    local acquireItemName = condition
    for _, value in ipairs(list) do
	   acquireItemName = string.gsub(acquireItemName, value[1], value[2])
    end
    return acquireItemName
end

function IJAWH:AcquireConditions()
    local list = {
	   "Acquire%s(.*)",
    }
    return list
end

function IJAWH:CraftingConditions()
    local list = {
	   "Craft.*",
	   "I need to create.*",
    }
    return list
end

function IJAWH:isPoison(conditionText)
if conditionText == nil then return end
    return string.match(conditionText, "Poison")
end
