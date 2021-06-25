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


@test "trying to find 1 POD with the lower-case syntax" {
	run try "at most 1 times every 5s to find 1 pod named 'nginx' with 'status' being 'running'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 4 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
	[ "${lines[3]}" = "Expected 1 pod named nginx to have this value (running). Found 2." ]
}


@test "trying to find 2 PODs with the lower-case syntax" {
	run try "at most 1 times every 5s to find 2 pods named 'nginx' with 'status' being 'running'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "trying to find 2 PODs with the lower-case syntax (and a different K8s namespace)" {
	DETIK_CLIENT_NAME="mytest_with_namespace"
	DETIK_CLIENT_NAMESPACE="test_ns"
	DEBUG_DETIK="true"

	run try "at most 1 times every 5s to find 2 pods named 'nginx' with 'status' being 'running'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]

	# Running the same request with the invalid client will throw an error
	# (the namespace is not expected in this function)
	DETIK_CLIENT_NAME="mytest"
	run try "at most 1 times every 5s to find 2 pods named 'nginx' with 'status' being 'running'"
	[ "$status" -eq 3 ]
}


@test "trying to find 3 PODs with the lower-case syntax" {
	run try "at most 1 times every 5s to find 3 pods named 'nginx' with 'status' being 'running'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 4 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
	[ "${lines[3]}" = "Expected 3 pods named nginx to have this value (running). Found 2." ]
}


@test "trying to find 0 POD with the lower-case syntax" {
	run try "at most 1 times every 5s to find 0 pod named 'nginx' with 'status' being 'drinking'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is running..." ]
}


@test "trying to find 1 POD with a complex property" {
	run try "at most 1 times every 5s to find 1 pod named 'nginx' with '.status.phase' being 'running'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 4 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
	[ "${lines[3]}" = "Expected 1 pod named nginx to have this value (running). Found 2." ]
}


@test "trying to find 2 PODs with a complex property" {
	run try "at most 1 times every 5s to find 2 pods named 'nginx' with '.status.phase' being 'running'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "trying to find of a POD with upper-case letters" {
	run try "at most 5 times eVery 5s to find 2 pods named 'nginx' with 'status' being 'RUNNING'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "trying to verify the syntax check (invalid wording)" {
	run try "at most 5 times VERY 5hours to find 1 pod named 'nginx' with 'status' being 'RUNNING'"
	[ "$status" -eq 2 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "Invalid expression: it does not respect the expected syntax." ]
}


@test "trying to verify the find syntax check (missing quotes)" {
	run try "at most 5 times every 5s to find 2 pods named 'nginx' with 'status' being running"
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


@test "trying to find of a POD with the wrong value (1 attempt)" {
	run try "at most 1 times every 1s to find 1 pod named 'nginx' with 'status' being 'initializing'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 4 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is running..." ]
	[ "${lines[3]}" = "Expected 1 pod named nginx to have this value (initializing). Found 0." ]
}


@test "trying to find of a POD with the wrong value (2 attempts)" {
	run try "at most 2 times every 1s to find 1 pod named 'nginx' with 'status' being 'initializing'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 7 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is running..." ]
	[ "${lines[3]}" = "Expected 1 pod named nginx to have this value (initializing). Found 0." ]
	[ "${lines[4]}" = "Current value for nginx-deployment-75675f5897-6dg9r is running..." ]
	[ "${lines[5]}" = "Current value for nginx-deployment-75675f5897-gstkw is running..." ]
	[ "${lines[6]}" = "Expected 1 pod named nginx to have this value (initializing). Found 0." ]
}


@test "trying to find of a POD with the wrong value (3 attempts)" {
	run try "at most 3 times every 1s to find 1 pod named 'nginx' with 'status' being 'initializing'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 10 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is running..." ]
	[ "${lines[3]}" = "Expected 1 pod named nginx to have this value (initializing). Found 0." ]
	[ "${lines[4]}" = "Current value for nginx-deployment-75675f5897-6dg9r is running..." ]
	[ "${lines[5]}" = "Current value for nginx-deployment-75675f5897-gstkw is running..." ]
	[ "${lines[6]}" = "Expected 1 pod named nginx to have this value (initializing). Found 0." ]
	[ "${lines[7]}" = "Current value for nginx-deployment-75675f5897-6dg9r is running..." ]
	[ "${lines[8]}" = "Current value for nginx-deployment-75675f5897-gstkw is running..." ]
	[ "${lines[9]}" = "Expected 1 pod named nginx to have this value (initializing). Found 0." ]
}


@test "trying to find of a POD with an invalid name" {
	run try "at most 1 times every 1s to find 2 pods named 'nginx-something' with 'status' being 'running'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "No resource of type 'pods' was found with the name 'nginx-something'." ]
	[ "${lines[2]}" = "Expected 2 pods named nginx-something to have this value (running). Found 0." ]
}


@test "trying to find of a POD with a pattern name" {
	run try "at most 1 times every 1s to find 2 pods named 'ngin.*' with 'status' being 'running'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "trying to find of a POD with an invalid pattern name" {
	run try "at most 1 times every 1s to find 2 pods named 'ngin.+x' with 'status' being 'running'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "No resource of type 'pods' was found with the name 'ngin.+x'." ]
	[ "${lines[2]}" = "Expected 2 pods named ngin.+x to have this value (running). Found 0." ]
}


@test "trying to find of a POD with the lower-case syntax (multi-lines)" {
	run try "  at  most  5  times  every  5s  to  find 2  pods " \
		" named  'nginx' " \
		" with  'status'  being  'running' "

	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "trying to find of a POD with the lower-case syntax (multi-lines, without quotes)" {
	run try at  most  11  times  every  5s  to  find 2  pods \
		named  "'nginx'"  \
		with  "'status'"  being  "'running'"

	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "trying to find of a POD with the lower-case syntax (debug)" {

	debug_filename=$(basename -- "$BATS_TEST_FILENAME")
	path="/tmp/detik/$debug_filename.debug"
	[ -f "$path" ] && mv "$path" "$path.backup"
	[ ! -f "$path" ]

	# Enable the debug flag
	DEBUG_DETIK="true"
	run try "at most 5 times every 5s to find 2 pods named 'nginx' with 'status' being 'running'"

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
	echo "trying to find of a POD with the lower-case syntax (debug)" >&7
	echo "" >&7
	echo "Client query:" >&7
	echo "mytest get pods -o custom-columns=NAME:.metadata.name,PROP:.status.phase" >&7
	echo "" >&7
	echo "Result:" >&7
	echo "nginx-deployment-75675f5897-6dg9r  Running" >&7
	echo "nginx-deployment-75675f5897-gstkw  Running" >&7
	echo "" >&7
	echo "Expected count: 2" >&7
	echo "-----DETIK:end-----" >&7
	echo "" >&7

	exec 7>&-
	run diff -q "$path" "$path.cmp"
	[ "$status" -eq 0 ]
	[ "$output" = "" ]

	[ -f "$path.backup" ] && mv "$path.backup" "$path"
	rm -rf "$path.cmp"
}


@test "trying to find of a POD with the lower-case syntax (debug and a different K8s namespace)" {
	DETIK_CLIENT_NAME="mytest_with_namespace"
	DETIK_CLIENT_NAMESPACE="test_ns"

	debug_filename=$(basename -- "$BATS_TEST_FILENAME")
	path="/tmp/detik/$debug_filename.debug"
	[ -f "$path" ] && mv "$path" "$path.backup"
	[ ! -f "$path" ]

	# Enable the debug flag
	DEBUG_DETIK="true"
	run try "at most 5 times every 5s to find 2 pods named 'nginx' with 'status' being 'running'"

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
	echo "trying to find of a POD with the lower-case syntax (debug and a different K8s namespace)" >&7
	echo "" >&7
	echo "Client query:" >&7
	echo "mytest_with_namespace --namespace=test_ns get pods -o custom-columns=NAME:.metadata.name,PROP:.status.phase" >&7
	echo "" >&7
	echo "Result:" >&7
	echo "nginx-deployment-75675f5897-6dg9r  Running" >&7
	echo "nginx-deployment-75675f5897-gstkw  Running" >&7
	echo "" >&7
	echo "Expected count: 2" >&7
	echo "-----DETIK:end-----" >&7
	echo "" >&7

	exec 7>&-
	run diff -q "$path" "$path.cmp"
	[ "$status" -eq 0 ]
	[ "$output" = "" ]

	[ -f "$path.backup" ] && mv "$path.backup" "$path"
	rm -rf "$path.cmp"
}


my_consul_test() {

	consul_cpt=0
	if [[ -f /tmp/my-consul-test.txt ]]; then
		consul_cpt=$(cat /tmp/my-consul-test.txt)
	fi

	if [[ "$consul_cpt" == "2" ]]; then
		echo -e "NAME  PROP\nconsul-for-vault-0  Running\nconsul-for-vault-1  Running\nconsul-for-vault-2  Running"
	fi

	consul_cpt=$((consul_cpt + 1))
	echo "$consul_cpt" > /tmp/my-consul-test.txt
}


@test "trying to find Consul PODs" {

	DETIK_CLIENT_NAME="my_consul_test"
	rm -rf /tmp/my-consul-test.txt

	run try "at most 5 times every 1s to find 3 pods named 'consul-for-vault' with 'status' being 'running'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 8 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "No resource of type 'pods' was found with the name 'consul-for-vault'." ]
	[ "${lines[2]}" = "Expected 3 pods named consul-for-vault to have this value (running). Found 0." ]
	[ "${lines[3]}" = "No resource of type 'pods' was found with the name 'consul-for-vault'." ]
	[ "${lines[4]}" = "Expected 3 pods named consul-for-vault to have this value (running). Found 0." ]
	[ "${lines[5]}" = "consul-for-vault-0 has the right value (running)." ]
	[ "${lines[6]}" = "consul-for-vault-1 has the right value (running)." ]
	[ "${lines[7]}" = "consul-for-vault-2 has the right value (running)." ]
}
