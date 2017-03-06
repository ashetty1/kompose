#!/bin/bash

function install_oc_client () {
    sudo apt-get install wget -y
    sudo sed -i 's:DOCKER_OPTS=":DOCKER_OPTS="--insecure-registry 172.30.0.0/16 :g' /etc/default/docker
    sudo mv /bin/findmnt /bin/findmnt.backup
    sudo cat /etc/default/docker
    sudo /etc/init.d/docker restart;
    # FIXME
    wget https://github.com/openshift/origin/releases/download/v1.4.1/openshift-origin-client-tools-v1.4.1-3f9807a-linux-64bit.tar.gz -O /tmp/oc.tar.gz
    mkdir /tmp/ocdir && cd /tmp/ocdir && tar -xvvf /tmp/oc.tar.gz
    sudo mv /tmp/ocdir/*/oc /usr/bin/
}


function convert::oc_cluster_up () {

    convert::run_cmd "oc cluster up"
    exit_status=$?

    if [ $exit_status -ne 0 ]; then
	FAIL_MSGS=$FAIL_MSGS"exit status: $exit_status\n";
	return $exit_status;
    fi

    oc login -u system:admin
}

function convert::oc_cluster_down () {

    convert::run_cmd "oc cluster down"
    exit_status=$?

    if [ $exit_status -ne 0 ]; then
	FAIL_MSGS=$FAIL_MSGS"exit status: $exit_status\n";
	return $exit_status;
    fi

}

# function retry () {
#     local retry=0
#     local retry_count=10
#     if [ $retry -lt $retry_count ]; then
# 	echo
# 	sleep 10;
# }

# function convert::check_pods_up () {
#     local arg_count=$#
#     pod_1=$1
#     pod
#     if [ $arg_count > 2 ] || [ $arg_count < 2 ]; then
# 	exit 1;
#     fi
    
#     while [ "$(oc get pods | grep ${pod} | grep -v deploy | awk '{ print $3 }')"
# 	    != 'Running' ]; do
# 	if [ $retry_up -lt 10 ]; then
# 	   echo "Waiting for the pods to come up ..."
# 	   retry_up=$(($retry_up + 1))
# 	   sleep 30
# 	else
# 	   convert::print_fail "FAIL: kompose up has failed to bring the pods up"
# 	   exit 1
# 	fi
#     done
# }
