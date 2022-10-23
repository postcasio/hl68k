include "constants.as"
include "banks.as"
include "dsl.as"
include "../strings.as"

block script_header_block (@bank = rom_header) {
	dc.w init
}

block script_code_block (@bank = rom_code, @table = default_table) {
init:
	map_load $1
	map_refresh
	console_log .hello_world
	party_init
	object_freeze $1
	object_create_party_char $1, $0
	object_set_visible $1
	object_thaw $1
	rts
.hello_world:
	dc.b "Hello, world!", NL, 0
}
