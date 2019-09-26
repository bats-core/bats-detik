#!/usr/bin/env bats

load "../lib/utils"


@test "testing trim" {

	run trim "This is a sentence."
	[ "$status" -eq 0 ]
	[ "$output" = "This is a sentence." ]
	
	run trim "  This is a sentence. "
	[ "$status" -eq 0 ]
	[ "$output" = "This is a sentence." ]
	
	run trim "  This is a sentence."
	[ "$status" -eq 0 ]
	[ "$output" = "This is a sentence." ]
	
	run trim "This is a sentence.   "
	[ "$status" -eq 0 ]
	[ "$output" = "This is a sentence." ]
	
	run trim "This is a sentence."
	[ "$status" -eq 0 ]
	[ "$output" = "This is a sentence." ]
}
