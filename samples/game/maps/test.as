block map_test_data (@bank = rom_data, @align = 2) {
map_test:
	map_header {
		size = MAP_SIZE_64_64
		fgOffset = .fg-map_test
		bgOffset = .bg-map_test
		width = 64
		height = 64
		name = "TEST MAP\0"
		palettes = palette_spring, palette_winter, palette_summer
	}
.align 16
.fg:
	ds.w $1000, $a080, $a081, $a082, $a083, $a084, $a085
.bg:
	ds.w $1000, $0085
}
