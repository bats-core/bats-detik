#!/usr/bin/env bats

source "lib/lib.sh"


CLIENT_NAME="mytest"
mytest() {
	echo -e "NAME  PROP\nnginx-deployment-75675f5897-6dg9r  Running\nnginx-deployment-75675f5897-gstkw  Running"
}


@test "verifying the status of a POD with the lower-case syntax" {
	run try "at most 5 times every 5s to get pods named 'nginx' and verify that 'status' is 'running'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "verifying the status of a POD with a complex property" {
	run try "at most 5 times every 5s to get pods named 'nginx' and verify that '.status.phase' is 'running'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "verifying the status of a POD with upper-case letters" {
	run try "at most 5 times eVery 5s to GET pods named 'nginx' and verify that 'status' is 'RUNNING'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "verifying the syntax check (invalid wording)" {
	run try "at most 5 times VERY 5hours to GET pods named 'nginx' and verify that 'status' is 'RUNNING'"
	[ "$status" -eq 2 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "Invalid expression: it does not respect the expected syntax." ]
}


@test "verifying the syntax check (missing quotes)" {
	run try "at most 5 times every 5s to get pods named 'nginx' and verify that 'status' is running"
	[ "$status" -eq 2 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "Invalid expression: it does not respect the expected syntax." ]
}


@test "verifying the syntax check (empty query)" {
	run try ""
	[ "$status" -eq 1 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "An empty expression was not expected." ]
}


@test "verifying the status of a POD with the wrong value (1 attempt)" {
	run try "at most 1 times every 1s to get pods named 'nginx' and verify that 'status' is 'initializing'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is running..." ]
}


@test "verifying the status of a POD with the wrong value (2 attempts)" {
	run try "at most 2 times every 1s to get pods named 'nginx' and verify that 'status' is 'initializing'"
	[ "$status" -eq 3 ]
	[ ${#lines[@]} -eq 5 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "Current value for nginx-deployment-75675f5897-6dg9r is running..." ]
	[ "${lines[2]}" = "Current value for nginx-deployment-75675f5897-gstkw is running..." ]
	[ "${lines[3]}" = "Current value for nginx-deployment-75675f5897-6dg9r is running..." ]
	[ "${lines[4]}" = "Current value for nginx-deployment-75675f5897-gstkw is running..." ]
}


@test "verifying the status of a POD with the wrong value (3 attempts)" {
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


@test "verifying the status of a POD with an invalid name" {
	run try "at most 1 times every 1s to get pods named 'nginx-something' and verify that 'status' is 'running'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "No resource of type 'pods' was found with the name 'nginx-something'." ]
}


@test "verifying the status of a POD with a pattern name" {
	run try "at most 1 times every 1s to get pods named 'ngin.*' and verify that 'status' is 'running'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 3 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "nginx-deployment-75675f5897-6dg9r has the right value (running)." ]
	[ "${lines[2]}" = "nginx-deployment-75675f5897-gstkw has the right value (running)." ]
}


@test "verifying the status of a POD with an invalid pattern name" {
	run try "at most 1 times every 1s to get pods named 'ngin.+x' and verify that 'status' is 'running'"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "Valid expression. Verification in progress..." ]
	[ "${lines[1]}" = "No resource of type 'pods' was found with the name 'ngin.+x'." ]
}

