struct party {
  byte members[4]
}


block (@bank = ram_system) {
  parties:
    repeat (4) {
      dc.b 0, 0, 0, 0
    }
  money: dc.l 0
  current_party: dc.b 0
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

  moveq #1, d0
  jsr get_characterdef_addr
  movea.l a0,a1
  moveq #1, d0
  jsr get_character_addr
  jsr character_init
  rts
party_get_current:
  ; out a0 -> current party address
  moveq #0,d0
  move.b (current_party).l, d0
  lea parties, a0
  lea (a0, d0.l), a0
  rts

party_get_character:
  ; a0 -> party address
  ; d0 -> party index
  ; out d0 -> character id
  moveq #0,d0
  move.b (a0,d0.w), d0
  rts

}
