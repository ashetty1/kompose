#!/bin/bash

# Copyright 2017 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


function convert::print_msg () {
    echo ""
    tput setaf 4
    tput bold
    echo -e "$@"
    tput sgr0
    echo ""
}

function install_oc_client () {
    sudo sed -i 's:DOCKER_OPTS=":DOCKER_OPTS="--insecure-registry 172.30.0.0/16 :g' /etc/default/docker
    sudo mv /bin/findmnt /bin/findmnt.backup
    sudo cat /etc/default/docker
    sudo /etc/init.d/docker restart
    # FIXME
    wget https://github.com/openshift/origin/releases/download/v1.4.1/openshift-origin-client-tools-v1.4.1-3f9807a-linux-64bit.tar.gz -O /tmp/oc.tar.gz 2> /dev/null > /dev/null
    mkdir /tmp/ocdir && cd /tmp/ocdir && tar -xvvf /tmp/oc.tar.gz > /dev/null
    sudo mv /tmp/ocdir/*/oc /usr/bin/
}


function convert::oc_cluster_up () {

    convert::run_cmd "oc cluster up"
    exit_status=$?

    if [ $exit_status -ne 0 ]; then
	FAIL_MSGS=$FAIL_MSGS"exit status: $exit_status\n";
	convert::print_fail "oc cluster up failed"
	exit $exit_status
    fi

    convert::run_cmd "oc login -u system:admin"
}

function convert::oc_cluster_down () {

    convert::run_cmd "oc cluster down"
    exit_status=$?

    if [ $exit_status -ne 0 ]; then
	FAIL_MSGS=$FAIL_MSGS"exit status: $exit_status\n"
	exit $exit_status
    fi

}

function convert::kompose_up () {
    dc_file=$1
    kompose_cli='kompose --emptyvols --provider=openshift -f $dc_file up'
    convert::run_cmd "${kompose_cli}"
    exit_status=$?

    if [ $exit_status -ne 0 ]; then
	FAIL_MSGS=$FAIL_MSGS"kompose up failed with exit status: $exit_status\n"
	exit $exit_status
    fi
}

function convert::kompose_down () {
    dc_file=$1
    kompose_cli='kompose --emptyvols --provider=openshift -f $dc_file down'
    convert::run_cmd $kompose_cli
    exit_status=$?

    if [ $exit_status -ne 0 ]; then
	FAIL_MSGS=$FAIL_MSGS"kompose down failed with exit status: $exit_status\n";
	exit $exit_status;
    fi
}


function convert::kompose_up_check () {
    # Usage: -p for pod name, -r replica count
    local retry_up=0
   
    while getopts ":p:r:" opt; do
	case $opt in
	    p ) pod=$OPTARG;;
	    r ) replica=$OPTARG;;
	esac
    done

    if [ -z $replica ]; then
       replica_1=1
       replica_2=1
    else
       replica_1=$replica
       replica_2=$replica
    fi

    echo $pod
    
    pod_1=$( echo $pod | awk '{ print $1 }')
    pod_2=$( echo $pod | awk '{ print $2 }')
    
    query_1='grep ${pod_1} | grep -v deploy'
    query_2='grep ${pod_2} | grep -v deploy'
    
    query_1_status='Running'
    query_2_status='Running'
    
    is_buildconfig=$(oc get builds --no-headers | wc -l)

    if [ $is_buildconfig -gt 0 ]; then
	query_1='grep ${pod_1} | grep -v deploy | grep -v build'
	query_2='grep build | grep -v deploy'
	query_2_status='Completed'
	replica_2=1 
    fi
    
    # FIXME: Make this generic to cover all cases
    while [ $(oc get pods | eval ${query_1} | awk '{ print $3 }' | \
		     grep ${query_1_status} | wc -l) -ne $replica_1 ] ||
	      [ $(oc get pods | eval ${query_2} | awk '{ print $3 }' | \
			 grep ${query_2_status} | wc -l) -ne $replica_2 ]; do

	if [ $retry_up -lt 10 ]; then
	    echo "Waiting for the pods to come up ..."
	    retry_up=$(($retry_up + 1))
	    sleep 30
	else
	    convert::print_fail "kompose up has failed to bring the pods up"
	    exit 1
	fi
	
    done

    # Wait
    sleep 5

    # If pods are up, print a success message
    if [ $(oc get pods | eval ${query_1} | awk '{ print $3 }' | \
		  grep ${query_1_status} | wc -l) -eq $replica_1 ] &&
	   [ $(oc get pods | eval ${query_2} | awk '{ print $3 }' | \
		      grep ${query_2_status} | wc -l) -eq $replica_2 ]; then
	oc get pods
	convert::print_pass "All pods are Running now. kompose up is successful."
    fi
}

function convert::kompose_down_check () {
    retry_down=0
    while [ $(oc get pods | wc -l ) != 0 ] ; do
	if [ $retry_down -lt 10 ]; then
	    echo "Waiting for the pods to go down ..."
	    oc get pods
	    retry_down=$(($retry_down + 1))
	    sleep 30;
	else
	    convert::print_fail "kompose down has failed"
	    exit 1;
	fi
    done

    # Wait
    sleep 5;

    # Print a message if all the pods are down
    if [ $(oc get pods | wc -l ) == 0 ] ; then
	convert::print_pass "All pods are down now. kompose down successful."
    fi
}

function convert::oc_cleanup () {
    oc delete bc,rc,rs,svc,is,dc,deploy,images,ds,builds --all
}

