macro vdp_lea() {
	lea VDP_CONTROL,a5
	lea VDP_DATA,a6
}
macro vdp_write_reg (reg, data) {
	or.w #((reg << 8) | $8000),data
	move.w data,(a5)
}

macro vdp_write_reg_imm (reg, data) {
	move.w #((reg << 8) | $8000 | data),(a5)
}

macro vdp_begin_write_cram_imm (addr) {
	move.l #(VDP_CRAM_WRITE | ((addr & $3FFF) << 16) | ((addr & $C000) >> 14)),(a5)
}

macro vdp_begin_write_vram_imm (addr) {
	move.l #(VDP_VRAM_WRITE | ((addr & $3FFF) << 16) | ((addr & $C000) >> 14)),(a5)
}

macro vdp_begin_write (type, addr) {
	clr d1
	push.l d2
	push.l d3
	clr d2
	move.w addr,d1
	move.w addr,d2
	and.w #$c000,d1
	move.l #14,d3
	lsr.l d3,d1
	and.w #$3fff,d2
	move.l #16,d3
	lsl.l d3,d2
	or.l d2,d1
	or.l #(type),d1
	move.l d1,(a5)
	pop.l d3
	pop.l d2
}

macro vdp_write (data) {
	move.l data,(a6)
}

macro vdp_write_word (data) {
	move.w data,(a6)
}

macro vdp_write_dir (data) {
	move.l data,(VDP_CONTROL)
}

macro vdp_set_bgcolor(color) {
	vdp_write_reg VDP_REG_BGCOLOR, color
}

block vdp_utils_block (@bank = rom_code) {
vramcopy.l:
  ; a0 = source addr
  ; a1 = dest addr
  ; d0 = count
  vdp_lea
  vdp_begin_write VDP_VRAM_WRITE, a1
  subi.w #1,d0
.vramloop:
  move.l  (a0)+,(a6)
  dbf    d0,.vramloop
  rts
vdp_init:
	lea VDP_DATA,a0
	lea VDP_CONTROL,a1
	move.w #$8000,d0
	move.b #19,d1
	lea (.vdp_register_init_table,pc),a2
.loop:
	move.b (a2)+,d0
	move.w d0,(a1)
	add.w #$100,d0
	dbf d1,.loop
	rts
.vdp_register_init_table:
	dc.b	0b00010110	; Register $80 - hint enable, normal operation, HV counter off
	dc.b	0b01110100	; Register $81 - display enable, vint enable, dma enable, NTSC, MD mode
	dc.b	(VDP_INIT_FOREGROUND_TABLE_VRAM_ADDR >> 10)			; Register $82 - foreground nametable VRAM address = $C000
	dc.b	(VDP_INIT_WINDOW_TABLE_VRAM_ADDR >> 10)			; Register $83 - window nametable VRAM address = $B000
	dc.b	(VDP_INIT_BACKGROUND_TABLE_VRAM_ADDR >> 13)			; Register $84 - background nametable VRAM address = $E000
	dc.b	(VDP_INIT_SPRITE_TABLE_VRAM_ADDR >> 9)			; Register $85 - sprite table VRAM address = $AC00
	dc.b	$00			; Register $86
	dc.b	$00			; Register $87
	dc.b	$00			; Register $88
	dc.b	$00			; Register $89
	dc.b	$FF			; Register $8A
	dc.b	$00			; Register $8B
	dc.b	$81			; Register $8C
	dc.b	$2A			; Register $8D
	dc.b	$00			; Register $8E
	dc.b	$02			; Register $8F
	dc.b	$11			; Register $90
	dc.b	$00			; Register $91
	dc.b	$00			; Register $92
	dc.b	$00			; Register $93
	dc.b	$00			; Register $94
	dc.b	$00			; Register $95
	dc.b	$00			; Register $96
	dc.b	$00			; Register $97
}
