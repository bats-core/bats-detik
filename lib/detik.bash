#!/bin/bash

directory=$(dirname "${BASH_SOURCE[0]}")
source "$directory/utils.bash"


# Retrieves values and attempts to compare values to an expected result (with retries).
# @param {string} A text query that respect the appropriate syntax
# @return
#	1 Empty query
#	2 Invalid syntax
#	3 The assertion could not be verified after all the attempts
#	  (may also indicate an error with the K8s client)
#	0 Everything is fine
try() {

	# Concatenate all the arguments into a single string
	IFS=' '
	exp="$*"

	# Trim the expression
	exp=$(trim "$exp")

	# Make the regular expression case-insensitive
	shopt -s nocasematch;

	# Verify the expression and use it to build a request
	if [[ "$exp" == "" ]]; then
		echo "An empty expression was not expected."
		return 1
	fi

	# Let's verify the syntax
	times=""
	delay=""
	resource=""
	name=""
	property=""
	expected_value=""
	expected_count=""
	verify_strict_equality="true"

	if [[ "$exp" =~ $try_regex_verify_is ]]; then

		# Extract parameters
		times="${BASH_REMATCH[1]}"
		delay="${BASH_REMATCH[2]}"
		resource=$(to_lower_case "${BASH_REMATCH[3]}")
		name="${BASH_REMATCH[4]}"
		property="${BASH_REMATCH[5]}"
		expected_value="${BASH_REMATCH[6]}"

	elif [[ "$exp" =~ $try_regex_verify_matches ]]; then

		# Extract parameters
		times="${BASH_REMATCH[1]}"
		delay="${BASH_REMATCH[2]}"
		resource=$(to_lower_case "${BASH_REMATCH[3]}")
		name="${BASH_REMATCH[4]}"
		property="${BASH_REMATCH[5]}"
		expected_value="${BASH_REMATCH[6]}"
		verify_strict_equality="false"

	elif [[ "$exp" =~ $try_regex_find_being ]]; then

		# Extract parameters
		times="${BASH_REMATCH[1]}"
		delay="${BASH_REMATCH[2]}"
		expected_count="${BASH_REMATCH[3]}"
		resource=$(to_lower_case "${BASH_REMATCH[4]}")
		name="${BASH_REMATCH[5]}"
		property="${BASH_REMATCH[6]}"
		expected_value="${BASH_REMATCH[7]}"

	elif [[ "$exp" =~ $try_regex_find_matching ]]; then

		# Extract parameters
		times="${BASH_REMATCH[1]}"
		delay="${BASH_REMATCH[2]}"
		expected_count="${BASH_REMATCH[3]}"
		resource=$(to_lower_case "${BASH_REMATCH[4]}")
		name="${BASH_REMATCH[5]}"
		property="${BASH_REMATCH[6]}"
		expected_value="${BASH_REMATCH[7]}"
		verify_strict_equality="false"
	fi

	# Do we have something?
	if [[ "$times" != "" ]]; then

		# Prevent line breaks from being removed in command results
		IFS=""

		# Start the loop
		echo "Valid expression. Verification in progress..."
		code=0
		for ((i=1; i<=times; i++)); do

			# Verify the value
			verify_value "$verify_strict_equality" "$property" "$expected_value" "$resource" "$name" "$expected_count" && code=$? || code=$?

			# Break the loop prematurely?
			if [[ "$code" == "0" ]]; then
				break
			elif [[ "$i" != "1" ]]; then
				code=3
				sleep "$delay"
			else
				code=3
			fi
		done

		## Error code
		return $code
	fi

	# Default behavior
	echo "Invalid expression: it does not respect the expected syntax."
	return 2
}


# Retrieves values and attempts to compare values to an expected result (without any retry).
# @param {string} A text query that respect one of the supported syntaxes
# @return
#	1 Empty query
#	2 Invalid syntax
#	3 The elements count is incorrect
#	  (may also indicate an error with the K8s client)
#	0 Everything is fine
verify() {

	# Concatenate all the arguments into a single string
	IFS=' '
	exp="$*"

	# Trim the expression
	exp=$(trim "$exp")

	# Make the regular expression case-insensitive
	shopt -s nocasematch;

	# Verify the expression and use it to build a request
	if [[ "$exp" == "" ]]; then
		echo "An empty expression was not expected."
		return 1

	elif [[ "$exp" =~ $verify_regex_count_is ]] || [[ "$exp" =~ $verify_regex_count_are ]]; then
		card="${BASH_REMATCH[1]}"
		resource=$(to_lower_case "${BASH_REMATCH[2]}")
		name="${BASH_REMATCH[3]}"

		echo "Valid expression. Verification in progress..."
		query=$(build_k8s_request "")
		client_with_options=$(build_k8s_client_with_options)
		result=$(eval $client_with_options get $resource $query | grep $name | tail -n +1 | wc -l | tr -d '[:space:]')

		# Debug?
		detik_debug "-----DETIK:begin-----"
		detik_debug "$BATS_TEST_FILENAME"
		detik_debug "$BATS_TEST_DESCRIPTION"
		detik_debug ""
		detik_debug "Client query:"
		detik_debug "$client_with_options get $resource $query"
		detik_debug ""
		detik_debug "Result:"
		detik_debug "$result"
		detik_debug "-----DETIK:end-----"
		detik_debug ""

		if [[ "$result" == "$card" ]]; then
			echo "Found $result $resource named $name (as expected)."
		else
			echo "Found $result $resource named $name (instead of $card expected)."
			return 3
		fi

	elif [[ "$exp" =~ $verify_regex_property_is ]]; then
		property="${BASH_REMATCH[1]}"
		expected_value="${BASH_REMATCH[2]}"
		resource=$(to_lower_case "${BASH_REMATCH[3]}")
		name="${BASH_REMATCH[4]}"

		echo "Valid expression. Verification in progress..."
		verify_value true "$property" "$expected_value" "$resource" "$name"

		if [[ "$?" != "0" ]]; then
			return 3
		fi

	elif [[ "$exp" =~ $verify_regex_property_matches ]]; then
		property="${BASH_REMATCH[1]}"
		expected_value="${BASH_REMATCH[2]}"
		resource=$(to_lower_case "${BASH_REMATCH[3]}")
		name="${BASH_REMATCH[4]}"

		echo "Valid expression. Verification in progress..."
		verify_value false "$property" "$expected_value" "$resource" "$name"

		if [[ "$?" != "0" ]]; then
			return 3
		fi

	else
		echo "Invalid expression: it does not respect the expected syntax."
		return 2
	fi
}


# Verifies the value of a column for a set of elements.
# @param {boolean} true to verify equality, false to match a regex
# @param {string} A K8s column or one of the supported aliases.
# @param {string} The expected value.
# @param {string} The resouce type (e.g. pod).
# @param {string} The resource name or regex.
# @param {integer} a.k.a. "expected_count": the expected number of elements having this property (optional)
# @return
# 		If "expected_count" was NOT set: the number of elements with the wrong value.
#		If "expected_count" was set: 101 if the elements count is not right, 0 otherwise.
verify_value() {

	# Make the parameters readable
	verify_strict_equality=$(to_lower_case "$1")
	property="$2"
	expected_value="$3"
	resource="$4"
	name="$5"
	expected_count="$6"

	# List the items and remove the first line (the one that contains the column names)
	query=$(build_k8s_request "$property")
	client_with_options=$(build_k8s_client_with_options)
	result=$(eval $client_with_options get $resource $query | grep $name | tail -n +1)

	# Debug?
	detik_debug "-----DETIK:begin-----"
	detik_debug "$BATS_TEST_FILENAME"
	detik_debug "$BATS_TEST_DESCRIPTION"
	detik_debug ""
	detik_debug "Client query:"
	detik_debug "$client_with_options get $resource $query"
	detik_debug ""
	detik_debug "Result:"
	detik_debug "$result"
	if [[ "$expected_count" != "" ]]; then
		detik_debug ""
		detik_debug "Expected count: $expected_count"
	fi
	detik_debug "-----DETIK:end-----"
	detik_debug ""

	# Is the result empty?
	empty=0
	if [[ "$result" == "" ]]; then
		echo "No resource of type '$resource' was found with the name '$name'."
	fi

	# Verify the result
	IFS=$'\n'
	invalid=0
	valid=0
	for line in $result; do

		# Keep the second column (property to verify)
		value=$(echo "$line" | awk '{ print $2 }')
		element=$(echo "$line" | awk '{ print $1 }')

		# Compare with an exact value (case insensitive)
		if [[ "$verify_strict_equality" == "true" ]]; then
			value=$(to_lower_case "$value")
			expected_value=$(to_lower_case "$expected_value")
			if [[ "$value" != "$expected_value" ]]; then
				echo "Current value for $element is $value..."
				invalid=$((invalid + 1))
			else
				echo "$element has the right value ($value)."
				valid=$((valid + 1))
			fi

		# Verify a regex (we preserve the case)
		else
			# We do not want another syntax for case-insensitivity
			if [ "$DETIK_REGEX_CASE_INSENSITIVE_PROPERTIES" = "true" ]; then
				value=$(to_lower_case "$value")
			fi

			reg=$(echo "$value" | grep -E "$expected_value")
			if [[ "$?" -ne 0 ]]; then
				echo "Current value for $element is $value..."
				invalid=$((invalid + 1))
			else
				echo "$element matches the regular expression (found $reg)."
				valid=$((valid + 1))
			fi
		fi
	done

	# Do we have the right number of elements?
	if [[ "$expected_count" != "" ]]; then
		if [[ "$valid" != "$expected_count" ]]; then
			if [[ "$verify_strict_equality" == "true" ]]; then
				echo "Expected $expected_count $resource named $name to have this value ($expected_value). Found $valid."
			else
				echo "Expected $expected_count $resource named $name to match this pattern ($expected_value). Found $valid."
			fi
			invalid=101
		else
			invalid=0
		fi
	# If no count expected, raise an error when 0 found items
	elif [[ "$valid" == "0" ]]; then
		invalid=102
	fi

	return $invalid
}


# Builds the request for the get operation of the K8s client.
# @param {string} A K8s column or one of the supported aliases.
# @return 0
build_k8s_request() {

	req="-o custom-columns=NAME:.metadata.name"
	if [[ "$1" == "status" ]]; then
		req="$req,PROP:.status.phase"
	elif [[ "$1" == "port" ]]; then
		req="$req,PROP:.spec.ports[*].port"
	elif [[ "$1" == "targetPort" ]]; then
		req="$req,PROP:.spec.ports[*].targetPort"
	elif [[ "$1" != "" ]]; then
		req="$req,PROP:'$1'"
	fi

	echo "$req"
}


# Builds the client command, with the option for the K8s namespace, if any.
# @return 0
build_k8s_client_with_options() {

	client_with_options="$DETIK_CLIENT_NAME"
	if [[ -n "$DETIK_CLIENT_NAMESPACE" ]]; then
		# eval does not "like" the '-n' syntax
		client_with_options="$DETIK_CLIENT_NAME --namespace=$DETIK_CLIENT_NAMESPACE"
	fi

	echo "$client_with_options"
}
