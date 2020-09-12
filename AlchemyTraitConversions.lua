
function IsJustaEasyAlchemy:ConvertTraitNames(isPoison)
	local isPoison = IsJustaEasyAlchemy.AlchemyHList.pattern[1]
	-- convert first effect name to match potion name
	local pattern = IsJustaEasyAlchemy.AlchemyHList.pattern		-- Poison name
	if isPoison == "Poison" then
		if pattern[2] == "Minor Breach" 							then pattern[2] = "Breaching" 					end
		if pattern[2] == "Minor Cowardice" 							then pattern[2] = "Cowardice" 					end
		if pattern[2] == "Defile" 									then pattern[2] = "Defiling" 					end
		if pattern[2] == "Expose Victim" 							then pattern[2] = "StealthDraining" 			end
		if pattern[2] == "Minor Enervation" 						then pattern[2] = "Enervating" 					end
		if pattern[2] == "Immobilize" 								then pattern[2] = "Entrapping" 					end
		if pattern[2] == "Minor Fracture" 							then pattern[2] = "Fracturing"					end
		if pattern[2] == "Heal Absorption" 							then pattern[2] = "Traumatic" 					end
		if pattern[2] == "Hindrance" 								then pattern[2] = "Hindering" 					end
		if pattern[2] == "Minor Fracture and Resolve"				then pattern[2] = "ResolveDraining" 			end
		if pattern[2] == "Minor Cowardice and Sorcery" 				then pattern[2] = "SorceryDraining" 			end
		if pattern[2] == "Minor Breach and Ward" 					then pattern[2] = "WardDraining" 				end
		if pattern[2] == "Minor Enervation and Savagery" 			then pattern[2] = "SavageryDraining" 			end
		if pattern[2] == "Minor Maim and Brutality" 				then pattern[2] = "BrutalityDraining" 			end
		if pattern[2] == "Mark Victim" 								then pattern[2] = "Conspicuous" 				end
		if pattern[2] == "Gradual Drain Health" 					then pattern[2] = "Gradual Health Drain" 		end
		if pattern[2] == "Minor Maim" 								then pattern[2] = "Maiming" 					end
		if pattern[2] == "Minor Vulnerability and Protection"		then pattern[2] = "ProtectionReversing" 		end
		if pattern[2] == "Poison Damage" 							then pattern[2] = "Damage Health" 				end
		if pattern[2] == "Increase Magicka Cost" 					then pattern[2] = "Damage Magicka" 				end
		if pattern[2] == "Increase Stamina Cost" 					then pattern[2] = "Damage Stamina" 				end
		if pattern[2] == "Drain Health" 							then pattern[2] = "Drain Health" 				end
		if pattern[2] == "Drain Magicka" 							then pattern[2] = "Drain Magicka" 				end
		if pattern[2] == "Drain Stamina" 							then pattern[2] = "Drain Stamina" 				end
		if pattern[2] == "Hindrance and Major Expedition" 			then pattern[2] = "SpeedDraining" 				end
		if pattern[2] == "Minor Uncertainty and Prophecy" 			then pattern[2] = "ProphecyDraining"			end
		if pattern[2] == "Minor Uncertainty" 						then pattern[2] = "Uncertainty" 				end
		if pattern[2] == "Immobilize and Unstoppable" 				then pattern[2] = "Escapists" 					end
		if pattern[2] == "Minor Defile and Vitality" 				then pattern[2] = "VitalityDraining" 			end
		if pattern[2] == "Minor Vulnerability" 						then pattern[2] = "Vulnerability" 				end
		for i=3, #pattern do										-- Effect name
			if pattern[i] == "Minor Breach" 						then pattern[i] = "Breach"						end
			if pattern[i] == "Minor Cowardice" 						then pattern[i] = "Cowardice" 					end
			if pattern[i] == "Defile" 								then pattern[i] = "Defile" 						end
			if pattern[i] == "Expose Victim" 						then pattern[i] = "Detection" 					end
			if pattern[i] == "Minor Enervation" 					then pattern[i] = "Enervation" 					end
			if pattern[i] == "Immobilize" 							then pattern[i] = "Entrapment" 					end
			if pattern[i] == "Minor Fracture" 						then pattern[i] = "Fracture" 					end
			if pattern[i] == "Heal Absorption" 						then pattern[i] = "Heroism" 					end
			if pattern[i] == "Minor Fracture and Resolve" 			then pattern[i] = "Increase Armor" 				end
			if pattern[i] == "Minor Cowardice and Sorcery" 			then pattern[i] = "Increase Spell Power" 		end
			if pattern[i] == "Minor Breach and Ward" 				then pattern[i] = "Increase Spell Resist" 		end
			if pattern[i] == "Minor Enervation and Savagery" 		then pattern[i] = "Increase Weapon Crit" 		end
			if pattern[i] == "Minor Maim and Brutality" 			then pattern[i] = "Increase Weapon Power" 		end
			if pattern[i] == "Mark Victim" 							then pattern[i] = "Invisible" 					end
			if pattern[i] == "Gradual Drain Health" 				then pattern[i] = "Lingering Health" 			end
			if pattern[i] == "Minor Maim" 							then pattern[i] = "Maim" 						end
			if pattern[i] == "Minor Vulnerability and Protection"	then pattern[i] = "Protection" 					end
			if pattern[i] == "Poison Damage" 						then pattern[i] = "Ravage Health" 				end
			if pattern[i] == "Increase Magicka Cost" 				then pattern[i] = "Ravage Magicka" 				end
			if pattern[i] == "Increase Stamina Cost" 				then pattern[i] = "Ravage Stamina" 				end
			if pattern[i] == "Drain Health" 						then pattern[i] = "Restore Health" 				end
			if pattern[i] == "Drain Magicka" 						then pattern[i] = "Restore Magicka" 			end
			if pattern[i] == "Drain Stamina" 						then pattern[i] = "Restore Stamina" 			end
			if pattern[i] == "Hindrance and Major Expedition" 		then pattern[i] = "Speed" 						end
			if pattern[i] == "Minor Uncertainty and Prophecy" 		then pattern[i] = "Spell Critical" 				end
			if pattern[i] == "Minor Uncertainty" 					then pattern[i] = "Uncertainty" 				end
			if pattern[i] == "Immobilize and Unstoppable"			then pattern[i] = "Unstoppable" 				end
			if pattern[i] == "Minor Defile and Vitality"			then pattern[i] = "Vitality" 					end
			if pattern[i] == "Minor Vulnerability"					then pattern[i] = "Vulnerability" 				end
		end
	else															-- Potion name
		if pattern[2] == "Breach" 					then pattern[2] = "Ravage Spell Protection" 	end
		if pattern[2] == "Restore Health" 			then pattern[2] = "Health" 						end
		if pattern[2] == "Restore Magicka" 			then pattern[2] = "Magicka" 					end
		if pattern[2] == "Restore Stamina" 			then pattern[2] = "Stamina" 					end
		if pattern[2] == "Unstoppable" 				then pattern[2] = "Immovability" 				end
		if pattern[2] == "Fracture" 				then pattern[2] = "Ravage Armor" 				end
		if pattern[2] == "Hindrance" 				then pattern[2] = "Hindering" 					end
		if pattern[2] == "Increase Armor" 			then pattern[2] = "Armor" 						end
		if pattern[2] == "Increase Spell Power" 	then pattern[2] = "Spell Power" 				end
		if pattern[2] == "Increase Spell Resist" 	then pattern[2] = "Spell Protection" 			end
		if pattern[2] == "Increase Weapon Power" 	then pattern[2] = "Weapon Power" 				end
		if pattern[2] == "Increase Weapon Crit" 	then pattern[2] = "Weapon Critical" 			end
		if pattern[2] == "Increase Spell Crit" 		then pattern[2] = "Spell Critical" 				end
		if pattern[2] == "Invisible" 				then pattern[2] = "Invisibility" 				end
		if pattern[2] == "Gradual Ravage Health" 	then pattern[2] = "Creeping Ravage Health"  	end
		if pattern[2] == "Unstoppable" 				then pattern[2] = "Immovability" 				end
		for i=3, #pattern do										-- Effect name
			if pattern[i] == "Increase Weapon Crit" 	then pattern[i] = "Weapon Critical" 		end
			if pattern[i] == "Increase Spell Crit" 		then pattern[i] = "Spell Critical" 			end
			
		end
	end
	return pattern
end
