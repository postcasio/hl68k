include "../script/opcodes.as"

struct script_state {
	long script_pc
	;word script_pc_lo
	long script_sp
	;word script_sp_lo
	byte script_waiting
	byte script_finished
	word script_stack[$100]
}

block interpreter_ram (@bank = ram_system, @align = 16) {
	global_script: script_state {}
	global_script_end:
}

block interpreter_code (@bank = rom_code, @align = 8, @table = default_table) {
script_init:
	lea script_bank, a0
	move.l #script_bank, d0
	add.w (a0), d0
	movea.l d0, a1
	lea global_script, a0
	move.l #global_script_end, (script_state.script_sp,a0)
	jsr script_call_subroutine
	rts

script_push_long:
	; a0 = script state
	; d0 = long
	subi.l #4, (script_state.script_sp, a0)
	movea.l (script_state.script_sp, a0), a1
	move.l d0, (a1)
	rts

script_push_word:
	; a0 = script state
	; d0 = long
	subi.l #2, (script_state.script_sp, a0)
	movea.l (script_state.script_sp, a0), a1
	move.w d0, (a1)
	rts

script_pull_long:
	movea.l (script_state.script_sp, a0), a1
	move.l (a1), d0
	addi.l #4, (script_state.script_sp, a0)
	rts

script_pull_word:
	movea.l (script_state.script_sp, a0), a1
	move.w (a1), d0
	addi.l #2, (script_state.script_sp, a0)
	rts

script_call_subroutine:
	; a0 = script state
	; a1 = subroutine address
	move.l (script_state.script_pc,a0), d0
	pusha.l a1
	jsr script_push_long
	popa.l a1
	move.l a1, (script_state.script_pc, a0)
	rts

script_mark_finished:
	; a0 = script state
	pusha.l a0
	move.b #1, (script_state.script_finished, a0)
	lea .script_mark_finished_str,a0
	jsr console_write
	popa.l a0
script_mark_waiting:
	move.b #1, (script_state.script_waiting, a0)
	rts

script_run:
	; a0 = script state
	cmpi.b #1,(script_state.script_waiting, a0)
	beq .script_dont_run
	pusha.l a0
	jsr script_execute_next
	popa.l a0
	bra script_run
.script_dont_run:
	rts


script_get_next_word_addr:
	move.w (script_state.script_pc, a0), d0
	moveq #16,d1
	lsl.l d1,d0
	bra.s .script_get_next_word_2
script_get_next_word:
	; a0 = script states
	moveq #0,d0
.script_get_next_word_2:
	movea.l (script_state.script_pc, a0), a1
	move.b (a1)+,d0
	lsl.w #8,d0
	or.b (a1)+,d0
	move.l a1, (script_state.script_pc, a0)

	rts

script_get_next_byte:
	moveq #0, d0
	movea.l (script_state.script_pc, a0), a1
	move.b (a1)+,d0
	move.l a1, (script_state.script_pc, a0)
	rts

script_execute_next:
	; a0 = script state
	jsr script_get_next_word
	jsr script_execute_instruction
	rts

script_execute_instruction:
	; a0 = script state
	; d0 = instruction
	move.l (script_state.script_pc, a0), d1	; d1 = pc
	subi.l #2, d1

	cmpi.w #OPCODE_CONSOLE_LOG, d0
	beq.w .script_instruction_console_log
	cmpi.w #OPCODE_MAP_LOAD, d0
	beq.w .script_instruction_map_load
	cmpi.w #OPCODE_MAP_REFRESH, d0
	beq.w .script_instruction_map_refresh
	cmpi.w #OPCODE_RTS, d0
	beq.w .script_instruction_rts
	cmpi.w #OPCODE_PARTY_INIT, d0
	beq.w .script_instruction_party_init
	cmpi.w #OPCODE_OBJECT_CREATE_PARTY_CHAR, d0
	beq.w .script_instruction_object_create_party_char
	cmpi.w #OPCODE_OBJECT_CREATE_CHAR, d0
	beq.w .script_instruction_object_create_char
	cmpi.w #OPCODE_OBJECT_SET_VISIBLE, d0
	beq.w .script_instruction_object_set_visible
	cmpi.w #OPCODE_OBJECT_FREEZE, d0
	beq.w .script_instruction_object_freeze
	cmpi.w #OPCODE_OBJECT_THAW, d0
	beq.w .script_instruction_object_thaw

.script_error:
	push.l d1
	push.l d0
	lea .script_error_str,a0
	jsr console_write
	lea .script_error_unknown_instruction_str,a0
	jsr console_write
	pop.l d0
	jsr to_hex_string
	jsr console_write
	lea .script_error_at_str, a0
	jsr console_write

	pop.l d0
	jsr to_hex_string
	jsr console_write
	jsr console_nl
	rts

.script_instruction_console_log:
	; a0 = script state
	jsr script_get_next_word_addr
	movea.l d0,a0
	jsr console_write
	rts

.script_instruction_map_load:
	; a0 = script state
	jsr script_get_next_word
	; d0 = map id
	jmp map_load_id
.script_instruction_map_refresh:
	jmp refresh_map
.script_instruction_rts:
	jsr script_pull_long
	tst.l d0
	beq.w script_mark_finished
	move.l d0, (script_state.script_pc, a0)
	rts
.script_instruction_titlescreen:
	jsr script_mark_waiting
	jmp titlescreen_start
.script_instruction_party_init:
	jmp party_init
.script_instruction_object_create_party_char:
	jsr script_get_next_byte ; object ID
	push.l d0
	push.l a0
	jsr party_get_current
	movea.l a0, a1
	popa.l a0
	jsr script_get_next_byte ; character ID
	movea.l a1, a0
	jsr party_get_character
	move.l d0, d1
	pop.l d0
	jmp object_create_char
.script_instruction_object_create_char:
	jsr script_get_next_byte
	jmp object_create_char
.script_instruction_object_set_visible:
	jsr script_get_next_byte
	jmp object_set_visible
.script_instruction_object_freeze:
	jsr script_get_next_byte
	jmp object_freeze
.script_instruction_object_thaw:
	jsr script_get_next_byte
	jmp object_thaw

.script_error_str: dc.b "Script error!", NL, 0
.script_mark_finished_str: dc.b "Script finished", NL, 0
.script_mark_waiting_str: dc.b "Script waiting", NL, 0
.script_error_unknown_instruction_str: dc.b "Unknown instruction ", 0
.script_error_at_str: dc.b " @ ", 0
}

block script_data (@bank = rom_script, @align = $10000) {
script_bank:
	.incbin "../script/script.bin"
}
