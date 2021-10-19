-------------------------------------
-- Smithing
-------------------------------------
-- reference tables
local materialItemIdTOMaterialIndex = {
	[1] = 1,
	[2] = 1,
	[3] = 1,
	[4] = 1,
	[5] = 1,
	[6] = 1,
	[7] = 1,
	[8] = 1,
	[9] = 8,
	[10] = 8,
	[11] = 13,
	[12] = 13,
	[13] = 18,
	[14] = 18,
	[15] = 23,
	[16] = 1,
	[17] = 1,
	[18] = 8,
	[19] = 8,
	[20] = 13,
	[21] = 13,
	[22] = 18,
	[23] = 18,
	[24] = 23,
	[25] = 1,
	[26] = 1,
	[27] = 8,
	[28] = 8,
	[29] = 13,
	[30] = 13,
	[31] = 18,
	[32] = 18,
	[33] = 23,
	[34] = 1,
	[35] = 1,
	[36] = 8,
	[37] = 8,
	[38] = 13,
	[39] = 13,
	[40] = 18,
	[41] = 18,
	[42] = 23,
	[43] = 1,
	[44] = 1,
	[45] = 8,
	[46] = 8,
	[47] = 13,
	[48] = 13,
	[49] = 18,
	[50] = 18,
	[51] = 23,
	[52] = 1,
	[53] = 1,
	[54] = 1,
	[55] = 1,
	[56] = 13,
	[57] = 13,
	[58] = 13,
	[59] = 13,
	[60] = 13,
	
	[116] = 26,
	[117] = 29,
	[118] = 32,
	[119] = 34,
	
	[121] = 26,
	[122] = 29,
	[123] = 32,
	[124] = 34,
	[125] = 26,
	[126] = 29,
	[127] = 32,
	[128] = 34,
	[129] = 26,
	[130] = 29,
	[131] = 32,
	[132] = 34,
	[133] = 26,
	[134] = 29,
	[135] = 32,
	[136] = 34,
	[137] = 26,
	[138] = 26,
	[139] = 33,
	[140] = 33,
	
	
	[146] = 1,
	[147] = 1,
	[148] = 1,
	[149] = 1,
	
	[152] = 8,
	[153] = 8,
	[154] = 8,
	[155] = 8,
	[156] = 13,
	[157] = 13,
	[158] = 13,
	[159] = 13,
	[160] = 18,
	[161] = 18,
	[162] = 18,
	[163] = 18,
	[164] = 23,
	[165] = 23,
	[166] = 23,
	[167] = 23,
	[168] = 26,
	[169] = 26,
	[170] = 26,
	[171] = 26,
	[172] = 29,
	[173] = 29,
	[174] = 29,
	[175] = 29,
	[176] = 32,
	[177] = 32,
	[178] = 32,
	[179] = 32,
	[180] = 34,
	[181] = 34,
	[182] = 34,
	[183] = 34,
	[184] = 34,
	[185] = 34,
	[186] = 34,
	[187] = 34,
	[188] = 40,
	
	[190] = 40,
	
	[192] = 40,
	
	[194] = 40,
	[255] = 40
}

local smithingMaterialQuantity = {-- [crafting type][pattern index][material Id]
	[1] = {
		[1] = {
			[1] = 3,
			[8] = 4,
			[13] = 5,
			[18] = 6,
			[23] = 7,
			[26] = 8,
			[29] = 9,
			[32] = 10,
			[34] = 11,
			[40] = 11
		},
		[2] = {
			[1] = 3,
			[8] = 4,
			[13] = 5,
			[18] = 6,
			[23] = 7,
			[26] = 8,
			[29] = 9,
			[32] = 10,
			[34] = 11,
			[40] = 11
		},
		[3] = {
			[1] = 3,
			[8] = 4,
			[13] = 5,
			[18] = 6,
			[23] = 7,
			[26] = 8,
			[29] = 9,
			[32] = 10,
			[34] = 11,
			[40] = 11
		},
		[4] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 14
		},
		[5] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 14
		},
		[6] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 14
		},
		[7] = {
			[1] = 2,
			[8] = 3,
			[13] = 4,
			[18] = 5,
			[23] = 6,
			[26] = 7,
			[29] = 8,
			[32] = 9,
			[34] = 10,
			[40] = 10
		},
		[8] = {
			[1] = 7,
			[8] = 8,
			[13] = 9,
			[18] = 10,
			[23] = 11,
			[26] = 12,
			[29] = 13,
			[32] = 14,
			[34] = 15,
			[40] = 15
		},
		[9] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[10] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[11] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[12] = {
			[1] = 6,
			[8] = 6,
			[13] = 8,
			[18] = 9,
			[23] = 10,
			[26] = 11,
			[29] = 12,
			[32] = 13,
			[34] = 14,
			[40] = 14
		},
		[13] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[14] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		-- set items
		[15] = {
			[1] = 3,
			[8] = 4,
			[13] = 5,
			[18] = 6,
			[23] = 7,
			[26] = 8,
			[29] = 9,
			[32] = 10,
			[34] = 11,
			[40] = 11
		},
		[16] = {
			[1] = 3,
			[8] = 4,
			[13] = 5,
			[18] = 6,
			[23] = 7,
			[26] = 8,
			[29] = 9,
			[32] = 10,
			[34] = 11,
			[40] = 11
		},
		[17] = {
			[1] = 3,
			[8] = 4,
			[13] = 5,
			[18] = 6,
			[23] = 7,
			[26] = 8,
			[29] = 9,
			[32] = 10,
			[34] = 11,
			[40] = 11
		},
		[18] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 14
		},
		[19] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 14
		},
		[20] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 14
		},
		[21] = {
			[1] = 2,
			[8] = 3,
			[13] = 4,
			[18] = 5,
			[23] = 6,
			[26] = 7,
			[29] = 8,
			[32] = 9,
			[34] = 10,
			[40] = 10
		},
		[22] = {
			[1] = 7,
			[8] = 8,
			[13] = 9,
			[18] = 10,
			[23] = 11,
			[26] = 12,
			[29] = 13,
			[32] = 14,
			[34] = 15,
			[40] = 15
		},
		[23] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[24] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[25] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[26] = {
			[1] = 6,
			[8] = 6,
			[13] = 8,
			[18] = 9,
			[23] = 10,
			[26] = 11,
			[29] = 12,
			[32] = 13,
			[34] = 14,
			[40] = 14
		},
		[27] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[28] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
	},
	[2] = {
		[1] = { -- robe
			[1] = 7,
			[8] = 8,
			[13] = 9,
			[18] = 10,
			[23] = 11,
			[26] = 12,
			[29] = 13,
			[32] = 14,
			[34] = 15,
			[40] = 15
		},
		[2] = { -- shirt
			[1] = 7,
			[8] = 8,
			[13] = 9,
			[18] = 10,
			[23] = 11,
			[26] = 12,
			[29] = 13,
			[32] = 14,
			[34] = 15,
			[40] = 15
		},
		[3] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[4] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[5] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[6] = {
			[1] = 6,
			[8] = 7,
			[13] = 8,
			[18] = 9,
			[23] = 10,
			[26] = 11,
			[29] = 12,
			[32] = 13,
			[34] = 14,
			[40] = 14
		},
		[7] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[8] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[9] = {
			[1] = 7,
			[8] = 8,
			[13] = 9,
			[18] = 10,
			[23] = 11,
			[26] = 12,
			[29] = 13,
			[32] = 14,
			[34] = 15,
			[40] = 15
		},
		[10] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[11] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[12] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[13] = {
			[1] = 6,
			[8] = 7,
			[13] = 8,
			[18] = 9,
			[23] = 10,
			[26] = 11,
			[29] = 12,
			[32] = 13,
			[34] = 14,
			[40] = 14
		},
		[14] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[15] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		-- set items
		[16] = {
			[1] = 7,
			[8] = 8,
			[13] = 9,
			[18] = 10,
			[23] = 11,
			[26] = 12,
			[29] = 13,
			[32] = 14,
			[34] = 15,
			[40] = 15
		},
		[17] = {
			[1] = 7,
			[8] = 8,
			[13] = 9,
			[18] = 10,
			[23] = 11,
			[26] = 12,
			[29] = 13,
			[32] = 14,
			[34] = 15,
			[40] = 15
		},
		[18] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[19] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[20] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[21] = {
			[1] = 6,
			[8] = 7,
			[13] = 8,
			[18] = 9,
			[23] = 10,
			[26] = 11,
			[29] = 12,
			[32] = 13,
			[34] = 14,
			[40] = 14
		},
		[22] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[23] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[24] = {
			[1] = 7,
			[8] = 8,
			[13] = 9,
			[18] = 10,
			[23] = 11,
			[26] = 12,
			[29] = 13,
			[32] = 14,
			[34] = 15,
			[40] = 15
		},
		[25] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[26] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[27] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[28] = {
			[1] = 6,
			[8] = 7,
			[13] = 8,
			[18] = 9,
			[23] = 10,
			[26] = 11,
			[29] = 12,
			[32] = 13,
			[34] = 14,
			[40] = 14
		},
		[29] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
		[30] = {
			[1] = 5,
			[8] = 6,
			[13] = 7,
			[18] = 8,
			[23] = 9,
			[26] = 10,
			[29] = 11,
			[32] = 12,
			[34] = 13,
			[40] = 13
		},
	},
	[6] = {
		[1] = {
			[1] = 3,
			[8] = 4,
			[13] = 5,
			[18] = 6,
			[23] = 7,
			[26] = 8,
			[29] = 9,
			[32] = 10,
			[34] = 11,
			[40] = 12
		},
		[2] = {
			[1] = 6,
			[8] = 7,
			[13] = 8,
			[18] = 9,
			[23] = 10,
			[26] = 11,
			[29] = 12,
			[32] = 13,
			[34] = 14,
			[40] = 14
		},
		[3] = {
			[1] = 3,
			[8] = 4,
			[13] = 5,
			[18] = 6,
			[23] = 7,
			[26] = 8,
			[29] = 9,
			[32] = 10,
			[34] = 11,
			[40] = 12
		},
		[4] = {
			[1] = 3,
			[8] = 4,
			[13] = 5,
			[18] = 6,
			[23] = 7,
			[26] = 8,
			[29] = 9,
			[32] = 10,
			[34] = 11,
			[40] = 12
		},
		[5] = {
			[1] = 3,
			[8] = 4,
			[13] = 5,
			[18] = 6,
			[23] = 7,
			[26] = 8,
			[29] = 9,
			[32] = 10,
			[34] = 11,
			[40] = 12
		},
		[6] = {
			[1] = 3,
			[8] = 4,
			[13] = 5,
			[18] = 6,
			[23] = 7,
			[26] = 8,
			[29] = 9,
			[32] = 10,
			[34] = 11,
			[40] = 12
		},
		-- set items
		[7] = {
			[1] = 3,
			[8] = 4,
			[13] = 5,
			[18] = 6,
			[23] = 7,
			[26] = 8,
			[29] = 9,
			[32] = 10,
			[34] = 11,
			[40] = 12
		},
		[8] = {
			[1] = 6,
			[8] = 7,
			[13] = 8,
			[18] = 9,
			[23] = 10,
			[26] = 11,
			[29] = 12,
			[32] = 13,
			[34] = 14,
			[40] = 14
		},
		[9] = {
			[1] = 3,
			[8] = 4,
			[13] = 5,
			[18] = 6,
			[23] = 7,
			[26] = 8,
			[29] = 9,
			[32] = 10,
			[34] = 11,
			[40] = 12
		},
		[10] = {
			[1] = 3,
			[8] = 4,
			[13] = 5,
			[18] = 6,
			[23] = 7,
			[26] = 8,
			[29] = 9,
			[32] = 10,
			[34] = 11,
			[40] = 12
		},
		[11] = {
			[1] = 3,
			[8] = 4,
			[13] = 5,
			[18] = 6,
			[23] = 7,
			[26] = 8,
			[29] = 9,
			[32] = 10,
			[34] = 11,
			[40] = 12
		},
		[12] = {
			[1] = 3,
			[8] = 4,
			[13] = 5,
			[18] = 6,
			[23] = 7,
			[26] = 8,
			[29] = 9,
			[32] = 10,
			[34] = 11,
			[40] = 12
		},
	},
	[7] = {
		[1] = { -- patternIndex
			[1] = 2,
			[13] = 3,
			[26] = 4,
			[34] = 8,
			[40] = 10
		},
		[2] = { -- patternIndex
			[1] = 3,
			[13] = 5,
			[26] = 6,
			[34] = 12,
			[40] = 15
		},
		-- set items
		[3] = {
			[1] = 2,
			[13] = 3,
			[26] = 4,
			[34] = 6,
			[40] = 10
		},
		[4] = {
			[1] = 3,
			[13] = 5,
			[26] = 6,
			[34] = 8,
			[40] = 15
		},
	}
}

local smithingPatternIndex = {-- [crafting type][item type][armor type]
	[1] = {
		[1] = {
			[0] = 1,
			[3] = 11,
		},
		[2] = {
			[0] = 2,
		},
		[3] = {
			[0] = 3,
			[3] = 8,
		},
		[4] = {
			[0] = 6,
			[3] = 13,
		},
		[5] = {
			[0] = 4,
		},
		[6] = {
			[0] = 5,
		},
		[8] = {
			[3] = 14,
		},
		[9] = {
			[3] = 12,
		},
		[10] = {
			[3] = 9,
		},
		[11] = {
			[0] = 7,
		},
		[13] = {
			[3] = 10,
		},
	},
	[2] = {
		[1] = {
			[1] = 5,
			[2] = 12,
		},
		[3] = {
			[1] = 1,
			[2] = 9,
		},
		[4] = {
			[1] = 7,
			[2] = 14,
		},
		[8] = {
			[1] = 8,
			[2] = 15,
		},
		[9] = {
			[1] = 6,
			[2] = 13,
		},
		[10] = {
			[1] = 3,
			[2] = 10,
		},
		[13] = {
			[1] = 4,
			[2] = 11,
		},
	},
	[6] = {
		[8] = {
			[0] = 1,
		},
		[9] = {
			[0] = 6,
		},
		[12] = {
			[0] = 3,
		},
		[13] = {
			[0] =  4,
		},
		[14] = {
			[0] = 2,
		},
		[15] = {
			[0] = 5,
		},
	},
	[7] = {
		[2] = {
			[0] = 2,
		},
		[12] = {
			[0] = 1,
		},
	}
}

local smithingArmorMaterialItems = {-- [armor type][pattern index]
	[1] = { -- light
		[1] = 811, [8] = 4463, [13] = 23125, [18] = 23126, [23] = 23127, [26] = 46131, [29] = 46132, [32] =  46133, [34] = 46134, [40] = 64504
	},
	[2] = { -- medium
		[1] = 794, [8] = 4447, [13] = 23099, [18] = 23100, [23] = 23101, [26] = 46135, [29] = 46136, [32] = 46137, [34] = 46138, [40] = 64506
	},
	[3] = { -- heavy
		[1] = 5413, [8] = 4487, [13] = 23107, [18] = 6000, [23] = 6001, [26] = 46127, [29] = 46128, [32] = 46129, [34] = 46130, [40] = 64489 
	},
}

local smithingWeaponMaterialItems = {-- [craftingType][pattern index]
	[1] = {-- ingots
		[1] = 5413, [8] = 4487, [13] = 23107, [18] = 6000, [23] = 6001, [26] = 46127, [29] = 46128, [32] = 46129, [34] = 46130, [40] = 64489 
	},
	[6] = {-- wood
		[1] = 803, [8] = 533, [13] = 23121, [18] = 23122, [23] = 23123, [26] = 46139, [29] = 46140, [32] = 46141, [34] = 46142, [40] = 64502
	},
	[7] = {-- jewelry. I know, not a weapon but, uses the crafting type as key.
		[1] = 135138, [13] = 135140, [26] = 135142, [34] = 135144, [40] = 135146
	}
}

local baseItemId = {
	[18] =  43561,
	[24] =  43536,
	[26] =  43564,
	[28] =  43543,
	[29] =  43547,
	[30] =  43548,
	[31] =  43546,
	[32] =  43544,
	[34] =  43545,
	[35] =  43563,
	[37] =  43550,
	[38] =  43554,
	[39] =  43555,
	[40] =  43553,
	[41] =  43551,
	[43] =  43552,
	[44] =  43562,
	[46] =  43537,
	[47] =  43541,
	[48] =  43542,
	[49] =  43540,
	[50] =  43538,
	[52] =  43539,
	[53] =  43529,
	[56] =  43530,
	[59] =  43531,
	[62] =  43535,
	[65] =  43556,
	[67] =  43534,
	[68] =  43532,
	[69] =  43533,
	[70] =  43549,
	[71] =  43560,
	[72] =  43557,
	[73] =  43558,
	[74] =  43559,
	[75] =  44241
}

-- local functions	-----------------------------------
local function getPlatformTab_GP(conditionInfo)
	if CanSmithingSetPatternsBeCraftedHere() then
		if conditionInfo.isMasterWrit then
			if conditionInfo.weaponType then
				return conditionInfo.weaponType == WEAPONTYPE_SHIELD and 2 or 1
			else
				return conditionInfo.armorType == EQUIPMENT_FILTER_TYPE_HEAVY and 2 or 1
			end
		else
			if conditionInfo.weaponType then
				return conditionInfo.weaponType == WEAPONTYPE_SHIELD and 4 or 3
			else
				return conditionInfo.armorType == EQUIPMENT_FILTER_TYPE_HEAVY and 4 or 2
			end
		end
	else
		if conditionInfo.weaponType then
			return conditionInfo.weaponType == WEAPONTYPE_SHIELD and 2 or 1
		else
			return conditionInfo.armorType == EQUIPMENT_FILTER_TYPE_HEAVY and 2 or 1
		end
	end
end

local function getPlatformTab_KB(conditionInfo)
	if conditionInfo.isMasterWrit then
		if conditionInfo.weaponType then
			return conditionInfo.weaponType == WEAPONTYPE_SHIELD and SMITHING_FILTER_TYPE_SET_ARMOR or SMITHING_FILTER_TYPE_SET_WEAPONS
		else
			return conditionInfo.armorType == EQUIPMENT_FILTER_TYPE_NONE and SMITHING_FILTER_TYPE_SET_JEWELRY or SMITHING_FILTER_TYPE_SET_ARMOR
		end
	else
		if conditionInfo.weaponType then
			return conditionInfo.weaponType == WEAPONTYPE_SHIELD and SMITHING_FILTER_TYPE_ARMOR or SMITHING_FILTER_TYPE_WEAPONS
		else
			return conditionInfo.armorType == EQUIPMENT_FILTER_TYPE_NONE and SMITHING_FILTER_TYPE_JEWELRY or SMITHING_FILTER_TYPE_ARMOR
		end
	end
end

local function getTabIndex(conditionInfo)
	if IsInGamepadPreferredMode() then
		return getPlatformTab_GP(conditionInfo)
	else
		return getPlatformTab_KB(conditionInfo)
	end
end

local function getDesiredItemType(itemLink)
	local itemType = 0
	local tabIndex = 0
	if itemLink ~= nil then
		local weaponType = GetItemLinkWeaponType(itemLink)
		if weaponType ~= 0 then
			itemType = weaponType
		else
			local equipType = GetItemLinkEquipType(itemLink)
			itemType = equipType
		end
	end
	return itemType
end

local function hasSetTabsOnly(armorType, craftingType)
	-- toDo check for game mode dependent
	return armorType == 1 or
		armorType == 2 or
		craftingType == 7
end

local function findIndexFromData(selectedData, itemType, scrollList)
	local equalityFunction = function (a, b) return (a == b) end
	if selectedData then
		for newDataIndex, newData in ipairs(scrollList) do
			if equalityFunction(selectedData, newData[itemType]) then
				return newDataIndex
--				return 1 - newDataIndex
			end
		end
	end
	return 1
end

-------------------------------------
local Smithing_Writ_Object = IJA_WritHelper_Shared_Writ_Object:Subclass()

function Smithing_Writ_Object:GetRecipeData(conditionInfo)
--	local patternIndex, materialIndex
	local itemId = conditionInfo.itemId ~= 0 and conditionInfo.itemId or baseItemId[conditionInfo.itemTemplateId]
	local itemLink = self:GetItemLink(itemId)
	self.comparator	= self:GetComparator(itemLink)
	
	if conditionInfo.isMasterWrit then
		-- until the correct crafting station is used, itemId and itemLink are set to a generic item of correct type
		self.isMasterWrit	= true
		self.itemSetId		= conditionInfo.itemSetId
		self.improveItem	= self.savedVars.autoImprove
		self.itemFunctionalQuality = conditionInfo.itemFunctionalQuality
	end
	
	self.itemLink = itemLink
	local patternIndex, materialIndex = self:GetSmithingPatternIndex(conditionInfo)
	
	if patternIndex and materialIndex then
		local materialQuantity = self:GetMaterialQuantity(patternIndex, materialIndex)
		
		self:SetInternalItemCat(itemLink)
		local recipeData = {
			["patternIndex"]		= patternIndex,
			["materialIndex"]		= materialIndex, 
			["materialQuantity"] 	= materialQuantity, 
			["itemStyleId"]			= conditionInfo.itemStyleId,
			["itemTraitType"]		= conditionInfo.itemTraitType or 0,
			
			 -- for stations that do not have separate tabs for different types of items unless it's a set station
			["hasSetTabsOnly"]		= hasSetTabsOnly(self.armorType, self.craftingType)
		}
		return recipeData, itemId, self:UpdateLinkLevel(itemLink, recipeData)
	else
	end
end

function Smithing_Writ_Object:AutoCraft()
	if self:GetWrtitType() == WRIT_TYPE_CRAFT then
		local patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex, useUniversalStyleItem, numIterations = self:GetAllCraftingParameters()

		local maxIterations, craftingResult = GetMaxIterationsPossibleForSmithingItem(
				patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex, useUniversalStyleItem, numIterations
			)
		
		if maxIterations > 0 then
	--		CraftSmithingItem(patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex, useUniversalStyleItem, numIterations)
			self:TryCraftItem(CraftSmithingItem, patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex, useUniversalStyleItem, numIterations)
		else
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString("SI_TRADESKILLRESULT", craftingResult))
		end
	else
		self:Deconstruct()
	end
end

function Smithing_Writ_Object:GetAllCraftingParameters(recipeData)
	local useUniversalStyleItem = self:GetIsUsingUniversalStyleItem() or false
	
	local patternIndex, materialIndex, materialQuantity, itemStyleId, itemTraitType = self:GetCraftingParametersWithoutIterations(recipeData)
	local traitIndex = itemTraitType + 1
	
	local styleCount = GetCurrentSmithingStyleItemCount(itemStyleId)
	local numIterations = self:GetRequiredIterations()
	
	-- only craft up to the maximum of the quantity of the selected style item
	numIterations = styleCount < numIterations and styleCount or numIterations
	
	return patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex, useUniversalStyleItem, numIterations
end

function Smithing_Writ_Object:GetCraftingParametersWithoutIterations(recipeData)
	recipeData = recipeData or self.recipeData

	local patternIndex		= recipeData.patternIndex
	local materialIndex 	= recipeData.materialIndex
	local materialQuantity	= recipeData.materialQuantity
	local itemTraitType		= recipeData.itemTraitType
	
	local itemStyleId 		= recipeData.itemStyleId or self:GetStyleId(patternIndex)
	
	return patternIndex, materialIndex, materialQuantity, itemStyleId, itemTraitType
end

function Smithing_Writ_Object:MeetsCraftingRequierments()
	local patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex = self:GetAllCraftingParameters()

	local numIterations = self:GetRequiredIterations()
	
	local materialItemId = self:GetMaterialItemId(materialIndex)
	local materialIStackCount = self:GetMaterialData(materialItemId).stackCount
	
	local styleCount = GetCurrentSmithingStyleItemCount(itemStyleId)
	
	local knownStyle = IsSmithingStyleKnown(itemStyleId, patternIndex)
	local knownTrait = IsSmithingTraitKnownForResult(patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex)

	self:AddMaterialCounts('materialQuantity',  materialQuantity)
	self:AddMaterialCounts('styleCount',  numIterations)
	
	local traitCount = 0
	if traitIndex > 1 then
		traitCount = GetCurrentSmithingTraitItemCount(traitIndex)
		self:AddMaterialCounts('traitCount',  numIterations)
	end

	local maxLevelMaterial = self:GetMaxLevelMaterial()
	self.craftingConditions = {
		[1] = materialIndex > maxLevelMaterial and 140 or nil,
		[2] = not knownStyle and 138 or nil,
		[3] = (traitIndex > 1 and not knownTrait) and 120 or nil,
		[4] = self:GetMaterialCount('materialQuantity') > materialIStackCount and 141 or nil,
		[5] = self:GetMaterialCount('styleCount') > styleCount and 142 or nil,
		[6] = (traitIndex > 1 and self:GetMaterialCount('traitCount') > traitCount) and 143 or nil,
		[7] = not CheckInventorySpaceSilently(self.conditionInfo.maximum) and 6 or nil,
	}
end

function Smithing_Writ_Object:GetMissingMessage()
	local missingMessage = {}

	local patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex, useUniversalStyleItem, numIterations = self:GetAllCraftingParameters()

    local materialLink = GetSmithingPatternMaterialItemLink(patternIndex, materialIndex)
    self:UpdateCraftItems(GetItemLinkItemId(materialLink), materialQuantity)
    local styleLink = GetItemStyleMaterialLink(itemStyleId)
    self:UpdateCraftItems(GetItemLinkItemId(styleLink), numIterations)
    local traitLink = GetSmithingTraitItemLink(traitIndex)
    self:UpdateCraftItems(GetItemLinkItemId(traitLink), numIterations)

    local missingCraftItemStrings = self:GetMissingCraftItemStrings()
    IJA_insert(missingMessage, missingCraftItemStrings)

	if not CheckInventorySpaceSilently(self.conditionInfo.maximum) then
		table.insert(missingMessage, GetString("SI_TRADESKILLRESULT", 6))
	end
	
	if materialIndex > self:GetMaxLevelMaterial() then
		table.insert(missingMessage, GetString("SI_TRADESKILLRESULT", 140))
	end

	local knownStyle = IsSmithingStyleKnown(itemStyleId, patternIndex)
	if not knownStyle then
		table.insert(missingMessage, GetString("SI_TRADESKILLRESULT", 138))
	end
    
	if traitIndex > 1 then
		local knownTrait = IsSmithingTraitKnownForResult(patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex)
		if (traitIndex > 1 and not knownTrait) then
		table.insert(missingMessage, GetString("SI_TRADESKILLRESULT", 120))
		end
	end
	
	if #missingMessage == 0 then
		-- used if no other definded reson was true
		local maxIterations, limitReason = GetMaxIterationsPossibleForSmithingItem(patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex, useUniversalStyleItem)
		local numIterations = self:GetRequiredIterations()
		if maxIterations == numIterations then
			table.insert(missingMessage, GetString("SI_TRADESKILLRESULT", limitReason))
		end
	end

	return missingMessage
end

function Smithing_Writ_Object:GetMaterialStackCount(materialIndex)
	return self:GetMaterialData(self:GetMaterialItemId(materialIndex)).stackCount
end

function Smithing_Writ_Object:GetMaxLevelMaterial()
	local craftingType = self.craftingType
	local skillRank = self:GetSkillRank(craftingType, 1)
	if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
		return skillRank > 0 and select(skillRank , 1, 13, 26, 34, 40) or 1
	else
		return skillRank > 0 and select(skillRank , 1, 8, 13, 18, 23, 26, 29, 32, 34, 40) or 1
	end
end

--					-----------------------------------------------------------
function Smithing_Writ_Object:SetStation()
	local function setDesiredTabAndItem(tabIndex, hasSetTabsOnly)
		if GAMEPAD_SMITHING_CREATION_SCENE:IsShowing() or (SMITHING_SCENE:IsShowing() and SMITHING.mode == self:GetWrtitType()) then
			EVENT_MANAGER:UnregisterForUpdate("IJA_WaitForScene")
			if self:GetWrtitType() == WRIT_TYPE_CRAFT then
				
				if hasSetTabsOnly and not CanSmithingSetPatternsBeCraftedHere() then
				else
					if IsInGamepadPreferredMode() then
						ZO_GamepadGenericHeader_SetActiveTabIndex(SMITHING_GAMEPAD.header, tabIndex)
					else
						ZO_MenuBar_SelectDescriptor(SMITHING.creationPanel.tabs, tabIndex)
					end
				end
				
				zo_callLater(function()
					self:SetStationLists()
				end, 100)
			else
				local zo_Object = IsInGamepadPreferredMode() and SMITHING_GAMEPAD or SMITHING
				local itemLink = self:GetItemLink(self.itemId)
				local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(self:GetItemData(self.itemId, self:GetComparator(itemLink)))
				if bagId then
					zo_Object = self:GetWrtitType() == WRIT_TYPE_REFINE and zo_Object.refinementPanel or zo_Object.deconstructionPanel
					zo_Object:AddItemToCraft(bagId, slotIndex)
				end
			end
		end
	end
	
	local setTabs = false
	if self.recipeData then
		setTabs = self.recipeData.hasSetTabsOnly
	end
	EVENT_MANAGER:RegisterForUpdate("IJA_WaitForScene", 10, function() setDesiredTabAndItem(getTabIndex(self), setTabs) end)
end

function Smithing_Writ_Object:SetStationLists()
	local patternIndex, materialIndex, materialQuantity, itemStyleId, itemTraitType = self:GetCraftingParametersWithoutIterations()

	if patternIndex and materialIndex and itemStyleId and itemTraitType then
		local zo_Object = IsInGamepadPreferredMode() and SMITHING_GAMEPAD or SMITHING
		if zo_Object.mode ~= SMITHING_MODE_CREATION then return end
		
		local patternListIndex = findIndexFromData(patternIndex, "patternIndex", zo_Object.creationPanel.patternList.list)
		zo_Object.creationPanel.patternList:SetSelectedDataIndex(patternListIndex, true, true)
		zo_Object.creationPanel.patternList:RefreshVisible()
		
		local materialListIndex = findIndexFromData(materialIndex, "materialIndex", zo_Object.creationPanel.materialList.list)
		zo_Object.creationPanel.materialList:SetSelectedDataIndex(materialListIndex, true, true)
		zo_Object.creationPanel.materialQuantitySpinner:SetValue(1)
		zo_Object.creationPanel.materialList:RefreshVisible()
		
		if self.savedVars.useMostStyle or self.isMasterWrit then
			local styleListIndex = findIndexFromData(itemStyleId, "itemStyleId", zo_Object.creationPanel.styleList.list)
			zo_Object.creationPanel.styleList:SetSelectedDataIndex(styleListIndex, true, true)
			zo_Object.creationPanel.styleList:RefreshVisible()
		end
		
		local traitListIndex = findIndexFromData(itemTraitType, "traitType", zo_Object.creationPanel.traitList.list)
		zo_Object.creationPanel.traitList:SetSelectedDataIndex(traitListIndex, true, true)
		zo_Object.creationPanel.traitList:RefreshVisible()
	end
end

function Smithing_Writ_Object:SelectMode()
	if SCENE_MANAGER:GetPreviousSceneName() == 'hud' then
		if IsInGamepadPreferredMode() then
			SMITHING_GAMEPAD:SetMode(self.writType)
		else
			ZO_MenuBar_SelectDescriptor(SMITHING.modeBar, self.writType)
		end
	end
end

function Smithing_Writ_Object:GetSmithingPatternIndex(conditionInfo)
	local desiredItemType = getDesiredItemType(self.itemLink)
	local armorType = GetItemLinkArmorType(self.itemLink)
	self.armorType = armorType
	
	local materialList = smithingMaterialQuantity[self.craftingType]
	local masterModifier = conditionInfo.isMasterWrit and #materialList / 2 or 0
	
	local materialIndex = materialItemIdTOMaterialIndex[conditionInfo.materialItemId]
	local patternIndex = smithingPatternIndex[self.craftingType][desiredItemType][armorType] + masterModifier
	
	return patternIndex, materialIndex
end

function Smithing_Writ_Object:GetMaterialQuantity(patternIndex, materialIndex)
	local materialList = smithingMaterialQuantity[self.craftingType]
	local materialQuantity = materialList[patternIndex][materialIndex]
	return materialQuantity
end

function Smithing_Writ_Object:GetStyleId(patternIndex)
	self:UpdateSmithingStyleList(patternIndex)
	
	if self.savedVars.useMostStyle then
		return self.StyleList[1].itemStyleId
	end
	return GetFirstKnownItemStyleId(patternIndex)
end

function Smithing_Writ_Object:SortRecipeData()
	local sortedConditions = {}
	
	for k, recipeData in pairs(self.conditions) do
		table.insert(sortedConditions, recipeData)
	end
	
	local function sortFunction(a, b)
		if a.recipeData and b.recipeData then
			local mat_a = a.recipeData.materialQuantity or 0
			local mat_b = b.recipeData.materialQuantity or 0
		
			return mat_a < mat_b
		end
	end
	table.sort(sortedConditions, sortFunction)
	
	self.sortedConditions = sortedConditions
end

function Smithing_Writ_Object:GetIsUsingUniversalStyleItem()
	local zo_Object = IsInGamepadPreferredMode() and SMITHING_GAMEPAD or SMITHING
	return zo_Object.creationPanel:GetIsUsingUniversalStyleItem()
end

function Smithing_Writ_Object:GetItemStyleItemId(itemStyleId)
	for k, data in pairs(self.StyleList) do
		if data.itemStyleId == itemStyleId then
			return data.itemId
		end
	end
end

function Smithing_Writ_Object:GetSmithingStyleItemInfo(itemStyleId)
    local styleItemLink = GetItemStyleMaterialLink(itemStyleId)
	local itemId = GetItemLinkItemId(styleItemLink)
	local itemData = self:GetItemData(itemId, IJA_IsStyleMaterial)
	if itemData then
		local stackCount = itemData.stackCount or 0
		return itemData.name, stackCount, itemStyleId, itemData.itemId, itemData.meetsUsageRequirement
	end
	return nil, 0, itemStyleId
end

local function canAddStyileItem(itemStyleId, patternIndex, meetsUsageRequirement, stackCount)
	local canBeUsed = function(itemStyleId, patternIndex)
		if patternIndex then
			return IsSmithingStyleKnown(itemStyleId, patternIndex)
		else
			return true
		end
	end

	return stackCount > 0 and meetsUsageRequirement and canBeUsed(itemStyleId, patternIndex)
end

function Smithing_Writ_Object:UpdateSmithingStyleList(patternIndex)
	local styleList = {}
	local numStyles = self.savedVars.useRaceStyles and GetImperialStyleId() or GetNumValidItemStyles()
	local i = 1
	
    repeat
		local styleName, stackCount, itemStyleId, itemId, meetsUsageRequirement = self:GetSmithingStyleItemInfo(GetValidItemStyleId(i))
		
		if canAddStyileItem(itemStyleId, patternIndex, meetsUsageRequirement, stackCount) then
			local data = {
				styleItem = styleName,
				stackCount = stackCount, 
				itemStyleId = itemStyleId,
				itemId = itemId,
			}
		
			table.insert(styleList, data)
		end
		
		if i == 9 and self.savedVars.useRaceStyles then 
			i = GetImperialStyleId()
		else
			i = i + 1
		end
    until i == numStyles
	
	table.sort(styleList, function(a,b)return a.stackCount > b.stackCount end)
	self.StyleList = styleList
end

function Smithing_Writ_Object:GetMaterialData(materialItemId)
	local comparator = self:GetComparator(self:GetItemLink(materialItemId))
	local itemData =  self:GetItemData(materialItemId, comparator)
	return itemData
end

function Smithing_Writ_Object:GetMaterialItemId(materialIndex)
	local meterialItems = self.armorType > 0 and smithingArmorMaterialItems[self.armorType] or smithingWeaponMaterialItems[self.craftingType]
	return meterialItems[materialIndex]
end

function Smithing_Writ_Object:GetMaxIterations()
	local patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex, useUniversalStyleItem = self:GetAllCraftingParameters()

	local maxIterations, craftingResult = GetMaxIterationsPossibleForSmithingItem(
		patternIndex, 
		materialIndex, 
		materialQuantity, 
		itemStyleId, 
		traitIndex, 
		useUniversalStyleItem
	)
	
	return maxIterations, craftingResult
end

function Smithing_Writ_Object:SetInternalItemCat(itemLink)
	local internalItemCat = 0
	local weaponType = GetItemLinkWeaponType(itemLink)
	if weaponType ~= 0 then
		self.weaponType = weaponType
	else
		local armorType = GetItemLinkArmorType(itemLink)
		self.armorType = armorType
	end
end

function Smithing_Writ_Object:GetResultItemLink()
	return GetSmithingPatternResultLink(self:GetCraftingParametersWithoutIterations())
end

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

-------------------------------------
-- Smithing improvement
-------------------------------------
function Smithing_Writ_Object:GetImprovementData(functionalQuality, craftingType)
	local upgradeFromFunctionalQuality = functionalQuality - 1
--	local reagentsAvailable = select(3, GetSmithingImprovementItemInfo(craftingType, upgradeFromFunctionalQuality))
	local reagentName, _, reagentsAvailable = GetSmithingImprovementItemInfo(craftingType, upgradeFromFunctionalQuality)
	local reagentsRequired = GetSmithingGuaranteedImprovementItemAmount(craftingType, upgradeFromFunctionalQuality)
	local itemLink = GetSmithingImprovementItemLink(craftingType, functionalQuality)

	local valid = true
	local extraInfo = nil
	if reagentsAvailable < reagentsRequired then
		extraInfo = zo_strformat(SI_SMITHING_MATERIAL_REQUIRED, reagentsRequired, reagentName)
		valid = false
	end

	return valid, reagentsRequired, reagentsAvailable, extraInfo, itemLink
end

function Smithing_Writ_Object:BuildImprovementData()
	if not self.savedVars.autoImprove then return end
   local improvementData = {}
    local minimumUpgradeQuality = 2
	
    local sufficientPrecursorReagents = true
    for functionalQuality = minimumUpgradeQuality, self.conditionInfo.itemFunctionalQuality do
		local valid, reagentsRequired, reagentsAvailable, extraInfo, itemLink = self:GetImprovementData(functionalQuality, self.craftingType)
		
		if not valid then
			sufficientPrecursorReagents = false
		end
	
		local data = {
			valid = valid,
			quality = functionalQuality,
			quantity = reagentsRequired,
			available = reagentsAvailable,
			extraInfo = extraInfo
		}
		table.insert(improvementData, data)

--		self:UpdateCraftItems(GetItemLinkItemId(itemLink), reagentsRequired)
    end
	
	return improvementData, sufficientPrecursorReagents
end

function Smithing_Writ_Object:ImproveItem(bagId, slotIndex)
	EVENT_MANAGER:UnregisterForEvent("IJAWH_ON_ITEM_IMPROVED")
	local currentQuality = GetItemFunctionalQuality(bagId, slotIndex)
	
	if currentQuality < self.conditionInfo.itemFunctionalQuality then
		local valid, numBoostersToApply, reagentsAvailable, extraInfo = self:GetImprovementData(currentQuality + 1, self.craftingType)
		
		if valid then
			EVENT_MANAGER:RegisterForEvent("IJAWH_ON_ITEM_IMPROVED", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(eventId, ...) self:ImproveItem(...) end)
			ImproveSmithingItem(bagId, slotIndex, numBoostersToApply)
		else
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(SI_TRADESKILLRESULT119))
			d( extraInfo)
			return
		end
	else
		self.improvementData = nil
		self.improvementItemData = nil
		
		CALLBACK_MANAGER:FireCallbacks("IsJustaWritHelper_OnCraftComplete", nil, nil, GetCraftingInteractionType())
	end
end

function Smithing_Writ_Object:TryImproveItem(bagId, slotIndex)
	if bagId and slotIndex then
		self:ImproveItem(bagId, slotIndex)
	else
		-- alert no item data
	end
end

function Smithing_Writ_Object:HasItemToImproveForWrit()
	if not self.isMasterWrit then return false end
	local conditionInfo = self.conditionInfo
	local patternIndex, materialIndex, desiredItemId = GetSmithingPatternInfoForItemSet(conditionInfo.itemTemplateId, conditionInfo.itemSetId, conditionInfo.materialItemId, conditionInfo.itemTraitType)
	
	-- update itemId and itemLink to correct item
	self.itemId = desiredItemId
	self.itemLink =  self:UpdateLinkLevel(self:GetItemLink(desiredItemId))

	return HasItemToImproveForWrit(desiredItemId, conditionInfo.materialItemId, conditionInfo.itemTraitType, conditionInfo.itemStyleId, conditionInfo.itemFunctionalQuality)
end

function Smithing_Writ_Object:GetImprovementItemData()
	local itemData = self:GetItemData(self.itemId, self.comparator)
--	local bagId, slotIndex = self:GetBagAndSlot(itemData)
	local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(itemData)
	return bagId, slotIndex
end

-------------------------------------
-- Deconstruct or Refine
-------------------------------------
function Smithing_Writ_Object:Deconstruct(bagId, slotIndex)
	local zo_Object = IsInGamepadPreferredMode() and SMITHING_GAMEPAD or SMITHING
	zo_Object = self:GetWrtitType() == WRIT_TYPE_REFINE and zo_Object.refinementPanel or zo_Object.deconstructionPanel

	local itemLink = self:GetItemLink(self.itemId)
	local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(self:GetItemData(self.itemId, self:GetComparator(itemLink)))
	if bagId then
		PrepareDeconstructMessage()
		local quantity = zo_Object:IsInRefineMode() and GetRequiredSmithingRefinementStackSize() or 1
		if AddItemToDeconstructMessage(bagId, slotIndex, quantity) then
			SendDeconstructMessage()
		end
	end
end

-------------------------------------
IJA_WritHelper_Smithing_Object = Smithing_Writ_Object

--[[

	local zo_Object = IsInGamepadPreferredMode() and SMITHING_GAMEPAD or SMITHING
	zo_Object.creationPanel:AddItemToCraft(bagId, slotIndex)



        local comparator = self:GetComparator(itemId)
        local itemData = self:GetItemData(itemId, comparator)





function test()
	local craftingType = GetCraftingInteractionType()
	for i=1, GetNumSmithingTraitItems() do
		d( traitItemLink) 
	end
end


Iron, 
Steel, 
Orichalc, 
Dwarven, 
Ebony, 
Calcium, 
Galatite, 
Quicksilver, 
Voidstone, 
Rubedite


Pewter		1
Copper		26
Silver		cp10
Electrum	cp80
Platinum	cp150

|H0:item:43531:308:50:0:0:0:0:0:0:0:0:0:0:0:0:3:1:0:0:0:0|h|h
	
function :UpdateLinkLevel(itemLink)
	local linkString = "|H0:item:[%d]+:<<1>>:[%d:{18}]+|h|h"
	
	local linkLevel = self:GetLinkLevel()
	return zitemLink:gsub(linkString, linkLevel)
end


	itemLink:gsub(linkString, linkLevel)
	
    local itemId, potionData = itemLink:match('|H0:item:[%d]+:<<1>>:[%d:{18}]+|h|h')
	
	
	
		return skillRank > 0 and select(skillRank , 1, 13, 26, 33, 40) or 1
	else
		return skillRank > 0 and select(skillRank , 1, 8, 13, 18, 23, 26, 29, 32, 34, 40) or 1
		

	local CraftingInteractionType = GetCraftingInteractionType()

	local skillRank = IJAWH:GetSkillRank(CraftingInteractionType, 1)
	
	if CraftingInteractionType == CRAFTING_TYPE_JEWELRYCRAFTING then
		return skillRank > 0 and select(skillRank , 1, 13, 26, 33, 40) or 1
	else
		return skillRank > 0 and select(skillRank , 1, 8, 13, 18, 23, 26, 29, 32, 34, 40) or 1
	end
	
	
	
			if self.savedVars.autoImprove then
				local recipeData_Object = self.currentWrit:GetCurrentCondition()
				if recipeData_Object:HasItemToImproveForWrit() then 
					recipeData_Object:TryImproveItem(recipeData_Object:GetImprovementItemData())
					return
				end
			end

local Saved_Vars = {}
			
	Saved_Vars = self.savedVars
	
			if self.savedVars.autoImprove then
				local o = self.currentWrit:GetCurrentCondition()
				if o:HasItemToImproveForWrit() then 
					o:TryImproveItem(o:GetImprovementItemData())
					return
				end
			end
			
			
local writObject = 
local o = 


			if recipeObject.improvementItemData ~= nil and self.savedVars.autoImprove then
				recipeObject:ImproveItem(recipeObject:GetImprovementItemData())
			end
recipeObject:GetImprovementItemData()


/script d(GetSmithingPatternInfoForItemSet(65, 51, 192, 11))
/script d(GetSmithingPatternInfoForItemSet(65, 51, 192, 1))
/script d(HasItemToImproveForWrit(49109, 192, 11, 43, 4))

desiredItemId, conditionInfo.materialItemId, conditionInfo.itemTraitType, conditionInfo.itemStyleId, conditionInfo.itemFunctionalQuality


GetSmithingPatternInfoForItemSet(itemTemplateId, itemSetId, materialItemId, itemTraitType)

|H0:item:49109:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1000:0|h|h


--]]