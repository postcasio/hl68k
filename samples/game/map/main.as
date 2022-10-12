struct map_header {
	word size
	word width
	word height
	word fgOffset
	word bgOffset
	long palettes[3]
	byte name[20]
}

block map_ram (@bank = ram_system, @align = 16) {
active_map:
active_map_header: map_header {
	name = "                    "
}
active_map_bg: ds.b $2000
active_map_fg: ds.b $2000
}

block map_code (@bank = rom_code, @align = 2) {
load_map_id:
	; d0 = map id
	lea map_list,a1
	subi.w #1,d0
	mulu.w #4,d0
	movea.l (a1, d0.w), a0
load_map_addr:
	; a0 = map header address
	pusha.l a0
	lea active_map_header,a1
	move.l #30, d0
	jsr copy.l			; copy map header to active map header in RAM
	popa.l a0			; restore map header address

	clr d0
	move.w (map_header.size,a0),d0
	vdp_lea
	vdp_write_reg VDP_REG_PLANE_SIZE, d0	; set plane size

	pusha.l a0			; store map header address
	move.w (map_header.bgOffset,a0),d0
	adda.l d0,a0		; add bgOffset to header address

	move.w (map_header.height,a0),d0
	mulu.w (map_header.width,a0),d0
	divu.w #2,d0		; calculate long count in d0
	push.l d0
	lea active_map_bg,a1
	jsr copy.l			; copy bg to ram

	pop.l d0			; restore long count in d0
	movea.l (sp),a0			; restore map header address
	clr d1
	move.w (map_header.fgOffset,a0),d1
	adda.l d1,a0		; add fgOffset to header address

	lea active_map_fg,a1
	jsr copy.l			; copy fg to ram

	popa.l a1			; restore map header address in a1

	lea (a1), a2
	clr d2

	movea.l (map_header.palettes,a2,d2.w),a0
	move.l #32, d0
	jsr load_palette
	addi.b #4, d2

	movea.l (map_header.palettes,a2,d2.w),a0
	move.l #64, d0
	jsr load_palette
	addi.b #4, d2

	movea.l (map_header.palettes,a2,d2.w),a0
	move.l #96, d0
	jsr load_palette

	rts

refresh_map:
	lea active_map_bg,a0
	lea active_map_header,a1

	move.w (map_header.width,a1),d0
	mulu.w (map_header.height,a1),d0
	divu.w #2,d0	; calculate long count in d0

	push.l d0

	lea VDP_INIT_BACKGROUND_TABLE_VRAM_ADDR, a1
	jsr vramcopy.l	; copy bg from ram to vram

	pop.l d0

	lea VDP_INIT_FOREGROUND_TABLE_VRAM_ADDR, a1
	lea active_map_fg,a0
	jsr vramcopy.l	; copy fg from ram to vram

	rts
}
