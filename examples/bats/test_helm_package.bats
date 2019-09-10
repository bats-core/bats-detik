#!/usr/bin/env bats

###########################################
# An example of tests for a Helm package
# that deploys Drupal and Varnish
# instances in a K8s cluster.
###########################################

load "/home/testing/lib/detik.bash"
DETIK_CLIENT_NAME="kubectl"
pck_version="1.0.1"

setup() {
	cd $BATS_TEST_DIRNAME
}

verify_helm() {
 	helm template ../drupal | kubectl apply --dry-run -f -
}


@test "verify the linting of the chart" {

	run helm lint ../drupal
	[ "$status" -eq 0 ]
}


@test "verify the deployment of the chart in dry-run mode" {

	run verify_helm
	[ "$status" -eq 0 ]	
}


@test "package the project" {

	run helm -d /tmp package ../drupal
	# Verifying the file was created is enough
	[ -f /tmp/drupal-${pck_version}.tgz ]
}


@test "verify a real deployment" {

	[ -f /tmp/drupal-${pck_version}.tgz ]

	run helm install --name my-test \
		--set varnish.ingressHost=varnish.test.local \
		--set db.ip=10.234.121.117 \
		--set db.port=44320 \
		--tiller-namespace my-test-namespace \
		/tmp/drupal-${pck_version}.tgz

	[ "$status" -eq 0 ]
	sleep 10

	# PODs
	run verify "there is 1 pod named 'my-test-drupal'"
	[ "$status" -eq 0 ]

        run verify "there is 1 pod named 'my-test-varnish'"
        [ "$status" -eq 0 ]

	# Postgres specifics
	run verify "there is 1 service named 'my-test-postgres'"
        [ "$status" -eq 0 ]

	run verify "there is 1 ep named 'my-test-postgres'"
        [ "$status" -eq 0 ]

	run verify "'.subsets[*].ports[*].port' is '44320' for endpoints named 'my-test-postgres'"
        [ "$status" -eq 0 ]

	run verify "'.subsets[*].addresses[*].ip' is '10.234.121.117' for endpoints named 'my-test-postgres'"
        [ "$status" -eq 0 ]

	# Services
	run verify "there is 1 service named 'my-test-drupal'"
	[ "$status" -eq 0 ]

	run verify "there is 1 service named 'my-test-varnish'"
        [ "$status" -eq 0 ]

	run verify "'port' is '80' for services named 'my-test-drupal'"
	[ "$status" -eq 0 ]

	run verify "'port' is '80' for services named 'my-test-varnish'"
	[ "$status" -eq 0 ]

	# Deployments
	run verify "there is 1 deployment named 'my-test-drupal'"
	[ "$status" -eq 0 ]

	run verify "there is 1 deployment named 'my-test-varnish'"
        [ "$status" -eq 0 ]

	# Ingress
	run verify "there is 1 ingress named 'my-test-varnish'"
        [ "$status" -eq 0 ]

	run verify "'.spec.rules[*].host' is 'varnish.test.local' for ingress named 'my-test-varnish'"
        [ "$status" -eq 0 ]

	run verify "'.spec.rules[*].http.paths[*].backend.serviceName' is 'my-test-varnish' for ingress named 'my-test-varnish'"
 	[ "$status" -eq 0 ]

	# PODs should be started
	run try "at most 5 times every 30s to get pods named 'my-test-drupal' and verify that 'status' is 'running'"
	[ "$status" -eq 0 ]

        run try "at most 5 times every 30s to get pods named 'my-test-varnish' and verify that 'status' is 'running'"
        [ "$status" -eq 0 ]

	# Indicate to other tests the deployment succeeded
	echo "started" > tests.status.tmp
}


@test "verify the deployed application" {

	if [[ ! -f tests.status.tmp ]]; then
		skip " The application was not correctly deployed... "
	fi

	rm -rf /tmp.drupal.html
	curl -sL http://varnish.test.local -o /tmp/drupal.html
	[ -f ${BATS_TMPDIR}/drupal.html ]

	grep -q "<title>Choose language | Drupal</title>" /tmp/drupal.html
	grep -q "Set up database" /tmp/drupal.html
	grep -q "Install site" /tmp/drupal.html
	grep -q "Save and continue" /tmp/drupal.html
}


@test "verify the undeployment" {

	run helm del --purge my-test --tiller-namespace my-test-namespace
	[ "$status" -eq 0 ]
	[ "$output" == "release \"my-test\" deleted" ]

        run verify "there is 0 service named 'my-test'"
        [ "$status" -eq 0 ]

        run verify "there is 0 deployment named 'my-test'"
        [ "$status" -eq 0 ]

	sleep 60
        run verify "there is 0 pod named 'my-test'"
        [ "$status" -eq 0 ]
}


@test "clean the test environment" {
	rm -rf tests.status.tmp
}

