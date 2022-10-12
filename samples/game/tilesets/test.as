block tileset_data (@bank = rom_data, @align = 8) {
tileset_test:
	tileset_header (.end - .start) / 32, .start
.start:
	dc.l $01010101
	dc.l $10101010
	dc.l $01010101
	dc.l $10101010
	dc.l $01010101
	dc.l $10101010
	dc.l $01010101
	dc.l $10101010

	dc.l $12121212
	dc.l $21212121
	dc.l $12121212
	dc.l $21212121
	dc.l $12121212
	dc.l $21212121
	dc.l $12121212
	dc.l $21212121

	dc.l $22222222
	dc.l $22222222
	dc.l $22222222
	dc.l $22222222
	dc.l $22222222
	dc.l $22222222
	dc.l $22222222
	dc.l $22222222

	dc.l $33443344
	dc.l $33443344
	dc.l $44334433
	dc.l $44334433
	dc.l $33443344
	dc.l $33443344
	dc.l $44334433
	dc.l $44334433

	dc.l $44444444
	dc.l $44444444
	dc.l $44444444
	dc.l $44444444
	dc.l $44444444
	dc.l $44444444
	dc.l $44444444
	dc.l $44444444

	dc.l $55555555
	dc.l $55555555
	dc.l $55555555
	dc.l $55555555
	dc.l $55555555
	dc.l $55555555
	dc.l $55555555
	dc.l $55555555

	dc.l $66666666
	dc.l $66666666
	dc.l $66666666
	dc.l $66666666
	dc.l $66666666
	dc.l $66666666
	dc.l $66666666
	dc.l $66666666

	dc.l $77777777
	dc.l $77777777
	dc.l $77777777
	dc.l $77777777
	dc.l $77777777
	dc.l $77777777
	dc.l $77777777
	dc.l $77777777

	dc.l $88888888
	dc.l $88888888
	dc.l $88888888
	dc.l $88888888
	dc.l $88888888
	dc.l $88888888
	dc.l $88888888
	dc.l $88888888

	dc.l $99999999
	dc.l $99999999
	dc.l $99999999
	dc.l $99999999
	dc.l $99999999
	dc.l $99999999
	dc.l $99999999
	dc.l $99999999

	dc.l $AAAAAAAA
	dc.l $AAAAAAAA
	dc.l $AAAAAAAA
	dc.l $AAAAAAAA
	dc.l $AAAAAAAA
	dc.l $AAAAAAAA
	dc.l $AAAAAAAA
	dc.l $AAAAAAAA

	dc.l $BBBBBBBB
	dc.l $BBBBBBBB
	dc.l $BBBBBBBB
	dc.l $BBBBBBBB
	dc.l $BBBBBBBB
	dc.l $BBBBBBBB
	dc.l $BBBBBBBB
	dc.l $BBBBBBBB

	dc.l $CCCCCCCC
	dc.l $CCCCCCCC
	dc.l $CCCCCCCC
	dc.l $CCCCCCCC
	dc.l $CCCCCCCC
	dc.l $CCCCCCCC
	dc.l $CCCCCCCC
	dc.l $CCCCCCCC

	dc.l $DDDDDDDD
	dc.l $DDDDDDDD
	dc.l $DDDDDDDD
	dc.l $DDDDDDDD
	dc.l $DDDDDDDD
	dc.l $DDDDDDDD
	dc.l $DDDDDDDD
	dc.l $DDDDDDDD

	dc.l $EEEEEEEE
	dc.l $EEEEEEEE
	dc.l $EEEEEEEE
	dc.l $EEEEEEEE
	dc.l $EEEEEEEE
	dc.l $EEEEEEEE
	dc.l $EEEEEEEE
	dc.l $EEEEEEEE

	dc.l $FFFFFFFF
	dc.l $FFFFFFFF
	dc.l $FFFFFFFF
	dc.l $FFFFFFFF
	dc.l $FFFFFFFF
	dc.l $FFFFFFFF
	dc.l $FFFFFFFF
	dc.l $FFFFFFFF
.end:
}
