include "settings.as"
include "constants.as"
include "strings.as"
include "banks.as"
include "interrupts.as"
include "header.as"
include "boot.as"
include "utils.as"
include "vdp.as"
include "console.as"
include "palettes.as"
include "tiles.as"
include "tilesets/font.as"
include "tilesets/test.as"
include "sprites.as"
include "interpreter/main.as"
include "map/main.as"
include "maps/main.as"
include "characters.as"
include "game.as"
include "titlescreen.as"

block main_code (@bank = rom_code, @align = 8, @table = default_table) {

reset:
start:
    lea .table,a6
    movem.l (a6)+,d0-d7
    movem.l (a6)+,a0-a5
    lea 0,a6

    jsr vdp_init

    vdp_lea
    vdp_write_reg_imm VDP_REG_AUTOINCREMENT, #2
    vdp_write_reg_imm VDP_REG_BGCOLOR, #0

    jsr reset_sprites
    jsr console_init

    lea palette_system,a0
    move.l #$0, d0
    jsr load_palette

    lea font,a0
    lea ($0),a1
    jsr load_tileset

    lea tileset_test,a0
    lea ($1000),a1
    jsr load_tileset

    lea .strings,a0
    jsr console_write

    move #$2000, sr

    jsr script_init

    lea global_script, a0
    jsr script_run

game_loop:
    jsr objects_update
    jsr vdp_vblank_wait_start
    jsr objects_copy_to_vram
    bra.s game_loop


    move.l ($99999999).l,d0

.end:
    loop_forever

hblank:
    rte
vblank:
    rte

.align 4
.strings:
    dc.b "Testing console", NL, 0

.align 4
.table:
    dc.l    0, 0, 0, 0, 0, 0, 0, 0
    dc.l    0, 0, 0, 0, 0, 0

}
