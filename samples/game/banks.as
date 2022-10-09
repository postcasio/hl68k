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
	@start = $FF0000
	@size = $FFFF
}

bank rom_script {
	@rom = 1
	@start = $10000
	@size = $10000
}
