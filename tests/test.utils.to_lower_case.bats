#!/usr/bin/env bats

load "../lib/utils"


@test "testing to_lower_case" {

	run to_lower_case "already in lower case"
	[ "$status" -eq 0 ]
	[ "$output" = "already in lower case" ]
	
	run to_lower_case "With Upper CASE"
	[ "$status" -eq 0 ]
	[ "$output" = "with upper case" ]
	
	run to_lower_case "with SOME numbers: 45, 18"
	[ "$status" -eq 0 ]
	[ "$output" = "with some numbers: 45, 18" ]
}
