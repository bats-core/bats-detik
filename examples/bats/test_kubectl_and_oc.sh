#!/bin/bash

###########################################
# A set of examples using DETIK functions.
###########################################

load ../lib/detik

# The client function.
DETIK_CLIENT_NAME="kubectl"


#########################################
# Counting objects
#########################################

# Basic examples
verify "there are 1 service named 'nginx'"
verify "there are 4 pods named 'nginx'"
verify "there are more than 2 pods named 'nginx'"
verify "there are less than 5 pods named 'nginx'"

# The same thing (it is case insensitive)
verify "There are 4 pods naMed 'nginx'"

# Use short names for resources ('po' instead of 'pods')
# See https://kubernetes.io/docs/reference/kubectl/overview/#resource-types
verify "there are 4 po named 'nginx'"

# Use a regular expression for the name
verify "there are 4 po named 'nginx.*'"


#########################################
# Verifying properties
#########################################

# Basic example
verify "'status' is 'running' for pods named 'nginx'"

# The same thing (it is case insensitive)
verify "'status' is 'RUNNING' for pods naMed 'nginx'"

# Use short names for resources ('po' instead of 'pods')
# See https://kubernetes.io/docs/reference/kubectl/overview/#resource-types
verify "'status' is 'running' for po named 'nginx'"

# Use a regular expression for the name
verify "'status' is 'running' for pods named 'nginx.*'"

# You can also use column names
# Use kubectl get <resource> -o custom-columns=ALL:* to find column names.
verify "'.status.phase' is 'running' for pods named 'nginx'"
verify "'.spec.ports[*].targetPort' is '8484' for services named 'nginx'"


#########################################
# Verifying properties (with retries)
#########################################

# Basic example
try "at most 5 times every 5s to get pods named 'nginx' and verify that 'status' is 'running'"

# The same thing (it is case insensitive)
try "at most 5 times every 15s to GET pods named 'nginx' and verify that 'status' is 'RUNNING'"

# Basic examples with more/less than
try "at most 5 times every 5s to get deploy named 'nginx' and verify that 'status.currentReplicas' is more than '1'"
try "at most 5 times every 5s to get deploy named 'nginx' and verify that 'status.currentReplicas' is less than '3'"

# Use short names for resources ('po' instead of 'pods')
# See https://kubernetes.io/docs/reference/kubectl/overview/#resource-types
try "at most 5 times every 5s to get po named 'nginx' and verify that 'status' is 'running'"

# Use a regular expression for the name
try "at most 2 times every 30s to get po named '^ng.*nx' and verify that 'status' is 'running'"

# You can also use column names
# Use kubectl get <resource> -o custom-columns=ALL:* to find column names.
try "at most 2 times every 30s to get po named 'nginx' and verify that '.status.phase' is 'running'"
try "at most 2 times every 30s to get svc named 'nginx' and verify that '.spec.ports[*].targetPort' is '8484'"


#########################################
# Formatting
#########################################

# Splitting a request over several lines
try "at most 2 times every 30s "\
	"to get svc named 'nginx' and "\
	"verify that '.spec.ports[*].targetPort' is '8484'"

# Using quotes differently
# (make sure to surround single quotes by double ones)
try at most 2 times every 30s \
	to get svc named "'nginx'" and \
	verify that "'.spec.ports[*].targetPort'" is "'8484'"

