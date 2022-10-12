block font_data (@bank = rom_data, @align = 8) {
font:
	tileset_header (font.end - font.letters.null) / 32, font.letters.null
font.letters.null:
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
font.letters.1:
	dc.l $00000100
	dc.l $00011120
	dc.l $00002120
	dc.l $00000120
	dc.l $00000120
	dc.l $00000120
	dc.l $00000120
	dc.l $00000020
font.letters.2:
	dc.l $01111100
	dc.l $12222210
	dc.l $00000012
	dc.l $01111122
	dc.l $12222220
	dc.l $12000000
	dc.l $11111110
	dc.l $02222222
font.letters.3:
	dc.l $11111100
	dc.l $02222210
	dc.l $00000012
	dc.l $00111122
	dc.l $00022212
	dc.l $00000012
	dc.l $11111122
	dc.l $02222220
font.letters.4:
	dc.l $10000010
	dc.l $12000012
	dc.l $12000012
	dc.l $01111112
	dc.l $00222212
	dc.l $00000012
	dc.l $00000012
	dc.l $00000002
font.letters.5:
	dc.l $11111110
	dc.l $12222222
	dc.l $12000000
	dc.l $11111100
	dc.l $02222210
	dc.l $00000012
	dc.l $11111122
	dc.l $02222220
font.letters.6:
	dc.l $01111100
	dc.l $12222210
	dc.l $12000022
	dc.l $11111100
	dc.l $12222210
	dc.l $12000012
	dc.l $01111122
	dc.l $00222220
font.letters.7:
	dc.l $11111100
	dc.l $02222212
	dc.l $00000012
	dc.l $00000012
	dc.l $00000012
	dc.l $00000012
	dc.l $00000012
	dc.l $00000002
font.letters.8:
	dc.l $01111100
	dc.l $12222210
	dc.l $12000012
	dc.l $01111122
	dc.l $12222210
	dc.l $12000012
	dc.l $01111122
	dc.l $00222220
font.letters.9:
	dc.l $01111100
	dc.l $12222210
	dc.l $12000012
	dc.l $01111112
	dc.l $00222212
	dc.l $00000012
	dc.l $00000012
	dc.l $00000002
font.letters.0:
	dc.l $01111100
	dc.l $12222110
	dc.l $12001212
	dc.l $12012212
	dc.l $12122012
	dc.l $11220012
	dc.l $01111122
	dc.l $00222220
font.letters.a:
	dc.l $00111000
	dc.l $01222100
	dc.l $12000010
	dc.l $11111112
	dc.l $12222212
	dc.l $12000012
	dc.l $12000012
	dc.l $02000002
font.letters.b:
	dc.l $11111100
	dc.l $12222210
	dc.l $12000012
	dc.l $11111122
	dc.l $12222212
	dc.l $12000012
	dc.l $11111122
	dc.l $02222220
font.letters.c:
	dc.l $01111100
	dc.l $12222210
	dc.l $12000002
	dc.l $12000000
	dc.l $12000000
	dc.l $12000010
	dc.l $01111122
	dc.l $00222220
font.letters.d:
	dc.l $11111100
	dc.l $12222210
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $11111122
	dc.l $02222220
font.letters.e:
	dc.l $11111110
	dc.l $12222222
	dc.l $12000000
	dc.l $11111100
	dc.l $12222220
	dc.l $12000000
	dc.l $11111110
	dc.l $02222222
font.letters.f:
	dc.l $11111110
	dc.l $12222222
	dc.l $12000000
	dc.l $11111100
	dc.l $12222220
	dc.l $12000000
	dc.l $12000000
	dc.l $02000000
font.letters.g:
	dc.l $01111100
	dc.l $12222210
	dc.l $12000002
	dc.l $12011110
	dc.l $12002212
	dc.l $12000012
	dc.l $01111122
	dc.l $00222220
font.letters.h:
	dc.l $10000010
	dc.l $12000012
	dc.l $12000012
	dc.l $11111112
	dc.l $12222212
	dc.l $12000012
	dc.l $12000012
	dc.l $02000002
font.letters.i:
	dc.l $01111100
	dc.l $00212220
	dc.l $00012000
	dc.l $00012000
	dc.l $00012000
	dc.l $00012000
	dc.l $01111100
	dc.l $00222220
font.letters.j:
	dc.l $01111110
	dc.l $00221222
	dc.l $00001200
	dc.l $00001200
	dc.l $01001200
	dc.l $01201200
	dc.l $00112200
	dc.l $00022200
font.letters.k:
	dc.l $10000010
	dc.l $12000122
	dc.l $12001220
	dc.l $11111100
	dc.l $12222210
	dc.l $12000012
	dc.l $12000012
	dc.l $02000002
font.letters.l:
	dc.l $10000000
	dc.l $12000000
	dc.l $12000000
	dc.l $12000000
	dc.l $12000000
	dc.l $12000000
	dc.l $01111110
	dc.l $00222222
font.letters.m:
	dc.l $11101110
	dc.l $12212210
	dc.l $12012012
	dc.l $12012012
	dc.l $12012012
	dc.l $12012012
	dc.l $12012012
	dc.l $02002002
font.letters.n:
	dc.l $01111100
	dc.l $12222210
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $02000002
font.letters.o:
	dc.l $01111100
	dc.l $12222210
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $01111122
	dc.l $00222220
font.letters.p:
	dc.l $11111100
	dc.l $12222210
	dc.l $12000012
	dc.l $11111122
	dc.l $12222220
	dc.l $12000000
	dc.l $12000000
	dc.l $02000000
font.letters.q:
	dc.l $01111100
	dc.l $12222210
	dc.l $12000012
	dc.l $12000012
	dc.l $12001212
	dc.l $12002122
	dc.l $01111212
	dc.l $00222202
font.letters.r:
	dc.l $11111100
	dc.l $12222210
	dc.l $12000012
	dc.l $11111122
	dc.l $12222210
	dc.l $12000012
	dc.l $12000012
	dc.l $02000002
font.letters.s:
	dc.l $01111110
	dc.l $12222222
	dc.l $12000000
	dc.l $01111100
	dc.l $00222210
	dc.l $00000012
	dc.l $11111122
	dc.l $02222220
font.letters.t:
	dc.l $11111110
	dc.l $02212222
	dc.l $00012000
	dc.l $00012000
	dc.l $00012000
	dc.l $00012000
	dc.l $00012000
	dc.l $00002000
font.letters.u:
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $01111122
	dc.l $00222220
font.letters.v:
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $12000120
	dc.l $12001220
	dc.l $01112200
	dc.l $00222000
font.letters.w:
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $12010012
	dc.l $12012012
	dc.l $12012012
	dc.l $01121122
	dc.l $00220220
font.letters.x:
	dc.l $10000010
	dc.l $12000012
	dc.l $01200120
	dc.l $00111200
	dc.l $01222120
	dc.l $12000012
	dc.l $12000012
	dc.l $02000002
font.letters.y:
	dc.l $10000010
	dc.l $12000012
	dc.l $12000012
	dc.l $01111112
	dc.l $00222212
	dc.l $10000012
	dc.l $01111122
	dc.l $00222220
font.letters.z:
	dc.l $11111110
	dc.l $02222122
	dc.l $00001220
	dc.l $00012200
	dc.l $00122000
	dc.l $01220000
	dc.l $11111110
	dc.l $02222222
font.letters.space:
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
font.letters.period:
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00011000
	dc.l $00011200
	dc.l $00002200
font.letters.comma:
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00000000
	dc.l $00011000
	dc.l $00011200
	dc.l $00112200
	dc.l $00022000
font.letters.exclamation_mark:
	dc.l $00011000
	dc.l $00011200
	dc.l $00011200
	dc.l $00011200
	dc.l $00002200
	dc.l $00011000
	dc.l $00011200
	dc.l $00002200
font.letters.at:
	dc.l $00000000
	dc.l $00111100
	dc.l $01222210
	dc.l $00011012
	dc.l $00121212
	dc.l $00120212
	dc.l $00011122
	dc.l $00002220
font.letters.colon:
	dc.l $00000000
	dc.l $00011000
	dc.l $00011200
	dc.l $00002200
	dc.l $00000000
	dc.l $00011000
	dc.l $00011200
	dc.l $00002200
font.letters.lower_a:
	dc.l $00000000
	dc.l $00000000
	dc.l $01111100
	dc.l $00222210
	dc.l $01111112
	dc.l $12222212
	dc.l $01111112
	dc.l $00222222
font.letters.lower_b:
	dc.l $11111100
	dc.l $12222210
	dc.l $12000012
	dc.l $11111122
	dc.l $12222212
	dc.l $12000012
	dc.l $11111122
	dc.l $02222220
font.letters.lower_c:
	dc.l $00000000
	dc.l $00000000
	dc.l $01111110
	dc.l $12222222
	dc.l $12000000
	dc.l $12000000
	dc.l $01111110
	dc.l $00222222
font.letters.lower_d:
	dc.l $00000010
	dc.l $00000012
	dc.l $01111112
	dc.l $12222212
	dc.l $12000012
	dc.l $12000012
	dc.l $01111112
	dc.l $00222222
font.letters.lower_e:
	dc.l $00000000
	dc.l $00000000
	dc.l $01111100
	dc.l $12222210
	dc.l $11111122
	dc.l $12222220
	dc.l $01111110
	dc.l $00222222
font.letters.lower_f:
	dc.l $01111100
	dc.l $12222220
	dc.l $12000000
	dc.l $11110000
	dc.l $12222000
	dc.l $12000000
	dc.l $12000000
	dc.l $02000000
font.letters.lower_g:
	dc.l $00000000
	dc.l $00000000
	dc.l $01111110
	dc.l $12222212
	dc.l $12000012
	dc.l $01111112
	dc.l $00222212
	dc.l $01111122
font.letters.lower_h:
	dc.l $10000000
	dc.l $12000000
	dc.l $11111100
	dc.l $12222210
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $02000002
font.letters.lower_i:
	dc.l $00000000
	dc.l $00110000
	dc.l $00022000
	dc.l $00110000
	dc.l $00012000
	dc.l $00012000
	dc.l $00012000
	dc.l $00002000
font.letters.lower_j:
	dc.l $01111110
	dc.l $00221222
	dc.l $00001200
	dc.l $00001200
	dc.l $01001200
	dc.l $01201200
	dc.l $00112200
	dc.l $00022200
font.letters.lower_k:
	dc.l $10000010
	dc.l $12000122
	dc.l $12001220
	dc.l $11111100
	dc.l $12222210
	dc.l $12000012
	dc.l $12000012
	dc.l $02000002
font.letters.lower_l:
	dc.l $00100000
	dc.l $00120000
	dc.l $00120000
	dc.l $00120000
	dc.l $00120000
	dc.l $00120000
	dc.l $00011100
	dc.l $00002220
font.letters.lower_m:
	dc.l $11101110
	dc.l $12212210
	dc.l $12012012
	dc.l $12012012
	dc.l $12012012
	dc.l $12012012
	dc.l $12012012
	dc.l $02002002
font.letters.lower_n:
	dc.l $00000000
	dc.l $00000000
	dc.l $01111100
	dc.l $12222210
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $02000002
font.letters.lower_o:
	dc.l $00000000
	dc.l $00000000
	dc.l $01111100
	dc.l $12222210
	dc.l $12000012
	dc.l $12000012
	dc.l $01111122
	dc.l $00222220
font.letters.lower_p:
	dc.l $00000000
	dc.l $00000000
	dc.l $11111100
	dc.l $12222210
	dc.l $12000012
	dc.l $11111122
	dc.l $12222220
	dc.l $12000000
font.letters.lower_q:
	dc.l $01111100
	dc.l $12222210
	dc.l $12000012
	dc.l $12000012
	dc.l $12001212
	dc.l $12002122
	dc.l $01111212
	dc.l $00222202
font.letters.lower_r:
	dc.l $00000000
	dc.l $00000000
	dc.l $01111110
	dc.l $12222222
	dc.l $12000000
	dc.l $12000000
	dc.l $12000000
	dc.l $02000000
font.letters.lower_s:
	dc.l $00000000
	dc.l $00000000
	dc.l $01111110
	dc.l $12222222
	dc.l $01111100
	dc.l $00222210
	dc.l $11111122
	dc.l $02222220
font.letters.lower_t:
	dc.l $10000000
	dc.l $12000000
	dc.l $11111000
	dc.l $12222200
	dc.l $12000000
	dc.l $12000000
	dc.l $01111110
	dc.l $00222222
font.letters.lower_u:
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $01111122
	dc.l $00222220
font.letters.lower_v:
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $12000012
	dc.l $12000120
	dc.l $12001220
	dc.l $01112200
	dc.l $00222000
font.letters.lower_w:
	dc.l $00000000
	dc.l $00000000
	dc.l $12000012
	dc.l $12010012
	dc.l $12012012
	dc.l $12012012
	dc.l $01121122
	dc.l $00220220
font.letters.lower_x:
	dc.l $10000010
	dc.l $12000012
	dc.l $01200120
	dc.l $00111200
	dc.l $01222120
	dc.l $12000012
	dc.l $12000012
	dc.l $02000002
font.letters.lower_y:
	dc.l $10000010
	dc.l $12000012
	dc.l $12000012
	dc.l $01111112
	dc.l $00222212
	dc.l $10000012
	dc.l $01111122
	dc.l $00222220
font.letters.lower_z:
	dc.l $11111110
	dc.l $02222122
	dc.l $00001220
	dc.l $00012200
	dc.l $00122000
	dc.l $01220000
	dc.l $11111110
	dc.l $02222222
font.letters.inverse_exclamation_mark:
	dc.l $01111110
	dc.l $11100111
	dc.l $11100111
	dc.l $11100111
	dc.l $11111111
	dc.l $11100111
	dc.l $01111110
	dc.l $00000000
font.end:
}
