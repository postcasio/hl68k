macro handler (interrupt_id, interrupt_type) {
  movem.l d7-d0/a7-a0,-(sp)
  move.l interrupt_id, d1
  move.l interrupt_type, d0
  jmp int_end
}

macro output_register (str, stack_offset) {
  lea str, a0
  jsr console_write
  lea colon_str, a0
  jsr console_write
  move.l (stack_offset,sp),d0
  jsr to_hex_string
  jsr console_write
}

GROUP_1_OR_2_TYPE=2
BUS_OR_ADDRESS_TYPE=3

block interrupts (@bank = rom_code, @table = default_table) {
int_1: handler #1, #BUS_OR_ADDRESS_TYPE
int_2: handler #2, #BUS_OR_ADDRESS_TYPE
int_3: handler #3, #GROUP_1_OR_2_TYPE
int_4: handler #4, #GROUP_1_OR_2_TYPE
int_5: handler #5, #GROUP_1_OR_2_TYPE
int_6: handler #6, #GROUP_1_OR_2_TYPE
int_7: handler #7, #GROUP_1_OR_2_TYPE
int_8: handler #8, #GROUP_1_OR_2_TYPE
int_9: handler #9, #GROUP_1_OR_2_TYPE
int_10: handler #10, #GROUP_1_OR_2_TYPE
int_11: handler #11, #0
int_12: handler #12, #0
int_13: handler #13, #0
int_14: handler #14, #0
int_23: handler #23, #0
int_24: handler #24, #0
int_25: handler #25, #0
int_26: handler #26, #0
int_28: handler #28, #0
int_30: handler #30, #0
int_31: handler #31, #0
int_32: handler #32, #0
int_33: handler #33, #0
int_34: handler #34, #0
int_35: handler #35, #0
int_36: handler #36, #0
int_37: handler #37, #0
int_38: handler #38, #0
int_39: handler #39, #0
int_40: handler #40, #0
int_41: handler #41, #0
int_42: handler #42, #0
int_43: handler #43, #0
int_44: handler #44, #0
int_45: handler #45, #0
int_46: handler #46, #0
int_47: handler #47, #0
int_48: handler #48, #0
int_49: handler #49, #0
int_50: handler #50, #0
int_51: handler #51, #0
int_52: handler #52, #0
int_53: handler #53, #0
int_54: handler #54, #0
int_55: handler #55, #0
int_56: handler #56, #0
int_57: handler #57, #0
error: handler #0, #0

int_end:
  move.l d1,d2             ; copy error code -> d2
  move.l d0,d3             ; copy error type -> d3
  jsr console_nl
  lea .excl_icon, a0
  jsr console_write

  mulu #2,d2               ; mul 2
  add.l #.error_strings,d2 ; indexing error offsets
  movea.l d2,a1            ; error string offset address -> a1
  move.w (a1),d2           ; error string offset -> d2
  add.l #.error_strings,d2
  movea.l d2,a0            ; error string -> a0
  jsr console_write

  jsr console_nl
  jsr console_nl

  lea .reg_names,a3

  cmpi.b #BUS_OR_ADDRESS_TYPE, d3         ; is bus/address error
  beq .bus_or_address_ex
  cmpi.b #GROUP_1_OR_2_TYPE, d3
  beq .group_1_or_2_ex

  bra.s .output_registers

.group_1_or_2_ex:
  lea .reg_pc_name, a0
  jsr console_write

  move.l (66,sp),d0
  jsr to_hex_string
  jsr console_write

  jsr console_nl


.bus_or_address_ex:
  move.w (64,sp),d0
  move.w d0, d1
  andi.w #0b10000, d0
  bne .bus_or_address_ex_read
.bus_or_address_ex_write:
  lea .ex_write_failed,a0
  bra .bus_or_address_ex_pc
.bus_or_address_ex_read:
  lea .ex_read_failed,a0
.bus_or_address_ex_pc:
  jsr console_write
  jsr console_nl
  lea .reg_pc_name, a0
  jsr console_write

  move.l (74,sp),d0
  jsr to_hex_string
  jsr console_write

  lea .two_spaces,a0
  jsr console_write

  lea .reg_addr_name, a0
  jsr console_write

  move.l (66,sp),d0
  jsr to_hex_string
  jsr console_write
  jsr console_nl
  jsr console_nl

.output_registers:

  output_register (0,a3), 0   ; d0
  lea .spaces,a0
  jsr console_write
  output_register (24,a3), 32 ; a0
  jsr console_nl

  output_register (3,a3), 4   ; d1
  lea .spaces,a0
  jsr console_write
  output_register (27,a3), 36 ; a1
  jsr console_nl

  output_register (6,a3), 8   ; d2
  lea .spaces,a0
  jsr console_write
  output_register (30,a3), 40 ; a2
  jsr console_nl

  output_register (9,a3), 12  ; d3
  lea .spaces,a0
  jsr console_write
  output_register (33,a3), 44 ; a3
  jsr console_nl

  output_register (12,a3), 16 ; d4
  lea .spaces,a0
  jsr console_write
  output_register (36,a3), 48 ; a4
  jsr console_nl

  output_register (15,a3), 20 ; d5
  lea .spaces,a0
  jsr console_write
  output_register (39,a3), 52 ; a5
  jsr console_nl

  output_register (18,a3), 24 ; d6
  lea .spaces,a0
  jsr console_write
  output_register (42,a3), 56 ; a6
  jsr console_nl

  output_register (21,a3), 28 ; d7
  lea .spaces,a0
  jsr console_write
  output_register (45,a3), 60 ; a7
  jsr console_nl

.forever:
  bra.s .forever

.excl_icon: dc.b "[!] ", 0
.ex_read_failed: dc.b "Read failed\n\n",0
.ex_write_failed: dc.b "Write failed\n\n",0
.reg_addr_name: dc.b "ADDR: ", 0
.reg_pc_name: dc.b "PC: ", 0
.spaces: dc.b "  "
.two_spaces: dc.b "  ", 0
.reg_names:   dc.b "d0", $0, "d1", $0, "d2", $0, "d3", $0
              dc.b "d4", $0, "d5", $0, "d6", $0, "d7", $0
.reg_names_a: dc.b "a0", $0, "a1", $0, "a2", $0, "a3", $0
              dc.b "a4", $0, "a5", $0, "a6", $0, "a7", $0

colon_str: dc.b ": ", 0
newline_str: dc.b "\n", 0
.align 2
.error_strings:
  dc.w $0000
  dc.w .bus_error-.error_strings
  dc.w .address_error-.error_strings
  dc.w .illegal_instruction-.error_strings
  dc.w .division_by_zero-.error_strings
  dc.w .chk_exception-.error_strings
  dc.w .trapv_exception-.error_strings
  dc.w .privilege_violation-.error_strings
  dc.w .trace_exception-.error_strings
  dc.w .line_a_emulator-.error_strings
  dc.w .line_f_emulator-.error_strings
  dc.w $0000
  dc.w .coprocessor_protocol_violation-.error_strings
  dc.w .format_error-.error_strings
  dc.w .unitialized_interrupt-.error_strings
  dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
  dc.w .spurious_interrupt-.error_strings
  dc.w .irq_level_1-.error_strings
  dc.w .irq_level_2-.error_strings
  dc.w .irq_level_3-.error_strings
  dc.w $0000
  dc.w .irq_level_5-.error_strings
  dc.w $0000
  dc.w .irq_level_7-.error_strings
  dc.w .trap_00_exception-.error_strings
  dc.w .trap_01_exception-.error_strings
  dc.w .trap_02_exception-.error_strings
  dc.w .trap_03_exception-.error_strings
  dc.w .trap_04_exception-.error_strings
  dc.w .trap_05_exception-.error_strings
  dc.w .trap_06_exception-.error_strings
  dc.w .trap_07_exception-.error_strings
  dc.w .trap_08_exception-.error_strings
  dc.w .trap_09_exception-.error_strings
  dc.w .trap_10_exception-.error_strings
  dc.w .trap_11_exception-.error_strings
  dc.w .trap_12_exception-.error_strings
  dc.w .trap_13_exception-.error_strings
  dc.w .trap_14_exception-.error_strings
  dc.w .trap_15_exception-.error_strings
  dc.w .fp_branch_or_set_on_unordered_condition-.error_strings
  dc.w .fp_inexact_result-.error_strings
  dc.w .fp_divide_by_zero-.error_strings
  dc.w .fp_underflow-.error_strings
  dc.w .fp_operand_error-.error_strings
  dc.w .fp_overflow-.error_strings
  dc.w .fp_signaling_nan-.error_strings
  dc.w .fp_unimplemented_data_type-.error_strings
  dc.w .mmu_configuration_error-.error_strings
  dc.w .mmu_illegal_operation_error-.error_strings
  dc.w .mmu_access_violation_error-.error_strings
  dc.w $0000, $0000, $0000, $0000, $0000


.bus_error:           dc.b "BUS ERROR\0"
.address_error:       dc.b "ADDRESS ERROR\0"
.illegal_instruction: dc.b "ILLEGAL INSTRUCTION\0"
.division_by_zero:    dc.b "DIVISION BY ZERO\0"
.chk_exception:       dc.b "CHK EXCEPTION\0"
.trapv_exception:     dc.b "TRAPV EXCEPTION\0"
.privilege_violation: dc.b "PRIVILEGE VIOLATION\0"
.trace_exception:     dc.b "TRACE EXCEPTION\0"
.line_a_emulator:     dc.b "LINE-A EMULATOR\0"
.line_f_emulator:     dc.b "LINE-F EMULATOR\0"
.coprocessor_protocol_violation: dc.b "COPROCESSOR PROTOCOL VIOLATION\0"
.format_error:        dc.b "FORMAT ERROR\0"
.unitialized_interrupt:dc.b "UNINITIALIZED INTERRUPT\0"
.spurious_interrupt:  dc.b "SPURIOUS INTERRUPT\0"
.irq_level_1:         dc.b "IRQ LEVEL 1\0"
.irq_level_2:         dc.b "IRQ LEVEL 2 EXT INTERRUPT\0"
.irq_level_3:         dc.b "IRQ LEVEL 3\0"
.irq_level_5:         dc.b "IRQ LEVEL 5\0"
.irq_level_7:         dc.b "IRQ LEVEL 7\0"
.trap_00_exception:   dc.b "TRAP #00 EXCEPTION\0"
.trap_01_exception:   dc.b "TRAP #01 EXCEPTION\0"
.trap_02_exception:   dc.b "TRAP #02 EXCEPTION\0"
.trap_03_exception:   dc.b "TRAP #03 EXCEPTION\0"
.trap_04_exception:   dc.b "TRAP #04 EXCEPTION\0"
.trap_05_exception:   dc.b "TRAP #05 EXCEPTION\0"
.trap_06_exception:   dc.b "TRAP #06 EXCEPTION\0"
.trap_07_exception:   dc.b "TRAP #07 EXCEPTION\0"
.trap_08_exception:   dc.b "TRAP #08 EXCEPTION\0"
.trap_09_exception:   dc.b "TRAP #09 EXCEPTION\0"
.trap_10_exception:   dc.b "TRAP #10 EXCEPTION\0"
.trap_11_exception:   dc.b "TRAP #11 EXCEPTION\0"
.trap_12_exception:   dc.b "TRAP #12 EXCEPTION\0"
.trap_13_exception:   dc.b "TRAP #13 EXCEPTION\0"
.trap_14_exception:   dc.b "TRAP #14 EXCEPTION\0"
.trap_15_exception:   dc.b "TRAP #15 EXCEPTION\0"
.fp_branch_or_set_on_unordered_condition: dc.b "FP BRANCH OR SET ON UNORDERED CONDITION\0"
.fp_inexact_result:    dc.b "FP INEXACT RESULT\0"
.fp_divide_by_zero:    dc.b "FP DIVIDE BY ZERO\0"
.fp_underflow:         dc.b "FP UNDERFLOW\0"
.fp_operand_error:     dc.b "FP OPERAND ERROR\0"
.fp_overflow:          dc.b "FP OVERFLOW\0"
.fp_signaling_nan:     dc.b "FP SIGNALING NAN\0"
.fp_unimplemented_data_type: dc.b "FP UNIMPLEMENTED DATA TYPE\0"
.mmu_configuration_error: dc.b "MMU CONFIGURATION ERROR\0"
.mmu_illegal_operation_error: dc.b "MMU ILLEGAL OPERATION ERROR\0"
.mmu_access_violation_error: dc.b "MMU ACCESS VIOLATION ERROR\0"

}
