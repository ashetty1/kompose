#!/bin/bash

function convert::oc_cluster_up () {

    convert::run_cmd "oc cluster up"
    exit_status=$?

    if [ $exit_status -ne 0 ]; then
	FAIL_MSGS=$FAIL_MSGS"exit status: $exit_status\n";
	return $exit_status;
    fi
    
}
