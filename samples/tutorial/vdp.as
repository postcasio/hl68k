macro write_vdp_register (reg, data) {
	move.w #((reg << 8) | $8000),d0
	or.w data,d0
	move.w d0,(VDP_CONTROL).l
}

macro begin_write_vdp_cram_imm (addr) {
	move.l #(VDP_CRAM_WRITE | ((addr & $3FFF) << 16) | ((addr & $C000) >> 14)),(VDP_CONTROL)
}
