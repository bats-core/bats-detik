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


@test "trying to find 1 POD with the lower-case syntax and a simple match" {
	run try "at most 1 times every 5s to find 1 pod named 'nginx' with 'status' matching 'Running'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 4 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
	[ "${lines[3]}" = "Expected 1 pod named nginx to match this pattern (Running). Found 2." ]
}


@test "trying to find 1 POD with the exact syntax and a simple match with different case" {
	run try "at most 1 times every 2s to find 1 pod named 'nginx' with 'status' matching 'running'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 4 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is Running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is Running..." ]
	[ "${lines[3]}" = "Expected 1 pod named nginx to match this pattern (running). Found 0." ]
}


@test "trying to find 1 POD with the lower-case syntax and a simple match with case-insensitivy" {
	DETIK_REGEX_CASE_INSENSITIVE_PROPERTIES="true"
	run try "at most 1 times every 5s to find 1 pod named 'nginx' with 'status' matching 'running'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 4 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found running)." ]
	[ "${lines[3]}" = "Expected 1 pod named nginx to match this pattern (running). Found 2." ]
}


@test "trying to find 1 POD with the exact syntax and a simple match with an upper-case pattern" {
	run try "at most 1 times every 2s to find 1 pod named 'nginx' with 'status' matching '[A-Z]+$'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 4 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is Running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is Running..." ]
	[ "${lines[3]}" = "Expected 1 pod named nginx to match this pattern ([A-Z]+$). Found 0." ]
}


@test "trying to find 1 POD with the exact syntax and a simple match with a lower-case pattern" {
	run try "at most 1 times every 2s to find 1 pod named 'nginx' with 'status' matching '[A-Z][a-z]+'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 4 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
	[ "${lines[3]}" = "Expected 1 pod named nginx to match this pattern ([A-Z][a-z]+). Found 2." ]
}


@test "trying to find 1 POD with the lower-case syntax and an exact match" {
	run try "at most 1 times every 2s to find 1 pod named 'nginx' with 'status' matching '^Running$'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 4 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
	[ "${lines[3]}" = "Expected 1 pod named nginx to match this pattern (^Running$). Found 2." ]
}


@test "trying to find 2 PODs with the lower-case syntax and a partial match" {
	run try "at most 1 times every 5s to find 2 pods named 'nginx' with 'status' matching 'Run.*'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
}


@test "trying to find 2 PODs with the lower-case syntax (with a partial match and a different K8s namespace)" {
	DETIK_CLIENT_NAME="mytest_with_namespace"
	DETIK_CLIENT_NAMESPACE="test_ns"
	DEBUG_DETIK="true"

	run try "at most 1 times every 5s to find 2 pods named 'nginx' with 'status' matching '.*ing'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]

	# Running the same request with the invalid client will throw an error
	# (the namespace is not expected in this function)
	DETIK_CLIENT_NAME="mytest"
	run try "at most 1 times every 5s to find 2 pods named 'nginx' with 'status' matching 'Running'"
	[ "$status" -eq 3 ]
}


@test "trying to find 3 PODs with the lower-case syntax and a partial match" {
	run try "at most 1 times every 5s to find 3 pods named 'nginx' with 'status' matching 'Ru.+ng'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 4 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
	[ "${lines[3]}" = "Expected 3 pods named nginx to match this pattern (Ru.+ng). Found 2." ]
}


@test "trying to find 0 POD with the lower-case syntax and a pattern match" {
	run try "at most 1 times every 5s to find 0 pod named 'nginx' with 'status' matching '^drinking'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is Running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is Running..." ]
}


@test "trying to find 1 POD with a complex property and a pattern match" {
	run try "at most 1 times every 5s to find 1 pod named 'nginx' with '.status.phase' matching 'R.nn.ng'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 4 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
	[ "${lines[3]}" = "Expected 1 pod named nginx to match this pattern (R.nn.ng). Found 2." ]
}


@test "trying to find 2 PODs with a complex property and a pattern match" {
	run try "at most 1 times every 5s to find 2 pods named 'nginx' with '.status.phase' matching 'Run{2}ing'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
}


@test "trying to verify the syntax check (invalid wording, with a pattern match)" {
	run try "at most 5 times VERY 5hours to find 1 pod named 'nginx' with 'status' matching '^RUNNING'"
	[ "$status" -eq 2 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "Invalid expression: it does not respect the expected syntax." ]
}


@test "trying to verify the find syntax check (missing quotes, with a pattern match)" {
	run try "at most 5 times every 5s to find 2 pods named 'nginx' with 'status' matching Running"
	[ "$status" -eq 2 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "Invalid expression: it does not respect the expected syntax." ]
}


@test "trying to find of a POD with the wrong value and a match (1 attempt)" {
	run try "at most 1 times every 1s to find 1 pod named 'nginx' with 'status' matching 'initializing'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 4 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is Running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is Running..." ]
	[ "${lines[3]}" = "Expected 1 pod named nginx to match this pattern (initializing). Found 0." ]
}


@test "trying to find of a POD with the wrong value and a match (2 attempts)" {
	run try "at most 2 times every 1s to find 1 pod named 'nginx' with 'status' matching 'initializing'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 7 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is Running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is Running..." ]
	[ "${lines[3]}" = "Expected 1 pod named nginx to match this pattern (initializing). Found 0." ]
	[ "${lines[4]}" = "Current value for nginx-deployment-75675f5897-6dg9r is Running..." ]
	[ "${lines[5]}" = "Current value for nginx-deployment-75675f5897-gstkw is Running..." ]
	[ "${lines[6]}" = "Expected 1 pod named nginx to match this pattern (initializing). Found 0." ]
}


@test "trying to find of a POD with the wrong value and a match (3 attempts)" {
	run try "at most 3 times every 1s to find 1 pod named 'nginx' with 'status' matching 'initializing'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 10 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is Running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is Running..." ]
	[ "${lines[3]}" = "Expected 1 pod named nginx to match this pattern (initializing). Found 0." ]
	[ "${lines[4]}" = "Current value for nginx-deployment-75675f5897-6dg9r is Running..." ]
	[ "${lines[5]}" = "Current value for nginx-deployment-75675f5897-gstkw is Running..." ]
	[ "${lines[6]}" = "Expected 1 pod named nginx to match this pattern (initializing). Found 0." ]
	[ "${lines[7]}" = "Current value for nginx-deployment-75675f5897-6dg9r is Running..." ]
	[ "${lines[8]}" = "Current value for nginx-deployment-75675f5897-gstkw is Running..." ]
	[ "${lines[9]}" = "Expected 1 pod named nginx to match this pattern (initializing). Found 0." ]
}


@test "trying to find of a POD with an invalid name and a pattern match" {
	run try "at most 1 times every 1s to find 2 pods named 'nginx-something' with 'status' matching 'R.*g'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "No resource of type 'pods' was found with the name 'nginx-something'." ]
	[ "${lines[2]}" = "Expected 2 pods named nginx-something to match this pattern (R.*g). Found 0." ]
}


@test "trying to find of a POD with a pattern name and pattern match" {
	run try "at most 1 times every 1s to find 2 pods named 'ngin.*' with 'status' matching 'Run.+'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
}


@test "trying to find of a POD with an invalid pattern name and a pattern match" {
	run try "at most 1 times every 1s to find 2 pods named 'ngin.+x' with 'status' matching 'Running'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "No resource of type 'pods' was found with the name 'ngin.+x'." ]
	[ "${lines[2]}" = "Expected 2 pods named ngin.+x to match this pattern (Running). Found 0." ]
}


@test "trying to find of a POD with the lower-case syntax (multi-lines and pattern matching)" {
	run try "  at  most  5  times  every  5s  to  find 2  pods " \
		" named  'nginx' " \
		" with  'status'  matching  '^Running$' "

	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
}


@test "trying to find of a POD with the lower-case syntax (multi-lines and pattern matching, without quotes)" {
	run try at  most  11  times  every  5s  to  find 2  pods \
		named  "'nginx'"  \
		with  "'status'"  matching  "'^Running$'"

	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r matches the regular expression (found Running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw matches the regular expression (found Running)." ]
}


@test "trying to find of a POD with the lower-case syntax (debug matching)" {

	debug_filename=$(basename -- "$BATS_TEST_FILENAME")
	path="/tmp/detik/$debug_filename.debug"
	[ -f "$path" ] && mv "$path" "$path.backup"
	[ ! -f "$path" ]

	# Enable the debug flag
	DEBUG_DETIK="true"
	run try "at most 5 times every 5s to find 2 pods named 'nginx' with 'status' matching '^[[:alnum:]]+$'"

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
	echo "trying to find of a POD with the lower-case syntax (debug matching)" >&7
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


@test "trying to find of a POD with the lower-case syntax (debug matching and a different K8s namespace)" {
	DETIK_CLIENT_NAME="mytest_with_namespace"
	DETIK_CLIENT_NAMESPACE="test_ns"

	debug_filename=$(basename -- "$BATS_TEST_FILENAME")
	path="/tmp/detik/$debug_filename.debug"
	[ -f "$path" ] && mv "$path" "$path.backup"
	[ ! -f "$path" ]

	# Enable the debug flag
	DEBUG_DETIK="true"
	run try "at most 5 times every 5s to find 2 pods named 'nginx' with 'status' matching '^[[:alnum:]]+$'"

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
	echo "trying to find of a POD with the lower-case syntax (debug matching and a different K8s namespace)" >&7
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


@test "trying to find Consul PODs with a match" {

	DETIK_CLIENT_NAME="my_consul_test"
	rm -rf /tmp/my-consul-test.txt

	run try "at most 5 times every 1s to find 3 pods named 'consul-for-vault' with 'status' matching 'R.nn.ng'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 8 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "No resource of type 'pods' was found with the name 'consul-for-vault'." ]
	[ "${lines[2]}" = "Expected 3 pods named consul-for-vault to match this pattern (R.nn.ng). Found 0." ]
	[ "${lines[3]}" = "No resource of type 'pods' was found with the name 'consul-for-vault'." ]
	[ "${lines[4]}" = "Expected 3 pods named consul-for-vault to match this pattern (R.nn.ng). Found 0." ]
	[ "${lines[5]}" = "consul-for-vault-0 matches the regular expression (found Running)." ]
	[ "${lines[6]}" = "consul-for-vault-1 matches the regular expression (found Running)." ]
	[ "${lines[7]}" = "consul-for-vault-2 matches the regular expression (found Running)." ]
}
