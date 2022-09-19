bank rom_header {
	@start = 0
	@size = $200
	@rom = 1
}

bank rom_code {
	@rom = 1
}

bank rom_data {
	@rom = 1
}

bank ram_system {
	@ram_start = $FF0000
	@size = $FFFF
}
