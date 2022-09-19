block boot (@bank = rom_code) {

__entry:
    tst.l CONTROLLER1_CTRL
    bne.s skipJoyDetect
    tst.w EXPANSION_CTRL
skipJoyDetect:
    bne.s skipSetup

    lea table,a5
    movem.w (a5)+,d5-d7
    movem.l (a5)+,a0-a4

    ; check version number
    move.b  (-$10ff,a1),d0
    andi.b  #$0f,d0
	beq.s   versionOK
    ; write magic word
    move.l  #"SEGA",($2f00,a1)
versionOK:
    ; read from control port to cancel pending read/writes
    move.w  (a4),d0

    ; configure a USER_STACK_LENGTH bytes user stack at bottom, and system stack on top of it
    move.l    sp, usp
    suba.l   #USER_STACK_LENGTH, sp

    move.w  d7,(a1)
    move.w  d7,(a2)

    ;jmp start
skipSetup:
    ;jmp reset

table:
    ; initial values for d5-d7
    dc.w    $8000, $3fff, $0100
    ; initial values for a0-a4
    dc.l    Z80_RAM, Z80_BUS, Z80_RESET, VDP_DATA, VDP_CONTROL
}
