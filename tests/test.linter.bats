#!/usr/bin/env bats

load "../lib/utils"
load "../lib/linter"


setup() {
	debug ""
	debug  ""
	debug  "-- $BATS_TEST_DESCRIPTION --"
	debug  ""
	debug  ""
}


@test "setup the global environment for this test" {
	reset_debug
}


@test "verifying the remove_surrounding_quotes function" {

	run remove_surrounding_quotes ""
	[ "$status" -eq 0 ]
	[ "$output" = "" ]

	run remove_surrounding_quotes "\"toto\""
	[ "$status" -eq 0 ]
	[ "$output" = "toto" ]

	run remove_surrounding_quotes "\"toto is sleeping\""
	[ "$status" -eq 0 ]
	[ "$output" = "toto is sleeping" ]

	run remove_surrounding_quotes "\"toto is \"still\" sleeping\""
	[ "$status" -eq 0 ]
	[ "$output" = "toto is \"still\" sleeping" ]

	run remove_surrounding_quotes "\"toto is \"still\" sleeping"
	[ "$status" -eq 0 ]

	run remove_surrounding_quotes "toto is \"still\" sleeping\""
	[ "$status" -eq 0 ]
}


@test "verifying the verify_against_pattern function" {

	run verify_against_pattern "toto" "toto"
	[ "$status" -eq 0 ]

	run verify_against_pattern "toto" "^toto$"
	[ "$status" -eq 0 ]

	run verify_against_pattern "\"toto\"" "^toto$"
	[ "$status" -eq 1 ]

	run verify_against_pattern "'toto'" "'toto'"
	[ "$status" -eq 0 ]

	run verify_against_pattern "\"'toto'\"" "'toto'"
	[ "$status" -eq 0 ]

	run verify_against_pattern "at most 5 times eVery 5s to GET pods named 'nginx' and verify that 'status' is 'RUNNING'" "$try_regex_verify_is"
	[ "$status" -eq 0 ]

	run verify_against_pattern "at most 5 times eVery 5s to GET pods named nginx' and verify that 'status' is 'RUNNING'" "$try_regex_verify_is"
	[ "$status" -eq 1 ]

	run verify_against_pattern "at most 5 times eVery 5s to GET pods named 'nginx' and verify that 'status' matches '^RUNNING$'" "$try_regex_verify_matches"
	[ "$status" -eq 0 ]

	run verify_against_pattern "at most 5 times eVery 5s to GET pods named nginx' and verify that 'status' matches '^RUNNING$'" "$try_regex_verify_matches"
	[ "$status" -eq 1 ]
}


@test "checking the linter with a file that does not exist" {

	run lint "/tmp/does-not-exist"
	[ "$status" -eq 1 ]
	[ "$output" = "'/tmp/does-not-exist' does not exist or is not a regular file." ]

	run lint "/tmp/"
	[ "$status" -eq 1 ]
	[ "$output" = "'/tmp/' does not exist or is not a regular file." ]
}


@test "checking the linter with a file without any error (with RUN)" {

	run lint "$BATS_TEST_DIRNAME/resources/without_lint_errors.run.txt"
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "51 DETIK queries were verified." ]
	[ "${lines[1]}" = "0 DETIK queries were found to be invalid or malformed." ]
	[ "$status" -eq 0 ]
}


@test "checking the linter with a file without any error (without RUN)" {

	run lint "$BATS_TEST_DIRNAME/resources/without_lint_errors.no.run.txt"
	[ ${#lines[@]} -eq 2 ]
	[ "${lines[0]}" = "51 DETIK queries were verified." ]
	[ "${lines[1]}" = "0 DETIK queries were found to be invalid or malformed." ]
	[ "$status" -eq 0 ]
}


@test "checking the linter with a file with lint errors on TRY to VERIFY (without RUN)" {

	run lint "$BATS_TEST_DIRNAME/resources/with_lint_errors_try_to_verify.no.run.txt"
	[ ${#lines[@]} -eq 13 ]
	[ "${lines[0]}" = "Invalid TRY statement at line 17." ]
	[ "${lines[1]}" = "Invalid TRY statement at line 21." ]
	[ "${lines[2]}" = "Invalid TRY statement at line 24." ]
	[ "${lines[3]}" = "Invalid TRY statement at line 27." ]
	[ "${lines[4]}" = "Empty statement at line 30." ]
	[ "${lines[5]}" = "Invalid TRY statement at line 41." ]
	[ "${lines[6]}" = "Invalid TRY statement at line 51." ]
	[ "${lines[7]}" = "Invalid TRY statement at line 55." ]
	[ "${lines[8]}" = "Invalid TRY statement at line 58." ]
	[ "${lines[9]}" = "Invalid TRY statement at line 61." ]
	[ "${lines[10]}" = "Invalid TRY statement at line 72." ]
	[ "${lines[11]}" = "27 DETIK queries were verified." ]
	[ "${lines[12]}" = "11 DETIK queries were found to be invalid or malformed." ]
	[ "$status" -eq 11 ]
}


@test "checking the linter with a file with lint errors on TRY to VERIFY (with RUN)" {

	run lint "$BATS_TEST_DIRNAME/resources/with_lint_errors_try_to_verify.run.txt"
	[ ${#lines[@]} -eq 13 ]
	[ "${lines[0]}" = "Invalid TRY statement at line 17." ]
	[ "${lines[1]}" = "Invalid TRY statement at line 21." ]
	[ "${lines[2]}" = "Invalid TRY statement at line 24." ]
	[ "${lines[3]}" = "Invalid TRY statement at line 27." ]
	[ "${lines[4]}" = "Empty statement at line 30." ]
	[ "${lines[5]}" = "Invalid TRY statement at line 41." ]
	[ "${lines[6]}" = "Invalid TRY statement at line 51." ]
	[ "${lines[7]}" = "Invalid TRY statement at line 55." ]
	[ "${lines[8]}" = "Invalid TRY statement at line 58." ]
	[ "${lines[9]}" = "Invalid TRY statement at line 61." ]
	[ "${lines[10]}" = "Invalid TRY statement at line 72." ]
	[ "${lines[11]}" = "27 DETIK queries were verified." ]
	[ "${lines[12]}" = "11 DETIK queries were found to be invalid or malformed." ]
	[ "$status" -eq 11 ]
}


@test "checking the linter with a file with lint errors on TRY to FIND (without RUN)" {

	run lint "$BATS_TEST_DIRNAME/resources/with_lint_errors_try_to_find.no.run.txt"
	[ ${#lines[@]} -eq 13 ]
	[ "${lines[0]}" = "Invalid TRY statement at line 17." ]
	[ "${lines[1]}" = "Invalid TRY statement at line 21." ]
	[ "${lines[2]}" = "Invalid TRY statement at line 24." ]
	[ "${lines[3]}" = "Invalid TRY statement at line 27." ]
	[ "${lines[4]}" = "Empty statement at line 30." ]
	[ "${lines[5]}" = "Invalid TRY statement at line 41." ]
	[ "${lines[6]}" = "Invalid TRY statement at line 51." ]
	[ "${lines[7]}" = "Invalid TRY statement at line 55." ]
	[ "${lines[8]}" = "Invalid TRY statement at line 58." ]
	[ "${lines[9]}" = "Invalid TRY statement at line 61." ]
	[ "${lines[10]}" = "Invalid TRY statement at line 72." ]
	[ "${lines[11]}" = "27 DETIK queries were verified." ]
	[ "${lines[12]}" = "11 DETIK queries were found to be invalid or malformed." ]
	[ "$status" -eq 11 ]
}


@test "checking the linter with a file with lint errors on TRY to FIND (with RUN)" {

	run lint "$BATS_TEST_DIRNAME/resources/with_lint_errors_try_to_find.run.txt"
	[ ${#lines[@]} -eq 13 ]
	[ "${lines[0]}" = "Invalid TRY statement at line 17." ]
	[ "${lines[1]}" = "Invalid TRY statement at line 21." ]
	[ "${lines[2]}" = "Invalid TRY statement at line 24." ]
	[ "${lines[3]}" = "Invalid TRY statement at line 27." ]
	[ "${lines[4]}" = "Empty statement at line 30." ]
	[ "${lines[5]}" = "Invalid TRY statement at line 41." ]
	[ "${lines[6]}" = "Invalid TRY statement at line 51." ]
	[ "${lines[7]}" = "Invalid TRY statement at line 55." ]
	[ "${lines[8]}" = "Invalid TRY statement at line 58." ]
	[ "${lines[9]}" = "Invalid TRY statement at line 61." ]
	[ "${lines[10]}" = "Invalid TRY statement at line 72." ]
	[ "${lines[11]}" = "27 DETIK queries were verified." ]
	[ "${lines[12]}" = "11 DETIK queries were found to be invalid or malformed." ]
	[ "$status" -eq 11 ]
}


@test "checking the linter with a file with lint errors on VERIFY (with RUN)" {

	run lint "$BATS_TEST_DIRNAME/resources/with_lint_errors_verify.run.txt"
	[ ${#lines[@]} -eq 16 ]
	[ "${lines[0]}" = "Invalid VERIFY statement at line 20." ]
	[ "${lines[1]}" = "Invalid VERIFY statement at line 25." ]
	[ "${lines[2]}" = "Invalid VERIFY statement at line 28." ]
	[ "${lines[3]}" = "Invalid VERIFY statement at line 31." ]
	[ "${lines[4]}" = "Empty statement at line 34." ]
	[ "${lines[5]}" = "Invalid VERIFY statement at line 42." ]
	[ "${lines[6]}" = "Invalid VERIFY statement at line 49." ]
	[ "${lines[7]}" = "Invalid VERIFY statement at line 52." ]
	[ "${lines[8]}" = "Invalid VERIFY statement at line 57." ]
	[ "${lines[9]}" = "Invalid VERIFY statement at line 62." ]
	[ "${lines[10]}" = "Invalid VERIFY statement at line 74." ]
	[ "${lines[11]}" = "Invalid VERIFY statement at line 77." ]
	[ "${lines[12]}" = "Invalid VERIFY statement at line 82." ]
	[ "${lines[13]}" = "Invalid VERIFY statement at line 86." ]
	[ "${lines[14]}" = "36 DETIK queries were verified." ]
	[ "${lines[15]}" = "14 DETIK queries were found to be invalid or malformed." ]
	[ "$status" -eq 14 ]
}


@test "checking the linter with a file with lint errors on VERIFY (without RUN)" {

	run lint "$BATS_TEST_DIRNAME/resources/with_lint_errors_verify.no.run.txt"
	[ ${#lines[@]} -eq 16 ]
	[ "${lines[0]}" = "Invalid VERIFY statement at line 20." ]
	[ "${lines[1]}" = "Invalid VERIFY statement at line 25." ]
	[ "${lines[2]}" = "Invalid VERIFY statement at line 28." ]
	[ "${lines[3]}" = "Invalid VERIFY statement at line 31." ]
	[ "${lines[4]}" = "Empty statement at line 34." ]
	[ "${lines[5]}" = "Invalid VERIFY statement at line 42." ]
	[ "${lines[6]}" = "Invalid VERIFY statement at line 49." ]
	[ "${lines[7]}" = "Invalid VERIFY statement at line 52." ]
	[ "${lines[8]}" = "Invalid VERIFY statement at line 57." ]
	[ "${lines[9]}" = "Invalid VERIFY statement at line 62." ]
	[ "${lines[10]}" = "Invalid VERIFY statement at line 74." ]
	[ "${lines[11]}" = "Invalid VERIFY statement at line 77." ]
	[ "${lines[12]}" = "Invalid VERIFY statement at line 82." ]
	[ "${lines[13]}" = "Invalid VERIFY statement at line 86." ]
	[ "${lines[14]}" = "36 DETIK queries were verified." ]
	[ "${lines[15]}" = "14 DETIK queries were found to be invalid or malformed." ]
	[ "$status" -eq 14 ]
}
