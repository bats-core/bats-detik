#!/usr/bin/env bats

load "../lib/utils"

debug_filename=$(basename -- "$BATS_TEST_FILENAME")
target="/tmp/detik/$debug_filename.debug"

@test "testing debug" {

	rm -f "$target"
	[ ! -f "$target" ]
	
	run debug "test"
	[ "$status" -eq 0 ]
	[ -f "$target" ]
	
	content=$(cat "$target")
	[ "$content" = "test" ]
}


@test "testing reset_debug" {

	[ -f "$target" ]
	run reset_debug
	[ "$status" -eq 0 ]
	
	[ ! -f "$target" ]
}
