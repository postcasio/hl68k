struct map_header {
	word size
	word width
	word height
	word fgOffset
	word bgOffset
	byte name
}

block map_ram (@bank = ram_system, @align = 16) {
active_map:
active_map_header: map_header {
	name = "                    "
}
active_map_bg: ds.b $2000
active_map_fg: ds.b $2000
active_map_palettes: ds.w 16 * 3
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
	lea (a0),a2
	lea active_map_header,a1
	move.l #30, d0
	jsr copy.l
	lea (a2),a0
	lea (a2),a1
	move.w (map_header.size,a1),d0
	move.l d0,d1
	vdp_write_reg VDP_REG_PLANE_SIZE, d1
	move.w (map_header.bgOffset,a1),d0
	adda.l d0,a0
	move.w (map_header.height,a1),d0
	mulu.w (map_header.width,a1),d0
	divu.w #2,d0
	lea active_map_bg,a1
	jsr copy.l

	rts

refresh_map:
	lea active_map_bg,a0
	lea active_map_header,a1
	move.w (map_header.width,a1),d0
	mulu.w (map_header.height,a1),d0
	divu.w #2,d0
	lea VDP_INIT_BACKGROUND_TABLE_VRAM_ADDR, a1
	jsr vramcopy.l

	rts
}
