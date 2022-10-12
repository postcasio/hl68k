include "banks.as"
include "dsl.as"
include "../strings.as"

block script_header_block (@bank = rom_header) {
	dc.w init
}

block script_code_block (@bank = rom_code, @table = default_table) {
init:
	load_map $1
	refresh_map
	console_log .hello_world
	rts
.hello_world:
	dc.b "Hello, world!\n\0"
}
