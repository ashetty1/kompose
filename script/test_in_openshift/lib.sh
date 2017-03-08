#!/bin/bash

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
	exit $exit_status;
    fi

    convert::run_cmd "oc login -u system:admin"
}

function convert::oc_cluster_down () {

    convert::run_cmd "oc cluster down"
    exit_status=$?

    if [ $exit_status -ne 0 ]; then
	FAIL_MSGS=$FAIL_MSGS"exit status: $exit_status\n";
	exit $exit_status;
    fi

}

function convert::kompose_up () {
    dc_file=$1
    kompose_cli='kompose --emptyvols --provider=openshift -f $dc_file up'
    convert::run_cmd "${kompose_cli}"
    exit_status=$?

    if [ $exit_status -ne 0 ]; then
	FAIL_MSGS=$FAIL_MSGS"kompose up failed with exit status: $exit_status\n";
	exit $exit_status;
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
}

function convert::oc_cleanup () {
    oc delete bc,rc,rs,svc,is,dc,deploy,images,ds,builds --all
}
