#!/bin/bash

# The pattern for resource types
# (pod, PODs, complex.crd.resource, ec2nodeclass, etc.)
resource_type_pattern="[a-z][0-9a-z.]+"

# The regex for the "try" key word
try_regex_verify_is="^at +most +([0-9]+) +times +every +([0-9]+)s +to +get +($resource_type_pattern) +named +'([^']+)' +and +verify +that +'([^']+)' +is +'([^']+)'$"
try_regex_verify_is_more_than="^at +most +([0-9]+) +times +every +([0-9]+)s +to +get +($resource_type_pattern) +named +'([^']+)' +and +verify +that +'([^']+)' +is more than +'([^']+)'$"
try_regex_verify_is_less_than="^at +most +([0-9]+) +times +every +([0-9]+)s +to +get +($resource_type_pattern) +named +'([^']+)' +and +verify +that +'([^']+)' +is less than +'([^']+)'$"
try_regex_verify_matches="^at +most +([0-9]+) +times +every +([0-9]+)s +to +get +($resource_type_pattern) +named +'([^']+)' +and +verify +that +'([^']+)' +matches +'([^']+)'$"
try_regex_find_being="^at +most +([0-9]+) +times +every +([0-9]+)s +to +find +([0-9]+) +($resource_type_pattern) +named +'([^']+)' +with +'([^']+)' +being +'([^']+)'$"
try_regex_find_matching="^at +most +([0-9]+) +times +every +([0-9]+)s +to +find +([0-9]+) +($resource_type_pattern) +named +'([^']+)' +with +'([^']+)' +matching +'([^']+)'$"

# The regex for the "verify" key word
verify_regex_count_is="^there +is +(0|1) +($resource_type_pattern) +named +'([^']+)'$"
verify_regex_count_are="^there +are +([0-9]+) +($resource_type_pattern) +named +'([^']+)'$"
verify_regex_count_is_less_than="^there are less than +([0-9]+) +($resource_type_pattern) +named +'([^']+)'$"
verify_regex_count_is_more_than="^there are more than +([0-9]+) +($resource_type_pattern) +named +'([^']+)'$"
verify_regex_property_is="^'([^']+)' +is +'([^']+)' +for +($resource_type_pattern) +named +'([^']+)'$"
verify_regex_property_matches="^'([^']+)' +matches +'([^']+)' +for +($resource_type_pattern) +named +'([^']+)'$"


# Prints a string in lower case.
# @param {string} The string.
# @return 0
to_lower_case() {
	echo "$1" | tr '[:upper:]' '[:lower:]'
}


# Trims a text.
# @param {string} The string.
# @return 0
trim() {
	echo $1 | sed -e 's/^[[:space:]]*([^[[:space:]]].*[^[[:space:]]])[[:space:]]*$/$1/'
}


# Trims ANSI codes (used to format strings in consoles).
# @param {string} The string.
# @return 0
trim_ansi_codes() {
	echo $1 | sed -e 's/[[:cntrl:]]\[[0-9;]*[a-zA-Z]//g'
}


# Adds a debug message for a given test.
# @param {string} The debug message.
# @return 0
debug() {
	debug_filename=$(basename -- "$BATS_TEST_FILENAME")
	mkdir -p /tmp/detik
	echo -e "$1" >> "/tmp/detik/$debug_filename.debug"
}


# Deletes the file that contains debug messages for a given test.
# @return 0
reset_debug() {
	debug_filename=$(basename -- "$BATS_TEST_FILENAME")
	rm -f "/tmp/detik/$debug_filename.debug"
}


# Adds a debug message for a given test about DETIK.
# @param {string} The debug message.
# @return 0
detik_debug() {

	if [[ "$DEBUG_DETIK" == "true" ]]; then
		debug "$1"
	fi
}


# Deletes the file that contains debug messages for a given test about DETIK.
# @return 0
reset_detik_debug() {

	if [[ "$DEBUG_DETIK" == "true" ]]; then
		reset_debug
	fi
}


# Dumps the argument and return the previous error code.
# @return the previous error code
ddump() {
	res="$?"
	echo "$1"
	return $res
}
