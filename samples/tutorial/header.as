block vectors (@bank = rom_header) {
	dc.l #$0000 ; SP
	dc.l __entry  ; Start address

	dc.l error    ; Bus error
	dc.l error    ; Address error
	dc.l error    ; Illegal instruction
	dc.l error    ; Division by zero
	dc.l error    ; CHK exception
	dc.l error    ; TRAPV exception
	dc.l error    ; Privilage violation
	dc.l error    ; TRACE exception
	dc.l error    ; Line-A emulator
	dc.l error    ; Line-F emulator
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Co-processor protocol violation
	dc.l error    ; Format error
	dc.l error    ; Uninitialized interrupt
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Spurious interrupt
	dc.l error    ; IRQ Level 1
	dc.l error    ; IRQ Level 2 (EXT interrupt)
	dc.l error    ; IRQ Level 3
	dc.l hblank   ; IRQ Level 4 (VDP Horizontal interrupt)
	dc.l error    ; IRQ Level 5
	dc.l vblank   ; IRQ Level 6 (VDP Vertical interrupt)
	dc.l error    ; IRQ Level 7
	dc.l error    ; TRAP #00 Exception
	dc.l error    ; TRAP #01 Exception
	dc.l error    ; TRAP #02 Exception
	dc.l error    ; TRAP #03 Exception
	dc.l error    ; TRAP #04 Exception
	dc.l error    ; TRAP #05 Exception
	dc.l error    ; TRAP #06 Exception
	dc.l error    ; TRAP #07 Exception
	dc.l error    ; TRAP #08 Exception
	dc.l error    ; TRAP #09 Exception
	dc.l error    ; TRAP #10 Exception
	dc.l error    ; TRAP #11 Exception
	dc.l error    ; TRAP #12 Exception
	dc.l error    ; TRAP #13 Exception
	dc.l error    ; TRAP #14 Exception
	dc.l error    ; TRAP #15 Exception
	dc.l error    ; (FP) Branch or Set on Unordered Condition
	dc.l error    ; (FP) Inexact Result
	dc.l error    ; (FP) Divide by Zero
	dc.l error    ; (FP) Underflow
	dc.l error    ; (FP) Operand Error
	dc.l error    ; (FP) Overflow
	dc.l error    ; (FP) Signaling NAN
	dc.l error    ; (FP) Unimplemented Data Type
	dc.l error    ; MMU Configuration Error
	dc.l error    ; MMU Illegal Operation Error
	dc.l error    ; MMU Access Violation Error
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
	dc.l error    ; Reserved (NOT USED)
}

block header (@bank = rom_header) {
	dc.b "SEGA MEGA DRIVE "                                 ; console name
	dc.b "(C)SEGA 1993.NOV"                                 ; copyright
	dc.b "SONIC THE             HEDGEHOG 3                " ; domestic name
	dc.b "SONIC THE             HEDGEHOG 3                " ; overseas name
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
