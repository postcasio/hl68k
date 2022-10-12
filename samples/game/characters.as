struct character_def {
	word sprite_id;
	byte name[20];
}

block (@bank = rom_code) {
}

block (@bank = rom_data) {

character_def_list:
character_0: dc.l character_0_data

character_0_data:
	character_def {
		sprite_id = 1
		name = "Character 0"
	}
}
