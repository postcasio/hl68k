include "opcodes.as"

macro console_log (string) {
	dc.w OPCODE_CONSOLE_LOG
	dc.w string
}

macro load_map (map_id) {
	dc.w OPCODE_LOAD_MAP
	dc.w map_id
}

macro refresh_map () {
	dc.w OPCODE_REFRESH_MAP
}

macro rts () {
	dc.w OPCODE_RTS
}

macro titlescreen() {
	dc.w OPCODE_TITLESCREEN
}
