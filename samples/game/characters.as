struct character_def {
	byte sprite_id
  byte padding
	byte name[20]
}

struct character {
  word current_hp
  word max_hp
  word current_mp
  word max_mp
  byte sprite_id
  byte character_def_id
  byte name[20]
}

block (@bank = rom_code) {

get_character_addr:
  ; d0 -> character ID
  ; out a0 -> character addr
  subi.l #1, d0
  mulu.w #character.$size, d0
  addi.l #characters, d0
  movea.l d0, a0
  rts
get_characterdef_addr:
  ; d0 = def ID
  ; out a0 = def addr
  subi.l #1, d0
  mulu.w #character_def.$size, d0
  addi.l #character_defs, d0
  movea.l d0, a0
  rts
character_init:
; a0 = character addr
; a1 = def addr
	move.b (character_def.sprite_id,a1),(character.sprite_id,a0)
	rts

.print "characters =", characters
.print "character_defs =", character_defs
.print "active map bg =", active_map_bg
.print "active map fg =", active_map_fg
}

block (@bank = rom_data) {

character_defs:
character_0_def:
	character_def {
		sprite_id = 1
		name = "Character 0"
	}
}

block (@bank = ram_system) {

  characters:
    repeat (16) {
      character {}
    }

}
