struct sprite {
	long tiles
	byte size
	byte frames
}

block (@bank = rom_data) {
sprites:
sprite_00:
	sprite {
		tiles = sprite_00_tiles
		size = SPRITE_SIZE_1_1
		frames = 1
	}

sprite_01:
	repeat (63) {
		sprite {}
	}
}
block (@bank = ram_system) {
sprite_next_vram_addr: ds.l 1
}

block (@bank = rom_code) {
.get_sprite_addr:
  ; d0 = object ID
  ; out a0 = object addr
  subi.l #1, d0
  mulu.w #sprite.$size, d0
  addi.l #sprites, d0
  movea.l d0, a0
  rts
reset_sprites:
	move.l #VDP_SPRITE_VRAM_ADDR, (sprite_next_vram_addr).l
	rts
sprite_size_to_tile_count:
	; d0 = sprite size
	; out d0 = tile count
	moveq #0, d1
	move.b d0, d1
	lsr.b #2, d0
	addi.b #1, d0
	andi.b #(0b11), d1
	addi.b #1, d1
	mulu.w d1, d0
	rts
sprite_load_id:
	; d0 = sprite id
	; out d0 = tile number
	jsr .get_sprite_addr
sprite_load_addr:
	movea.l a0,a1	; a1 = sprite addr
	movea.l (sprite.tiles,a1),a0	; a0 = source tiles
	move.b (sprite.frames,a1),d2	; d2 = frame count
	move.b (sprite.size,a1),d0	; d0 = sprite size
	andi.l #$ff, d0
	jsr sprite_size_to_tile_count	; d0 = tile count
	lsl.l #3, d0	; * 8
	mulu.w d2, d0	; multiply by frame count

	movea.l (sprite_next_vram_addr).l, a1	; a1 = dest addr (next free sprite vram spot)
	movea.l a1, a2	; copy to a2 forl ater
	; a0 = source addr
  	; a1 = dest addr
  	; d0 = count
	jsr vramcopy.l

	move.l a1, (sprite_next_vram_addr).l	; increase next vram addr

	move.l a2, d0
	lsr.l #5, d0				; d0 = tile index of original next vram addr

	rts
}

block (@bank = rom_data) {
sprite_00_tiles:
	dc.l $12345678
	dc.l $23456781
	dc.l $34567812
	dc.l $45678123
	dc.l $56781234
	dc.l $67812345
	dc.l $78123456
	dc.l $81234567
}
