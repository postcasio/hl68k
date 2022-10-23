macro tileset_header (size, graphics_start) {
.tileset_start:
	dc.w size
	dc.l graphics_start
}


block tile_code (@bank = rom_code) {
load_tileset:
    vdp_lea
    clr d0
    move.w (a0)+,d0
    mulu.w #8,d0
    subi.w #1,d0
    movea.l (a0)+,a2
    lea (a2),a0
    vdp_begin_write VDP_VRAM_WRITE, a1
.write:
    move.l (a0)+,d1
    vdp_write d1
    dbf d0,.write
    rts
}
