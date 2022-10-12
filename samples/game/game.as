struct party {
  byte members[4];
}

block (@bank = ram_system) {
  parties: dc.l 0, 0, 0, 0      ; 4 parties, 4 bytes per character
  money: dc.b
  current_party: dc.b 0
  characters:
    repeat (16) {
      character {}
    }
}
