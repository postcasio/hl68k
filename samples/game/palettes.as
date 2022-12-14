block palette_code (@bank = rom_code) {

load_palette:
    ; d0 = CRAM addr
    ; a0 = palette addr
    vdp_begin_write VDP_CRAM_WRITE, d0

    move.l #8, d0
    subi.l #$01, d0
.loop:
    vdp_write (a0)+
    dbf d0, .loop
    rts
}

block palette_data (@bank = rom_data) {
palette_spring:
    dc.w	$0F0F	; rgb(240,000,240) => 1111 0000 1111 => 0F0F
    dc.w	$0115	; rgb(080,048,032) => 0010 0011 0101 => 0115
    dc.w	$0356	; rgb(096,080,048) => 0011 0101 0110 => 0356
    dc.w	$0139	; rgb(144,096,016) => 0001 0011 1001 => 0139
    dc.w	$0031	; rgb(016,048,000) => 0000 0011 0001 => 0031
    dc.w	$0033	; rgb(048,048,000) => 0000 0011 0011 => 0033
    dc.w	$0785	; rgb(112,128,032) => 0111 1000 0101 => 0785
    dc.w	$05CD	; rgb(208,192,080) => 0101 1100 1101 => 05CD
    dc.w	$0A9D	; rgb(208,144,160) => 1010 1001 1101 => 0A9D
    dc.w	$0EEE	; rgb(224,224,224) => 1110 1110 1110 => 0EEE
    dc.w	$0154	; rgb(064,080,016) => 0001 0101 0100 => 0154
    dc.w	$04EE	; rgb(224,224,080) => 0100 1110 1110 => 04EE
    dc.w	$098A	; rgb(160,128,144) => 1001 1000 1010 => 098A
    dc.w	$0743	; rgb(048,064,112) => 0111 0100 0011 => 0743
    dc.w	$0F95	; rgb(080,144,240) => 1111 1001 0101 => 0F95
    dc.w	$079A	; rgb(160,144,112) => 0111 1001 1010 => 079A

palette_summer:
    dc.w	$0F0F	; rgb(240,000,240) => 1111 0000 1111 => 0F0F
    dc.w	$0115	; rgb(080,048,032) => 0010 0011 0101 => 0115
    dc.w	$0356	; rgb(096,080,048) => 0011 0101 0110 => 0356
    dc.w	$0139	; rgb(144,096,016) => 0001 0011 1001 => 0139
    dc.w	$0031	; rgb(016,048,000) => 0000 0011 0001 => 0031
    dc.w	$0033	; rgb(048,048,000) => 0000 0011 0011 => 0033
    dc.w	$0485	; rgb(112,128,064) => 0100 1000 0101 => 0485
    dc.w	$0145	; rgb(084,064,016) => 0001 0100 0101 => 0145
    dc.w	$0488	; rgb(128,128,064) => 0100 1000 1000 => 0488
    dc.w	$03CC	; rgb(192,192,048) => 0011 1100 1100 => 03CC
    dc.w	$0165	; rgb(080,096,016) => 0001 0110 0101 => 0165
    dc.w	$0142	; rgb(032,064,016) => 0001 0100 0010 => 0142
    dc.w	$04EE	; rgb(224,224,064) => 0100 1110 1110 => 04EE
    dc.w	$034E	; rgb(224,064,048) => 0011 0100 1110 => 034E
    dc.w	$056D	; rgb(208,096,080) => 0101 0110 1101 => 056D
    dc.w	$0899	; rgb(144,144,128) => 1000 1001 1001 => 0899

palette_fall:
    dc.w	$0F0F	; rgb(240,000,240) => 1111 0000 1111 => 0F0F
    dc.w	$0115	; rgb(080,048,032) => 0010 0011 0101 => 0115
    dc.w	$0356	; rgb(096,080,048) => 0011 0101 0110 => 0356
    dc.w	$0139	; rgb(144,096,016) => 0001 0011 1001 => 0139
    dc.w	$0031	; rgb(016,048,000) => 0000 0011 0001 => 0031
    dc.w	$0033	; rgb(048,048,000) => 0000 0011 0011 => 0033
    dc.w	$0238	; rgb(128,048,032) => 0010 0011 1000 => 0238
    dc.w	$034D	; rgb(208,064,048) => 0011 0100 1101 => 034D
    dc.w	$029E	; rgb(224,144,032) => 0010 1001 1110 => 029E
    dc.w	$04EF	; rgb(240,224,064) => 0100 1110 1111 => 04EF
    dc.w	$059A	; rgb(160,144,080) => 0101 1001 1010 => 059A
    dc.w	$07BA	; rgb(160,176,112) => 0111 1011 1010 => 07BA
    dc.w	$029D	; rgb(208,144,032) => 0010 1001 1101 => 029D
    dc.w	$045F	; rgb(240,080,064) => 0100 0101 1111 => 045F
    dc.w	$03CF	; rgb(240,192,048) => 0011 1100 1111 => 03CF
    dc.w	$0DEE	; rgb(224,224,208) => 1101 1110 1110 => 0DEE

palette_winter:
    dc.w	$0F0F	; rgb(240,000,240) => 1111 0000 1111 => 0F0F
    dc.w	$0115	; rgb(080,048,032) => 0010 0011 0101 => 0115
    dc.w	$0356	; rgb(096,080,048) => 0011 0101 0110 => 0356
    dc.w	$0139	; rgb(144,096,016) => 0001 0011 1001 => 0139
    dc.w	$0031	; rgb(016,048,000) => 0000 0011 0001 => 0031
    dc.w	$0033	; rgb(048,048,000) => 0000 0011 0011 => 0033
    dc.w	$0FEE	; rgb(224,224,240) => 1111 1110 1110 => 0FEE
    dc.w	$0FED	; rgb(208,224,240) => 1111 1110 1101 => 0FED
    dc.w	$0FEC	; rgb(192,224,240) => 1111 1110 1100 => 0FEC
    dc.w	$0ECD	; rgb(208,192,224) => 1110 1100 1101 => 0ECD
    dc.w	$0FFF	; rgb(240,240,240) => 1111 1111 1111 => 0FFF
    dc.w	$0EED	; rgb(208,224,224) => 1110 1110 1101 => 0EED
    dc.w	$0ABB	; rgb(176,176,160) => 1010 1011 1011 => 0ABB
    dc.w	$0358	; rgb(128,080,048) => 0011 0101 1000 => 0358
    dc.w	$0345	; rgb(080,064,048) => 0011 0100 0101 => 0345
    dc.w	$0DCC	; rgb(192,192,208) => 1101 1100 1100 => 0DCC

palette_system:
    dc.w $0000
    dc.w $FFFF
    dc.w $0666
    dc.w $0DDD
    dc.w $0444
    dc.w $000A
    dc.w $00A0
    dc.w $0A00
    dc.w $00AA
    dc.w $0AA0
    dc.w $0A0A
    dc.w $0222
    dc.w $0777
    dc.w $0888
    dc.w $0AAA
    dc.w $0BBB
}
