block vectors (@bank = rom_header) {
	dc.l #$0000 ; SP
	dc.l __entry  ; Start address

	dc.l int_1    ; Bus error
	dc.l int_2    ; Address error
	dc.l int_3    ; Illegal instruction
	dc.l int_4    ; Division by zero
	dc.l int_5    ; CHK exception
	dc.l int_6    ; TRAPV exception
	dc.l int_7    ; Privilage violation
	dc.l int_8    ; TRACE exception
	dc.l int_9    ; Line-A emulator
	dc.l int_10    ; Line-F emulator
	dc.l int_11    ; Reserved (NOT USED)
	dc.l int_12    ; Co-processor protocol violation
	dc.l int_13    ; Format error
	dc.l int_14    ; Uninitialized interrupt
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l int_23    ; Spurious interrupt
	dc.l int_24    ; IRQ Level 1
	dc.l int_25    ; IRQ Level 2 (EXT interrupt)
	dc.l int_26    ; IRQ Level 3
	dc.l hblank   ; IRQ Level 4 (VDP Horizontal interrupt)
	dc.l int_28    ; IRQ Level 5
	dc.l vblank   ; IRQ Level 6 (VDP Vertical interrupt)
	dc.l int_30    ; IRQ Level 7
	dc.l int_31    ; TRAP #00 Exception
	dc.l int_32    ; TRAP #01 Exception
	dc.l int_33    ; TRAP #02 Exception
	dc.l int_34    ; TRAP #03 Exception
	dc.l int_35    ; TRAP #04 Exception
	dc.l int_36    ; TRAP #05 Exception
	dc.l int_37    ; TRAP #06 Exception
	dc.l int_38    ; TRAP #07 Exception
	dc.l int_39    ; TRAP #08 Exception
	dc.l int_40    ; TRAP #09 Exception
	dc.l int_41    ; TRAP #10 Exception
	dc.l int_42    ; TRAP #11 Exception
	dc.l int_43    ; TRAP #12 Exception
	dc.l int_44    ; TRAP #13 Exception
	dc.l int_45    ; TRAP #14 Exception
	dc.l int_46    ; TRAP #15 Exception
	dc.l int_47    ; (FP) Branch or Set on Unordered Condition
	dc.l int_48    ; (FP) Inexact Result
	dc.l int_49    ; (FP) Divide by Zero
	dc.l int_50    ; (FP) Underflow
	dc.l int_51    ; (FP) Operand Error
	dc.l int_52    ; (FP) Overflow
	dc.l int_53    ; (FP) Signaling NAN
	dc.l int_54    ; (FP) Unimplemented Data Type
	dc.l int_55    ; MMU Configuration Error
	dc.l int_56    ; MMU Illegal Operation Error
	dc.l int_57    ; MMU Access Violation Error
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
}

block header (@bank = rom_header) {
	dc.b "SEGA MEGA DRIVE "                                 ; console name
	dc.b "(C)SEGA 1993.NOV"                                 ; copyright
	dc.b "SAMPLE THE            HEDGEHOG 3                " ; domestic name
	dc.b "SAMPLE THE            HEDGEHOG 3                " ; overseas name
	dc.b "GM 00000000-00"                                   ; serial
	dc.w $0000                                             ; checksum
	dc.b "JD              "                                 ; io support (todo: find bit meanings)
	dc.l start                                              ; start address
	dc.l rom_code.end                                       ; end address
	dc.l $00FF0000                                         ; start of SRAM
	dc.l $00FFFFFF                                         ; end of SRAM
	dc.b "                        "                         ; modem support (todo: find bit meanings)
	dc.b "                                        "         ; memo
	dc.b "JUE             "                                 ; region support
}
