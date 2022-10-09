block map_test_data (@bank = rom_data, @align = 2) {
map_test:
	map_header {
		size = MAP_SIZE_64_64
		fgOffset = .fg-map_test
		bgOffset = .bg-map_test
		width = 64
		height = 64
		name = "TEST MAP\0"
	}
.align 16
.fg:
	ds.w $1000, $a085, $a086, $a087, $a088
.bg:
	ds.w $1000, $0085
}
