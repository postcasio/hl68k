include "../opcodes.as"

struct script_state {
	word script_pc
	word script_pc_lo
	word script_sp
	word script_sp_lo
	byte script_waiting
	byte script_finished
	word script_stack[$100]
}

block interpreter_ram (@bank = ram_system, @align = 16) {
	global_script: script_state {}
	global_script_end:
}

block interpreter_code (@bank = rom_code, @align = 8) {
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
	lea script_mark_finished_str,a0
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
	move.l (script_state.script_pc, a0), d0
script_get_next_word:
	; a0 = script states
	movea.l (script_state.script_pc, a0), a1
	move.w (a1),d0
	addi.l #2, (script_state.script_pc, a0)
	rts

script_execute_next:
	; a0 = script state
	jsr script_get_next_word
	jsr script_execute_instruction
	rts

script_execute_instruction:
	; a0 = script state
	; d0 = instruction
	cmpi.w #OPCODE_CONSOLE_LOG, d0
	beq.w .script_instruction_console_log
	cmpi.w #OPCODE_LOAD_MAP, d0
	beq.w .script_instruction_load_map
	cmpi.w #OPCODE_REFRESH_MAP, d0
	beq.w .script_instruction_refresh_map
	cmpi.w #OPCODE_RTS, d0
	beq.w .script_instruction_rts

.script_error:
	lea script_error_text,a0
	jsr console_write
	rts

.script_instruction_console_log:
	; a0 = script state
	jsr script_get_next_word_addr
	movea.l d0,a0
	jsr console_write

	rts

.script_instruction_load_map:
	; a0 = script state
	jsr script_get_next_word
	; d0 = map id
	jsr load_map_id
	rts
.script_instruction_refresh_map:
	jsr refresh_map
	rts
.script_instruction_rts:
	jsr script_pull_long
	tst.l d0
	beq.w script_mark_finished
	move.l d0, (script_state.script_pc, a0)
	rts
.script_instruction_titlescreen:
	jsr mark_script_waiting
	jsr setup_titlescreen
	rts
}

block script_string_data (@bank = rom_code, @table = default_table) {
script_error_text: dc.b "SCRIPT ERROR!\n\0"
script_mark_finished_str: dc.b "SCRIPT FINISHED\n", 0
script_mark_waiting_str: dc.b "SCRIPT WAITING\n", 0
}

block script_data (@bank = rom_script, @align = $10000) {
script_bank:
	.incbin "../script.bin"
}
