struct party {
  byte members[4]
}

struct character {
  word current_hp
  word max_hp
  word current_mp
  word max_mp
  byte sprite_id
  byte character_def_index
  byte name[20]
}

block (@bank = ram_system) {
  parties:
    repeat (4) {
      dc.b 0, 0, 0, 0
    }
  money: dc.l 0
  current_party: dc.b 0
  .align 2
  characters:
    repeat (16) {
      character {}
    }
}

block (@bank = rom_data) {
  initial_party: dc.b 1, 0, 0, 0
  initial_money: dc.l 500
}

block (@bank = rom_code) {
party_init:
  lea parties, a0
  move.l (initial_party).l, (a0)
  move.l #0, (4,a0)
  move.l #0, (8,a0)
  move.l #0, (12,a0)

  move.b #0, (current_party).l
  move.l (initial_money).l, (money).l

  rts
party_get_current:
  ; out a0 -> current party address
  move.l (current_party).l, d0
  lea parties, a0
  lea (a0, d0.l), a0
  rts

party_get_character:
  ; a0 -> party address
  ; d0 -> party index
  ; out d0 -> character id
  move.l (a0,d0.w), d0
  rts

get_character_addr:
  ; d0 -> character ID
  ; out a0 -> character addr
  mulu.w #character.$size, d0
  addi.l #characters, d0
  movea.l d0, a0
  rts
}
