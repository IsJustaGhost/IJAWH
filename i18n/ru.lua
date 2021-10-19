------------------------------------------------
-- Russian localization for IsJustaWritHelper
------------------------------------------------
local strings = {
IJAWH_BUTTON_RESETWRIT = "Reset For Writ",

SI_IJAWH_NOTENOUGH              = "Недостаточно <<1>>.", --  "You do not have enough

SI_IJAWH_CHATTEROPTION1			= "Прочесть заказы для кузнецов", -- "Examine the Blacksmith Writs"
SI_IJAWH_CHATTEROPTION2			= "Прочесть заказы для портных", -- "Examine the Clothier Writs"
SI_IJAWH_CHATTEROPTION3			= "Прочесть заказы для зачарователей", -- "Examine the Enchanter Writs"
SI_IJAWH_CHATTEROPTION4			= "Прочесть заказы для алхимиков", -- "Examine the Alchemist Writs"
SI_IJAWH_CHATTEROPTION5			= "Прочесть заказы для снабженцев", -- "Examine the Provisioner Writs"
SI_IJAWH_CHATTEROPTION6			= "Прочесть заказы для столяров", -- "Examine the Woodworker Writs"
SI_IJAWH_CHATTEROPTION7			= "Прочесть заказы для ювелиров", -- "Examine the Jewelry Crafting Writs"
SI_IJAWH_CHATTEROPTION8			= "У меня есть все, что нужно.",  -- "I've got them right here"
SI_IJAWH_CHATTEROPTION9			= "Положить предметы в ящик", -- "Place the goods within the crate."
SI_IJAWH_CHATTEROPTION10		= "Подписать манифест", -- "Sign the Manifest"
SI_IJAWH_CHATTEROPTION11		= "Заверщить задание", -- "Finished the job"

SI_IJAWH_WRITREWARD1			= "доставку изготовленных вещей", -- "the delivery of crafted goods."
SI_IJAWH_WRITREWARD2			= "партия сырья", -- "A shipment of raw materials"

SI_IJAWH_CERT = "Certification",
SI_IJAWH_CERTIFI = "certifi",
SI_IJAWH_MASTERFUL = "Masterful",
SI_IJAWH_MASTERFUL_GLYPH = "A Masterful Glyph",
SI_IJAWH_MASTERFUL_CONCOCTION = "A Masterful Concoction",
SI_IJAWH_WITCHES = "Witches Festival Writ",

IJAWH_ACQUIRE_STRING = "Acquire",

SI_IJAWH_CRAFT_WRIT = "Craft for Writ",
SI_IJAWH_EASYALCHEMY = "Easy Alchemy",

SI_IJAWH_WRIT_ITEM_IN_BANK = "You have <<1>> x<<2>> in the bank.",
SI_IJAWH_ADDED_TO_WTHDRAW_LIST = "<<1>> x<<2>> added to be withdrawn from bank.",
SI_IJAWH_IN_WTHDRAW_LIST = "Go to the bank to auto withdraw items for writs.",
SI_IJAWH_WITHDRAW_FROM_BANK = "|c<<1>>Withdraw from bank|r",
SI_IJAWH_WITHDRAW_FROM_BANK_ITEMS = "|c<<1>>(|r <<2>> |c<<1>>)|r  <<3>>",

SI_IJAWH_TOTAL_WRITS = "Завершенные заказы: <<1>>/<<2>>", -- "Completed Writs: <<1>>/<<2>>",
SI_IJAWH_WRIT_NAME = "|c<<1>><<2>>|r",
SI_IJAWH_DELIVER = "Deliver",

SI_IJAWH_SAVEDALCHEMY_SAVED = "Recipe Saved.",
SI_IJAWH_UNKNOWNSAVE_WARNING = "Cannot save unknown recipe.",

SI_IJAWH_CHECK_STATION = "Use station to get details.",
SI_IJAWH_USE_SET_STATION = "This item must be crafted at a <<1>> set crafting station.",
SI_IJAWH_FOUND_IN = "... found in <<1>>",

------------------------------------------------
-- Settings
------------------------------------------------

SI_IJAWH_HEADER_WRIT = "Writ Panel Options",

SI_IJAWH_SETTING_PANELFONT = "Panel font size",
SI_IJAWH_SETTING_PANELFONT_TOOLTIP = "Sets the scale of the Writ Panel based on the font size writs will be displayed in. ",

SI_IJAWH_SETTING_PANELTRANSPARENCY = "Writ Panel transparency",
SI_IJAWH_SETTING_PANELTRANSPARENCY_TOOLTIP = "Sets the transparency of the Writ Panel.",

SI_IJAWH_SETTING_HIDEMOUNTED = "Hide while mounted",
SI_IJAWH_SETTING_HIDEMOUNTED_TOOLTIP = "Enabled: hides the writ panel while mounted.",

SI_IJAWH_HEADER_CRAFT = "Crafting Options",

SI_IJAWH_SETTING_AUTOCRAFT1 = "Auto-craft Smithing writs.",
SI_IJAWH_SETTING_AUTOCRAFT_TOOLTIP1= "Disabled: Prevents auto-crafting Blacksmith, Clothier, Woodworker, Jewelry writs to allow selecting recipes.",
SI_IJAWH_SETTING_AUTOCRAFT3 = "Auto-craft Enchanting writs.",
SI_IJAWH_SETTING_AUTOCRAFT_TOOLTIP3 = "Disabled: Prevents auto-crafting Enchanting writs to allow selecting recipes.",
SI_IJAWH_SETTING_AUTOCRAFT4 = "Auto-craft Alchemy writs.",
SI_IJAWH_SETTING_AUTOCRAFT_TOOLTIP4 = "Disabled: Prevents auto-crafting Alchemy writs to allow selecting recipes.",
SI_IJAWH_SETTING_AUTOCRAFT5 = "Auto-craft Provisioning writs.",
SI_IJAWH_SETTING_AUTOCRAFT_TOOLTIP5 = "Disabled: Prevents auto-crafting Provisioning writs to allow selecting recipes.",

SI_IJAWH_SETTING_RESETTUTORIALS = "Reset Tutorials",
SI_IJAWH_SETTING_RESETTUTORIALS_TOOLTIP = "Will make all tutorials show again.",

SI_IJAWH_HEADER_CERTS = "Certifications",

SI_IJAWH_SETTING_AUTOCRAFT6 = "Auto-refine",
SI_IJAWH_SETTING_AUTOCRAFT_TOOLTIP6 = "Enabled: will auto-refine raw materials for certifications.",

SI_IJAWH_SETTING_AUTOCRAFT7 = "Auto-deconstruct",
SI_IJAWH_SETTING_AUTOCRAFT_TOOLTIP7 = "Enabled: will auto-deconstruct items for certifications.",

SI_IJAWH_SETTING_AUTOCONTINUE = "Auto-continue",
SI_IJAWH_SETTING_AUTOCONTINUE_TOOLTIP = "Enabled: continues crafting all Writs for the current station. Does not require auto-crafting.",

SI_IJAWH_SETTING_USEMOSTSTYLE = "Use Most Style",
SI_IJAWH_SETTING_USEMOSTSTYLE_TOOLTIP = "Enabled: locks smithing writs to use the style material you have the most of.",
SI_IJAWH_SETTING_USERACESTYLE = "Use Race Styles",
SI_IJAWH_SETTING_USERACESTYLE_TOOLTIP = "Enabled: Use Most Style only selects from race style materials.",
SI_IJAWH_SETTING_AUTOIMPROVE = "Auto-improve",
SI_IJAWH_SETTING_AUTOIMPROVE_TOOLTIP = "Enabled: Auto-improve smithing items as required by a master smithing writ upon the following conditions.\n - completion of crafting the item.\n - if auto-improve failed previously, upon using the station",

SI_IJAWH_SETTING_HANDLEWITHDRAW = "Auto-Withdraw From Bank",
SI_IJAWH_SETTING_HANDLEWITHDRAW_TOOLTIP = "Enabled: when a writ requires an item to be crafted that is already in the bank, the item will be added to a list and be auto withdrawn from the bank the next time the bank is accessed",
SI_IJAWH_SETTING_AUTOEXIT = "Auto-Exit from station",
SI_IJAWH_SETTING_AUTOEXIT_TOOLTIP = "Enabled: auto-exits station when all items are crafted for all writs for station.",
SI_IJAWH_SETTING_AUTOACCEPT = "Auto-accept writs from Craft boards",
SI_IJAWH_SETTING_AUTOACCEPT_TOOLTIP = "Enabled: Auto-accepts writs upon using a Craft board. No other clicking needed.",

SI_IJAWH_SETTING_AUTOOPEN = "Auto-open.",
SI_IJAWH_SETTING_AUTOOPEN_TOOLTIP = "Enabled: Auto-loots containers received from turning in writs.",

SI_IJAWH_SETTING_AUTOOPENDELAY = "Auto-open Delay.",
SI_IJAWH_SETTING_AUTOOPENDELAY_TOOLTIP = "Set the delay since last turn-in crate interaction to start opening the writ containers.",

SI_IJAWH_HEADER_OTHER = "Other Options",
SI_IJAWH_SETTING_SAVEPERCHARACTER = "Save settings as Character",
SI_IJAWH_SETTING_SAVEPERCHARACTER_TOOLTIP = "Disabled: settings are saved for the account.\nEnabled: settings will be saved separately for each character.",

SI_IJAWH_SETTING_AUTOCOLLAPSE = "Auto-collaps",
SI_IJAWH_SETTING_AUTOCOLLAPSE_TOOLTIP = "Enabled: the Writ Panel will auto-collaps when all writs are completed.",

SI_IJAWH_HEADER_ALERTS = "Chat Notifications",
SI_IJAWH_SETTING_SHOWWRITITEMALERT = "Show Result Item In Bank Alert",
SI_IJAWH_SETTING_SHOWWRITITEMALERT_TOOLTIP = "Enabled: shows alerts if an item needed to be crafted for the writ is in the player bank.",
SI_IJAWH_SETTING_SHOWWITHDRAWINCHAT = "Show \"to be withdrawn\" in chat",
SI_IJAWH_SETTING_SHOWWITHDRAWINCHAT_TOOLTIP = "Enabled: shows in chat when an item has been added to be auto-withdrawn from the player bank or if it is already on the list.",

SI_IJAWH_CRAFT_ADVISOR_SMITHING_MISSING_TOOLTIP = "If you are missing materials that are required for crafting, you must obtain these before trying to craft. You can purchase most items from Traders or Guild Stores, but you can also try to search for them around Tamriel. The Race Style Material can be purchased from a Blacksmith, Clothier, or Carpenter",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end

--[[
	
SI_IJAWH_CHATTEROPTION11		= 'Заказ для кузнецов', -- "Blacksmith writ",
SI_IJAWH_CHATTEROPTION12		= 'Заказ для портных', -- "Clothier writ",
SI_IJAWH_CHATTEROPTION13		= 'Заказ для зачарователей', -- "Enchanter Writ",
SI_IJAWH_CHATTEROPTION14		= 'Заказ для алхимиков', -- "Alchemist Writ",
SI_IJAWH_CHATTEROPTION15		= 'Заказ для снабженцев', -- "Provisioner Writ",
SI_IJAWH_CHATTEROPTION16		= 'Заказ для столяров', -- "Woodworker writ",
SI_IJAWH_CHATTEROPTION17		= 'Заказ для ювелиров', -- "Jewelry Crafting Writ",
]]