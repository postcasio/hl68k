OBJECT_EXISTS=0b0000_0001
OBJECT_EXISTS_BIT=1
OBJECT_VISIBLE=0b0000_0010
OBJECT_DIRTY=0b0000_0100
OBJECT_DIRTY_BIT=2
OBJECT_FREEZE=0b0000_1000
OBJECT_FREEZE_BIT=3
OBJECT_VERT_FLIP=0b0001_0000_0000_0000
OBJECT_HORIZ_FLIP=0b0000_1000_0000_0000
OBJECT_PRIORITY=0b1000_0000_0000_0000

MAX_SPRITE_COUNT=32
struct map_object {
  byte x
  byte xp
  byte y
  byte yp
  word flags
  byte palette
  byte sprite_id
  word tile_number
}

struct sprite_table_entry {
  word y
  byte size ; 0b0000_hhvv
            ; h,v = horiz/vert size
  byte next

  word tile_data  ; 0bPppvhGGG_GGGGGGGG
                  ; P = priority, p = palette
                  ; v, h = vert/horiz flip
                  ; G = tile number (vram addr / $20)
  word x
}

SPRITE_TABLE_MAX_SIZE = (sprite_table_end - sprite_table)

block (@bank = ram_system, @align = $400) {
map_objects:
  repeat (MAX_SPRITE_COUNT) {
    map_object {}
  }
.align $100
sprite_table:
  repeat (MAX_SPRITE_COUNT) {
    sprite_table_entry {}
  }
sprite_table_end:
}

macro obj_set_flags(value) {
  move.w (map_object.flags,a0), d0
  ori.w value, d0
  move.w d0, (map_object.flags,a0)
}

macro obj_clear_flags(value) {
  move.w (map_object.flags,a0), d0
  andi.w #~(value), d0
  move.w d0, (map_object.flags,a0)
}

block (@bank = rom_code) {
.get_object_addr:
  ; d0 = object ID
  ; out a0 = object addr
  subi.l #1, d0
  mulu.w #map_object.$size, d0
  addi.l #map_objects, d0
  movea.l d0, a0
  rts
object_create_char:
  ; d0 = object ID
  ; d1 = character ID
  jsr .get_object_addr  ; -> a0
object_create_char_addr:
  ; a0 = object addr
  pusha.l a2
  movea.l a0, a2
  move.l d1, d0
  jsr get_character_addr
  movea.l a0, a1  ; a1 = char addr
  movea.l a2, a0  ; a0 = object addr
  moveq #0, d0

  move.b (character.sprite_id, a1), d0
  move.b d0, (map_object.sprite_id, a0)
  jsr sprite_load_id ; d0 = sprite tile number
  movea.l a2, a0
  move.w d0, (map_object.tile_number, a0)

  obj_set_flags #(OBJECT_DIRTY | OBJECT_EXISTS)
  popa.l a2
  rts
object_set_visible:
  ; d0 = object ID
  jsr .get_object_addr  ; -> a0
object_set_visible_addr:
  obj_set_flags #(OBJECT_VISIBLE | OBJECT_DIRTY)
  rts
object_freeze:
  ; d0 = object ID
  jsr .get_object_addr  ; -> a0
object_freeze_addr:
  obj_set_flags #(OBJECT_FREEZE | OBJECT_DIRTY)
  rts
object_thaw:
  ; d0 = object ID
  jsr .get_object_addr  ; -> a0
object_thaw_addr:
  obj_clear_flags #(OBJECT_FREEZE)
  rts
objects_update:
  moveq #0, d0  ; index into map_objects
  moveq #0, d1  ; index into sprite_table
  lea map_objects, a0
  lea sprite_table, a1
  push.l d2
  push.l d3
  push.l d4
  push.l d5
  pusha.l a2

  moveq #MAX_SPRITE_COUNT-1, d2 ; sprite count
  moveq #0,d5  ; current sprite number
  lea (sprite_table_entry.next,a1,d1.w),a2 ; load first sprites next field

.objects_update__copy:
  move.w (map_object.flags,a0,d0.w),d3
  btst #OBJECT_EXISTS_BIT, d3
  beq.s .objects_update__skip
  btst #OBJECT_FREEZE_BIT, d3
  bne.s .objects_update__continue ; if freeze flag is set, continue
  btst #OBJECT_DIRTY_BIT, d3
  beq.s .objects_update__continue ; if dirty flag is not set, continue
  move.w (map_object.x,a0,d0.w),(sprite_table_entry.x,a1,d1.w) ; copy x
  move.w (map_object.y,a0,d0.w),(sprite_table_entry.y,a1,d1.w) ; copy y

  move.w (map_object.tile_number,a0,d0.w), d3
  move.w (map_object.flags,a0,d0.w), d4
  andi.w #(OBJECT_HORIZ_FLIP | OBJECT_VERT_FLIP | OBJECT_PRIORITY), d4
  or.w d4, d3
  move.w (map_object.palette,a0,d0.w), d4  ; palette is a byte but we load as a word
  lsl.b #5, d4                             ; so we only need to shift 5 bits
  andi.w #0b0110_0000_0000_0000, d4        ; and then mask out extra bits
  or.b d4, d3     ; d3 now contains tile data
  move.w d3,(sprite_table_entry.tile_data,a1,d1.w)

.objects_update__continue:
  tst.b d5  ; if this isnt the first sprite
  beq .objects_update__skip

  move.b d5,(a2)  ; put current sprite number into next field of last sprite
  lea (sprite_table_entry.next,a1,d1.w),a2 ; load this sprites next field

.objects_update__skip:
  addi.b #1,d5  ; increment sprite number

  addi.l #(sprite_table_entry.$size), d1
  addi.l #(map_object.$size), d0
  dbf d2, .objects_update__copy

  move.b #0,(a2)
  popa.l a2
  pop.l d5
  pop.l d4
  pop.l d3
  pop.l d2
  rts
objects_copy_to_vram:
  lea sprite_table, a0
  lea (VDP_SPRITE_VRAM_ADDR).l, a1
  move.l #(SPRITE_TABLE_MAX_SIZE / 4), d0
  jsr vramcopy.l
  rts
}
