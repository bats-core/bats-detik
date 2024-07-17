#!/usr/bin/env bats

load "../lib/detik"


DETIK_CLIENT_NAME="mytest"
mytest() {
	echo -e "NAME  PROP\nnginx-deployment-75675f5897-6dg9r  Running\nnginx-deployment-75675f5897-gstkw  Running"
}

mytest_with_spaces() {
	echo -e "NAME  PROP\ncert1  ----BEGIN CERTIFICATE----"
}

mytest_deployment(){
	echo -e "NAME PROP\nnginx 2"
}


@test "trying to verify the status of a POD with the lower-case syntax" {
	run try "at most 5 times every 5s to get pods named 'nginx' and verify that 'status' is 'running'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "trying to verify the status of a POD with a complex property" {
	run try "at most 5 times every 5s to get pods named 'nginx' and verify that '.status.phase' is 'running'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}

@test "trying to verify the containerStatus of a POD with a complex json property" {
	run try "at most 5 times every 5s to get pods named 'nginx' and verify that '.status.containerStatuses[?(@.name==\"nginx\")].ready' is 'running'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "trying to verify the status of a POD with upper-case letters" {
	run try "at most 5 times eVery 5s to GET pods named 'nginx' and verify that 'status' is 'RUNNING'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "trying to verify the content of a single-line value with spaces" {
	DETIK_CLIENT_NAME="mytest_with_spaces"
	run try "at most 1 times every 1s to get something named 'cert1' and verify that 'value' is '----BEGIN CERTIFICATE----'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "cert1 has the right value (----begin certificate----)." ]
}


@test "trying to verify the syntax check (invalid wording)" {
	run try "at most 5 times VERY 5hours to GET pods named 'nginx' and verify that 'status' is 'RUNNING'"
	[ "$status" -eq 2 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "Invalid expression: it does not respect the expected syntax." ]
}


@test "trying to verify the syntax check (missing quotes)" {
	run try "at most 5 times every 5s to get pods named 'nginx' and verify that 'status' is running"
	[ "$status" -eq 2 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "Invalid expression: it does not respect the expected syntax." ]
}


@test "trying to verify the syntax check (empty query)" {
	run try ""
	[ "$status" -eq 1 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "An empty expression was not expected." ]
}


@test "trying to verify the status of a POD with the wrong value (1 attempt)" {
	run try "at most 1 times every 1s to get pods named 'nginx' and verify that 'status' is 'initializing'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is running..." ]
}


@test "trying to verify the status of a POD with the wrong value (2 attempts)" {
	run try "at most 2 times every 1s to get pods named 'nginx' and verify that 'status' is 'initializing'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 5 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is running..." ]
	[ "${lines[3]}" = "Current value for nginx-deployment-75675f5897-6dg9r is running..." ]
	[ "${lines[4]}" = "Current value for nginx-deployment-75675f5897-gstkw is running..." ]
}


@test "trying to verify the status of a POD with the wrong value (3 attempts)" {
	run try "at most 3 times every 1s to get pods named 'nginx' and verify that 'status' is 'initializing'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 7 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is running..." ]
	[ "${lines[3]}" = "Current value for nginx-deployment-75675f5897-6dg9r is running..." ]
	[ "${lines[4]}" = "Current value for nginx-deployment-75675f5897-gstkw is running..." ]
	[ "${lines[5]}" = "Current value for nginx-deployment-75675f5897-6dg9r is running..." ]
	[ "${lines[6]}" = "Current value for nginx-deployment-75675f5897-gstkw is running..." ]
}


@test "trying to verify the status of a POD with an invalid name" {
	run try "at most 1 times every 1s to get pods named 'nginx-something' and verify that 'status' is 'running'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "No resource of type 'pods' was found with the name 'nginx-something'." ]
}


@test "trying to verify the status of a POD with a pattern name" {
	run try "at most 1 times every 1s to get pods named 'ngin.*' and verify that 'status' is 'running'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "trying to find of a POD with an extended pattern name" {
  run try "at most 1 times every 5s to get pod named '^nginx-deployment-[a-z0-9]{9,10}-[a-z0-9]{5}\$' and verify that 'status' is 'running'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "trying to verify the status of a POD with an invalid pattern name" {
	run try "at most 1 times every 1s to get pods named 'ngin.+x' and verify that 'status' is 'running'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "No resource of type 'pods' was found with the name 'ngin.+x'." ]
}


@test "trying to find of a POD with an invalid extended pattern name" {
	run try "at most 1 times every 1s to find 2 pods named '^nginx-deployment-[a-z0-9]{9,10}-[a-z0-9]{4}\$' with 'status' being 'running'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "No resource of type 'pods' was found with the name '^nginx-deployment-[a-z0-9]{9,10}-[a-z0-9]{4}\$'." ]
	[ "${lines[2]}" = "Expected 2 pods named ^nginx-deployment-[a-z0-9]{9,10}-[a-z0-9]{4}\$ to have this value (running). Found 0." ]
}


@test "trying to verify the status of a POD with the lower-case syntax (multi-lines)" {
	run try "  at  most  5  times  every  5s  to  get  pods " \
		" named  'nginx'  and " \
		" verify  that  'status'  is  'running' "

	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "trying to verify the status of a POD with the lower-case syntax (multi-lines, without quotes)" {
	run try at  most  11  times  every  5s  to  get  pods \
		named  "'nginx'"  and \
		verify  that  "'status'"  is  "'running'"

	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "trying to verify the status of a POD with the lower-case syntax (debug)" {

	debug_filename=$(basename -- "$BATS_TEST_FILENAME")
	path="/tmp/detik/$debug_filename.debug"
	[[ -f "$path" ]] && mv "$path" "$path.backup"
	[ ! -f "$path" ]

	# Enable the debug flag
	DEBUG_DETIK="true"
	run try "at most 5 times every 5s to get pods named 'nginx' and verify that 'status' is 'running'"

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
	echo "trying to verify the status of a POD with the lower-case syntax (debug)" >&7
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


@test "trying to verify the replicas of a DEPLOYMENT is more than with the lower-case syntax" {
	DETIK_CLIENT_NAME=mytest_deployment
	run try "at most 1 times every 5s to get deployment named 'nginx' and verify that 'status.readyReplicas' is more than '1'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx matches the regular expression (found 2)." ]
}


@test "trying to verify the replicas of a DEPLOYMENT is less than with the lower-case syntax" {
	DETIK_CLIENT_NAME=mytest_deployment
	run try "at most 1 times every 5s to get deployment named 'nginx' and verify that 'status.readyReplicas' is less than '3'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx matches the regular expression (found 2)." ]
}

@test "trying to verify the replicas of a DEPLOYMENT is more than with the lower-case syntax with higher value" {
	DETIK_CLIENT_NAME=mytest_deployment
	run try "at most 1 times every 5s to get deployment named 'nginx' and verify that 'status.readyReplicas' is more than '2'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx is not more than 2..." ]
}

@test "trying to verify the replicas of a DEPLOYMENT is less than with the lower-case syntax with lower value" {
	DETIK_CLIENT_NAME=mytest_deployment
	run try "at most 1 times every 5s to get deployment named 'nginx' and verify that 'status.readyReplicas' is less than '1'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx is not less than 1..." ]
}
