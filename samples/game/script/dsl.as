include "opcodes.as"

macro console_log (string) {
	dc.w OPCODE_CONSOLE_LOG
	dc.w string
}

macro map_load (map_id) {
	dc.w OPCODE_MAP_LOAD
	dc.w map_id
}

macro map_refresh () {
	dc.w OPCODE_MAP_REFRESH
}

macro rts () {
	dc.w OPCODE_RTS
}

macro titlescreen() {
	dc.w OPCODE_TITLESCREEN
}

macro party_init() {
	dc.w OPCODE_PARTY_INIT
}

macro object_create_party_char(object_id, party_char_id) {
	dc.w OPCODE_OBJECT_CREATE_PARTY_CHAR
	dc.b object_id
	dc.b party_char_id
}

macro object_create_char(object_id, char_id) {
	dc.w OPCODE_OBJECT_CREATE_CHAR
	dc.b object_id
	dc.b char_id
}

macro object_set_visible(object_id) {
	dc.w OPCODE_OBJECT_SET_VISIBLE
	dc.b object_id
}

macro object_freeze(object_id) {
	dc.w OPCODE_OBJECT_FREEZE
	dc.b object_id
}

macro object_thaw(object_id) {
	dc.w OPCODE_OBJECT_THAW
	dc.b object_id
}
