#!/usr/bin/env bats

load "../lib/detik"


DETIK_CLIENT_NAME="mytest"
mytest() {
	echo -e "NAME  PROP\nnginx-deployment-75675f5897-6dg9r  Running\nnginx-deployment-75675f5897-gstkw  Running"
}


@test "trying to verify the status of a POD with the lower-case syntax and a simple match" {
	run try "at most 1 times every 1s to get pods named 'nginx' and verify that 'status' matches 'Running'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
}


@test "trying to verify the status of a POD with the lower-case syntax and a simple match with different case" {
	run try "at most 1 times every 1s to get pods named 'nginx' and verify that 'status' matches 'running'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is Running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is Running..." ]
}


@test "trying to verify the status of a POD with the lower-case syntax and a simple match with case-insensitivy" {
	DETIK_REGEX_CASE_INSENSITIVE_PROPERTIES="true"
	run try "at most 1 times every 1s to get pods named 'nginx' and verify that 'status' matches 'running'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found running)." ]
}


@test "trying to verify the status of a POD with the lower-case syntax and a simple match with an upper-case pattern" {
	run try "at most 1 times every 1s to get pods named 'nginx' and verify that 'status' matches '[A-Z]+$'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is Running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is Running..." ]
}


@test "trying to verify the status of a POD with the lower-case syntax and a simple match with a lower-case pattern" {
	run try "at most 5 times every 5s to get pods named 'nginx' and verify that 'status' matches '[A-Z][a-z]+'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
}


@test "trying to verify the status of a POD with the lower-case syntax and an exact match" {
	run try "at most 5 times every 5s to get pods named 'nginx' and verify that 'status' matches '^Running$'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
}


@test "trying to verify the status of a POD with a complex property and a partial match" {
	run try "at most 5 times every 5s to get pods named 'nginx' and verify that '.status.phase' matches '^Run.*'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
}

@test "trying to verify the containerStatus of a POD with a complex json property and a partial match" {
	run try "at most 5 times every 5s to get pods named 'nginx' and verify that '.status.containerStatuses[?(@.name==\"nginx\")].ready' matches '.*ning'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
}


@test "trying to verify the status of a POD with upper-case letters and a pattern match" {
	run try "at most 5 times eVery 5s to GET pods named 'nginx' and verify that 'status' matches '^Running$'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
}


@test "trying to verify the syntax check (invalid wording, with a pattern match)" {
	run try "at most 5 times VERY 5hours to GET pods named 'nginx' and verify that 'status' matches 'RUNNING'"
	[ "$status" -eq 2 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "Invalid expression: it does not respect the expected syntax." ]
}


@test "trying to verify the syntax check (missing quotes, with a pattern match)" {
	run try "at most 5 times every 5s to get pods named 'nginx' and verify that 'status' matches Running"
	[ "$status" -eq 2 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "Invalid expression: it does not respect the expected syntax." ]
}


@test "trying to verify the status of a POD with the wrong value and a match (1 attempt)" {
	run try "at most 1 times every 1s to get pods named 'nginx' and verify that 'status' matches 'initializing'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is Running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is Running..." ]
}


@test "trying to verify the status of a POD with the wrong value and a match (2 attempts)" {
	run try "at most 2 times every 1s to get pods named 'nginx' and verify that 'status' matches 'initializing'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 5 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is Running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is Running..." ]
	[ "${lines[3]}" = "Current value for nginx-deployment-75675f5897-6dg9r is Running..." ]
	[ "${lines[4]}" = "Current value for nginx-deployment-75675f5897-gstkw is Running..." ]
}


@test "trying to verify the status of a POD with the wrong value and a match (3 attempts)" {
	run try "at most 3 times every 1s to get pods named 'nginx' and verify that 'status' matches 'initializing'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 7 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is Running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is Running..." ]
	[ "${lines[3]}" = "Current value for nginx-deployment-75675f5897-6dg9r is Running..." ]
	[ "${lines[4]}" = "Current value for nginx-deployment-75675f5897-gstkw is Running..." ]
	[ "${lines[5]}" = "Current value for nginx-deployment-75675f5897-6dg9r is Running..." ]
	[ "${lines[6]}" = "Current value for nginx-deployment-75675f5897-gstkw is Running..." ]
}


@test "trying to verify the status of a POD with an invalid name and a pattern match" {
	run try "at most 1 times every 1s to get pods named 'nginx-something' and verify that 'status' matches 'Running'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "No resource of type 'pods' was found with the name 'nginx-something'." ]
}


@test "trying to verify the status of a POD with a pattern name and a partial match" {
	run try "at most 1 times every 1s to get pods named 'ngin.*' and verify that 'status' matches 'R.*g'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
}


@test "trying to verify the status of a POD with an invalid pattern name and a partial match" {
	run try "at most 1 times every 1s to get pods named 'ngin.+x' and verify that 'status' matches 'Running'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "No resource of type 'pods' was found with the name 'ngin.+x'." ]
}


@test "trying to verify the status of a POD with the lower-case syntax (multi-lines and pattern matching)" {
	run try "  at  most  5  times  every  5s  to  get  pods " \
		" named  'nginx'  and " \
		" verify  that  'status'  matches  '^Running$' "

	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
}


@test "trying to verify the status of a POD with the lower-case syntax (multi-lines and pattern matching, without quotes)" {
	run try at  most  11  times  every  5s  to  get  pods \
		named  "'nginx'"  and \
		verify  that  "'status'"  matches  "'^Running$'"

	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
}


@test "trying to verify the status of a POD with the lower-case syntax (debug matching)" {

	debug_filename=$(basename -- "$BATS_TEST_FILENAME")
	path="/tmp/detik/$debug_filename.debug"
	[[ -f "$path" ]] && mv "$path" "$path.backup"
	[ ! -f "$path" ]

	# Enable the debug flag
	DEBUG_DETIK="true"
	run try "at most 5 times every 5s to get pods named 'nginx' and verify that 'status' matches '^[[:alnum:]]+$'"

	# Reset the debug flag
	DEBUG_DETIK=""

	# Verify basic assertions
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]

	# Verify the debug file
	[ -f "$path" ]

	rm -rf "$path.cmp"
	exec 7<> "$path.cmp"

	echo "-----DETIK:begin-----" >&7
	echo "$BATS_TEST_FILENAME" >&7
	echo "trying to verify the status of a POD with the lower-case syntax (debug matching)" >&7
	echo "" >&7
	echo "Client query:" >&7
	echo "mytest get pods -o custom-columns=NAME:.metadata.name,PROP:.status.phase" >&7
	echo "" >&7
	echo "Result:" >&7
	echo "nginx-deployment-75675f5897-6dg9r  Running" >&7
	echo "nginx-deployment-75675f5897-gstkw  Running" >&7
	echo "-----DETIK:end-----" >&7
	echo "" >&7

	exec 7>&-
	run diff -q "$path" "$path.cmp"
	[ "$status" -eq 0 ]
	[ "$output" = "" ]

	[[ -f "$path.backup" ]] && mv "$path.backup" "$path"
	rm -rf "$path.cmp"
}
