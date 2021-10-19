function IJAWH:BuildDialogInfo()
	local dialogControl = IsJustaWritHelper_Dialog
--------------
	local tutorialEasyAlchemy =
	{
		customControl = dialogControl,
--		canQueue = true,
		title =
		{
			text = SI_IJAWH_TUTORIAL_EASYALCHEMY_TITLE,
		},
		setup = function(dialog)
			local textControl = dialog:GetNamedChild("ContainerText")
			textControl:SetText(GetString(SI_IJAWH_TUTORIAL_EASYALCHEMY_TEXT))
		end,
		buttons =
		{
			{
				control = dialogControl:GetNamedChild("Close"),
				keybind = "DIALOG_NEGATIVE",
				text = SI_DIALOG_CLOSE,
				callback = function(dialog)
					IJAWH.savedVariables.tutorials.IJAWH_TUTORIAL_EASYALCHEMY = true
					IJAWH.currentQueue = "IJAWH_TUTORIAL_EASYALCHEMY"
					IJAWH:GetNextDialogue()
					ZO_Dialogs_ReleaseDialogOnButtonPress("IJAWH_TUTORIAL_EASYALCHEMY")
				end,
			},
		}
	}
	ZO_Dialogs_RegisterCustomDialog("IJAWH_TUTORIAL_EASYALCHEMY", tutorialEasyAlchemy)
--------------	
	local tutorialAlchemyWrit =
	{
		customControl = dialogControl,
--		canQueue = true,
		title =
		{
			text = SI_IJAWH_TUTORIAL_ALCHEMY_TITLE,
		},
		setup = function(dialog)
			local textControl = dialog:GetNamedChild("ContainerText")
			textControl:SetText(GetString(SI_IJAWH_TUTORIAL_ALCHEMY_TEXT))
		end,
		buttons =
		{
			{
				control = dialogControl:GetNamedChild("Close"),
				keybind = "DIALOG_NEGATIVE",
				text = SI_DIALOG_CLOSE,
				callback = function(dialog)
					IJAWH.savedVariables.tutorials.IJAWH_TUTORIAL_ALCHEMYWRIT = true
					IJAWH.currentQueue = "IJAWH_TUTORIAL_ALCHEMYWRIT"
					IJAWH:GetNextDialogue()
					ZO_Dialogs_ReleaseDialogOnButtonPress("IJAWH_TUTORIAL_ALCHEMYWRIT")
				end,
			},
		}
	}
	ZO_Dialogs_RegisterCustomDialog("IJAWH_TUTORIAL_ALCHEMYWRIT", tutorialAlchemyWrit)
--------------	 
	local tutorialCrftForWrit =
	{
		customControl = dialogControl,
--		canQueue = true,
		title =
		{
			text = SI_IJAWH_TUTORIAL_CRAFT_WRIT_TITLE,
		},
		setup = function(dialog)
			local textControl = dialog:GetNamedChild("ContainerText")
			textControl:SetText(GetString(SI_IJAWH_TUTORIAL_CRAFT_WRIT_TEXT))
		end,
		buttons =
		{
			{
				control = dialogControl:GetNamedChild("Close"),
				keybind = "DIALOG_NEGATIVE",
				text = SI_DIALOG_CLOSE,
				callback = function(dialog)
					IJAWH.savedVariables.tutorials.IJAWH_TUTORIAL_CRAFT_FOR_WRIT = true
					IJAWH.currentQueue = "IJAWH_TUTORIAL_CRAFT_FOR_WRIT"
					IJAWH:GetNextDialogue()
					ZO_Dialogs_ReleaseDialogOnButtonPress("IJAWH_TUTORIAL_CRAFT_FOR_WRIT")
				end,
			},
		}
	}
	ZO_Dialogs_RegisterCustomDialog("IJAWH_TUTORIAL_CRAFT_FOR_WRIT", tutorialCrftForWrit)
--------------	
	local tutorialAutoWitdraw =
	{
		customControl = dialogControl,
--		canQueue = true,
		title =
		{
			text = SI_IJAWH_TUTORIAL_WITHDRAW_TITLE,
		},
		setup = function(dialog)
			local textControl = dialog:GetNamedChild("ContainerText")
			textControl:SetText(GetString(SI_IJAWH_TUTORIAL_WITHDRAW_TEXT))
		end,
		buttons =
		{
			{
				control = dialogControl:GetNamedChild("Close"),
				keybind = "DIALOG_NEGATIVE",
				text = SI_DIALOG_CLOSE,
				callback = function(dialog)
					IJAWH.savedVariables.tutorials.IJAWH_TUTORIAL_AUTO_WITHDRAW = true
					IJAWH.currentQueue = "IJAWH_TUTORIAL_AUTO_WITHDRAW"
					IJAWH:GetNextDialogue()
					ZO_Dialogs_ReleaseDialogOnButtonPress("IJAWH_TUTORIAL_AUTO_WITHDRAW")
				end,
			},
		}
	}
	ZO_Dialogs_RegisterCustomDialog("IJAWH_TUTORIAL_AUTO_WITHDRAW", tutorialAutoWitdraw)
--------------	
	local tutorialstyleMats =
	{
		customControl = dialogControl,
--		canQueue = true,
		title =
		{
			text = SI_IJAWH_TUTORIAL_STYLEMATERIALS_TITLE,
		},
		setup = function(dialog)
			local textControl = dialog:GetNamedChild("ContainerText")
			textControl:SetText(GetString(SI_IJAWH_TUTORIAL_STYLEMATERIALS_TEXT))
		end,
		buttons =
		{
			{
				control = dialogControl:GetNamedChild("Close"),
				keybind = "DIALOG_NEGATIVE",
				text = SI_DIALOG_CLOSE,
				callback = function(dialog)
					IJAWH.savedVariables.tutorials.IJAWH_TUTORIAL_STYLEMATERIALS = true
					IJAWH.currentQueue = "IJAWH_TUTORIAL_STYLEMATERIALS"
					IJAWH:GetNextDialogue()
					ZO_Dialogs_ReleaseDialogOnButtonPress("IJAWH_TUTORIAL_STYLEMATERIALS")
				end,
			},
		}
	}
	ZO_Dialogs_RegisterCustomDialog("IJAWH_TUTORIAL_STYLEMATERIALS", tutorialstyleMats)
end
