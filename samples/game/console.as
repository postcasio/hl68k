COLOR_WHITE = $50
COLOR_RED = $51
COLOR_BLUE = $52
COLOR_GREEN = $53

block console_ram (@bank = ram_system, @align = 2) {
console_cursor_x:  dc.w $0
console_cursor_y:  dc.w $0
}

block console_code (@bank = rom_code, @table = default_table) {
console_init:
  move.w #1, (console_cursor_x).l
  move.w #1, (console_cursor_y).l
  rts

console_nl:
  lea .newline_str, a0
console_write:
  vdp_lea
  ; find address in table for x,y coords
  move.l #VDP_INIT_FOREGROUND_TABLE_VRAM_ADDR, d0
  clr d1
  move.w (console_cursor_y).l, d1
  mulu.w #128, d1
  add.l d1, d0
  move.w (console_cursor_x).l, d1
  mulu.w #2,d1
  add.l d1, d0
  movea.l d0,a1
  vdp_begin_write VDP_VRAM_WRITE, d0
  clr d0
.loop:
  move.b (a0)+, d0
  beq.s .exit
  cmpi.b #$ff, d0
  beq.s .newline
  vdp_write_word d0
  addi.w #1,(console_cursor_x).l
  bra.s .loop
.newline:
  move.l a1,d0
  addi.l #128,d0
  clr d1
  move.w (console_cursor_x).l,d1
  subi.l #1,d1
  mulu.w #2,d1
  sub.l d1,d0
  addi.w #1,(console_cursor_y).l
  move.w #1,(console_cursor_x).l
  vdp_begin_write VDP_VRAM_WRITE, d0
  clr d0
  bra.s .loop
.exit:
  rts

.newline_str: dc.b "\n",0
}
