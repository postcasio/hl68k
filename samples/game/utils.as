
macro loop_forever () {
.forever:
	bra.s .forever
}

macro push (reg) {
  move.$ reg, -(sp)
}

macro pusha (reg) {
  move.$ reg, -(sp)
}

macro pop (reg) {
  move.$ (sp)+, reg
}

macro popa (reg) {
  movea.$ (sp)+, reg
}

block utils_ram (@bank = ram_system, @table = default_table) {
  to_hex_string_tmp: ds.b #10
}

block utils_code (@bank = rom_code, @table = default_table) {
copy.l:
  ; a0 = source addr
  ; a1 = dest addr
  ; d0 = count
  subi.w #1,d0
.loop:
  move.l  (A0)+,(A1)+ ; do the long moves
  dbf    d0,.loop

  rts

to_hex_string:
  ; d0 = data
  lea (to_hex_string_tmp).l, a0
to_hex_string_addr:
  ; d0 = data
  ; a0 = destination
  push.l d2

  lea (.hex).l,a1
  clr d1
  move.l #7, d2 ; d2 = offset from start of destination buffer
  clr.b (8,a0)

.next_byte:
  move.b d0, d1 ; d1 = next byte of input data
  andi.b #$0F, d1 ; d1 = last 4 bits
  move.b (a1,d1.w),(a0,d2.w)
  subi.b #1, d2
  move.b d0, d1
  lsr.b #4, d1
  move.b (a1,d1.w),(a0,d2.w)
  lsr.l #8, d0
  dbf d2, .next_byte

  pop.l d2

  rts

.hex: dc.b "0123456789ABCDEF"

}
