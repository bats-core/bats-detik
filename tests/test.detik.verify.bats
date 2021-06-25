#!/usr/bin/env bats

load "../lib/detik"


DETIK_CLIENT_NAME="mytest"
DETIK_CLIENT_NAMESPACE=""
mytest() {
	# The namespace should not appear (it is set in 1st position)
	[[ "$1" != "--namespace=test_ns" ]] || return 1

	# Return the result
	echo -e "NAME  PROP\nnginx-deployment-75675f5897-6dg9r  Running\nnginx-deployment-75675f5897-gstkw  Running"
}

mytest_with_namespace() {
	# A namespace is expected as the first argument
	[[ "$1" == "--namespace=test_ns" ]] || return 1

	# Return the result
	echo -e "NAME  PROP\nnginx-deployment-75675f5897-6dg9r  Running\nnginx-deployment-75675f5897-gstkw  Running"
}


@test "verifying the number of PODs with the lower-case syntax (exact number, plural)" {
	run verify "there are 2 pods named 'nginx'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Found 2 pods named nginx (as expected)." ]
}


@test "verifying the number of PODs with the lower-case syntax (exact number, singular)" {
	run verify "there is 1 pod named 'nginx-deployment-75675f5897-6dg9r'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Found 1 pod named nginx-deployment-75675f5897-6dg9r (as expected)." ]
}


@test "verifying the number of PODs with the lower-case syntax (exact number, singular mixed with plural)" {
	run verify "there are 1 pods named 'nginx-deployment-75675f5897-6dg9r'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Found 1 pods named nginx-deployment-75675f5897-6dg9r (as expected)." ]
}


@test "verifying the number of PODs with the lower-case syntax (exact number, 0 as singular)" {
	run verify "there is 0 pod named 'nginx-deployment-inexisting'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Found 0 pod named nginx-deployment-inexisting (as expected)." ]
}


@test "verifying the number of PODs with the lower-case syntax (exact number, 0 as plural)" {
	run verify "there are 0 pods named 'nginx-deployment-inexisting'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Found 0 pods named nginx-deployment-inexisting (as expected)." ]
}


@test "verifying the number of PODs with upper-case letters" {
	run verify "There are 2 PODS named 'nginx'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Found 2 pods named nginx (as expected)." ]
}


@test "verifying the number of PODs with upper-case letters (with a different K8s namespace)" {
	DETIK_CLIENT_NAME="mytest_with_namespace"
	DETIK_CLIENT_NAMESPACE="test_ns"
	DEBUG_DETIK="true"

	run verify "There are 2 PODS named 'nginx'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Found 2 pods named nginx (as expected)." ]

	# Running the same request with the invalid client will throw an error
	# (the namespace is not expected in this function)
	DETIK_CLIENT_NAME="mytest"
	run verify "There are 2 PODS named 'nginx'"
	[ "$status" -eq 3 ]
}


@test "verifying the syntax check (counting with invalid wording)" {
	run verify "There is 2 PODS named 'nginx'"
	[ "$status" -eq 2 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "Invalid expression: it does not respect the expected syntax." ]
}


@test "verifying the syntax check (counting with missing quotes)" {
	run verify "There are 2 PODS named nginx"
	[ "$status" -eq 2 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "Invalid expression: it does not respect the expected syntax." ]
}


@test "verifying the syntax check (empty query)" {
	run verify ""
	[ "$status" -eq 1 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "An empty expression was not expected." ]
}


@test "verifying the number of PODs with an invalid name" {
	run verify "There are 2 pods named 'nginx-inexisting'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Found 0 pods named nginx-inexisting (instead of 2 expected)." ]
}


@test "verifying the number of PODs with a pattern name" {
	run verify "There are 2 pods named 'ngin.*'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Found 2 pods named ngin.* (as expected)." ]
}


@test "verifying the number of PODs with an invalid pattern name" {
	run verify "There are 2 pods named 'ngin.+x'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Found 0 pods named ngin.+x (instead of 2 expected)." ]
}


@test "verifying the number of PODs with the lower-case syntax (multi-lines)" {
	run verify 	" there     are  2   pods  " \
			" named  'nginx' "

	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Found 2 pods named nginx (as expected)." ]
}


@test "verifying the number of PODs with the lower-case syntax (multi-lines, without quotes)" {
	run verify  there     are  2   pods  \
			 named  "'nginx'"

	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Found 2 pods named nginx (as expected)." ]
}


@test "verifying the number of PODs with the lower-case syntax (debug)" {

	debug_filename=$(basename -- "$BATS_TEST_FILENAME")
	path="/tmp/detik/$debug_filename.debug"
	[ -f "$path" ] && mv "$path" "$path.backup"
	[ ! -f "$path" ]

	# Enable the debug flag
	DEBUG_DETIK="true"
	run verify "there are 2 pods named 'nginx'"

	# Reset the debug flag
	DEBUG_DETIK=""

	# Verify basic assertions
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Found 2 pods named nginx (as expected)." ]

	# Verify the debug file
	[ -f "$path" ]

	rm -rf "$path.cmp"
	exec 7<> "$path.cmp"

	echo "-----DETIK:begin-----" >&7
	echo "$BATS_TEST_FILENAME" >&7
	echo "verifying the number of PODs with the lower-case syntax (debug)" >&7
	echo "" >&7
	echo "Client query:" >&7
	echo "mytest get pods -o custom-columns=NAME:.metadata.name" >&7
	echo "" >&7
	echo "Result:" >&7
	echo "2" >&7
	echo "-----DETIK:end-----" >&7
	echo "" >&7

	exec 7>&-
	run diff -q "$path" "$path.cmp"
	[ "$status" -eq 0 ]
	[ "$output" = "" ]

	[ -f "$path.backup" ] && mv "$path.backup" "$path"
	rm -rf "$path.cmp"
}


@test "verifying the number of PODs with the lower-case syntax (debug and a different K8s namespace)" {
	DETIK_CLIENT_NAME="mytest_with_namespace"
	DETIK_CLIENT_NAMESPACE="test_ns"

	debug_filename=$(basename -- "$BATS_TEST_FILENAME")
	path="/tmp/detik/$debug_filename.debug"
	[ -f "$path" ] && mv "$path" "$path.backup"
	[ ! -f "$path" ]

	# Enable the debug flag
	DEBUG_DETIK="true"
	run verify "there are 2 pods named 'nginx'"

	# Reset the debug flag
	DEBUG_DETIK=""

	# Verify basic assertions
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Found 2 pods named nginx (as expected)." ]

	# Verify the debug file
	[ -f "$path" ]

	rm -rf "$path.cmp"
	exec 7<> "$path.cmp"

	echo "-----DETIK:begin-----" >&7
	echo "$BATS_TEST_FILENAME" >&7
	echo "verifying the number of PODs with the lower-case syntax (debug and a different K8s namespace)" >&7
	echo "" >&7
	echo "Client query:" >&7
	echo "mytest_with_namespace --namespace=test_ns get pods -o custom-columns=NAME:.metadata.name" >&7
	echo "" >&7
	echo "Result:" >&7
	echo "2" >&7
	echo "-----DETIK:end-----" >&7
	echo "" >&7

	exec 7>&-
	run diff -q "$path" "$path.cmp"
	[ "$status" -eq 0 ]
	[ "$output" = "" ]

	[ -f "$path.backup" ] && mv "$path.backup" "$path"
	rm -rf "$path.cmp"
}


@test "verifying the status of a POD with the lower-case syntax" {
	run verify "'status' is 'running' for pods named 'nginx'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "verifying the status of a POD with a complex property" {
	run verify "'.status.phase' is 'running' for pods named 'nginx'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "verifying the status of a POD with upper-case letters" {
	run verify "'status' is 'RUNNING' For pods named 'nginx'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "verifying the syntax check (invalid wording)" {
	run verify "'status' is 'running' for all the pods named 'nginx'"
	[ "$status" -eq 2 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "Invalid expression: it does not respect the expected syntax." ]
}


@test "verifying the syntax check (missing quotes)" {
	run verify "status is 'running' for pods named 'nginx'"
	[ "$status" -eq 2 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "Invalid expression: it does not respect the expected syntax." ]
}


@test "verifying the status of a POD with the wrong value" {
	run verify "'status' is 'initializing' for pods named 'nginx'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is running..." ]
}


@test "verifying the status of a POD with an invalid name" {
	run verify "'status' is 'running' for pods named 'nginx-something'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "No resource of type 'pods' was found with the name 'nginx-something'." ]
}


@test "verifying the status of a POD with a pattern name" {
	run verify "'status' is 'running' for pods named 'ngin.*'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "verifying the status of a POD with an invalid pattern name" {
	run verify "'status' is 'running' for pods named 'ngin.+x'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "No resource of type 'pods' was found with the name 'ngin.+x'." ]
}


@test "verifying the status of a POD with the lower-case syntax (multi-lines)" {
	run verify "  'status'   is   'running'   for " \
			"  pods      named   'nginx'  "

	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "verifying the status of a POD with the lower-case syntax (multi-lines, without quotes)" {
	run verify "'status'"   is   "'running'"   for \
		pods      named   "'nginx'"

	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "verifying the status of a POD with the lower-case syntax (debug)" {

	debug_filename=$(basename -- "$BATS_TEST_FILENAME")
	path="/tmp/detik/$debug_filename.debug"
	[ -f "$path" ] && mv "$path" "$path.backup"
	[ ! -f "$path" ]

	# Enable the debug flag
	DEBUG_DETIK="true"
	run verify "'status' is 'running' for pods named 'nginx'"

	# Reset the debug flag
	DEBUG_DETIK=""

	# Verify basic assertions
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]

	# Verify the debug file
	[ -f "$path" ]

	rm -rf "$path.cmp"
	exec 7<> "$path.cmp"

	echo "-----DETIK:begin-----" >&7
	echo "$BATS_TEST_FILENAME" >&7
	echo "verifying the status of a POD with the lower-case syntax (debug)" >&7
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

	rm -rf "$path.cmp"
	[ -f "$path.backup" ] && mv "$path.backup" "$path"
}
