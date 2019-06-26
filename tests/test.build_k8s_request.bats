#!/usr/bin/env bats

source ../lib/lib.sh


@test "verifying the generated request with the predefined 'status' parameter" {
	run build_k8s_request "status"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "-o custom-columns=NAME:.metadata.name,PROP:.status.phase" ]
}


@test "verifying the generated request with the predefined 'port' parameter" {
	run build_k8s_request "port"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "-o custom-columns=NAME:.metadata.name,PROP:.spec.ports[*].targetPort" ]
}


@test "verifying the generated request with no additional parameter" {
	run build_k8s_request ""
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "-o custom-columns=NAME:.metadata.name" ]
}


@test "verifying the generated request with a native column" {
	run build_k8s_request ".spec.ports[*].targetPort"
	[ "$status" -eq 0 ]
	[ ${#lines[@]} -eq 1 ]
	[ "${lines[0]}" = "-o custom-columns=NAME:.metadata.name,PROP:.spec.ports[*].targetPort" ]
}

