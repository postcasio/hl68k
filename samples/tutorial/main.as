include "settings.as"
include "constants.as"
include "vdp.as"
include "banks.as"
include "header.as"
include "boot.as"

block (@bank = rom_code) {

reset:
start:
    nop
    nop
    bra end

}
