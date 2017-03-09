#!/bin/bash

# Copyright 2017 The Kubernetes Authors.
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

# Test case for kompose up/down with etherpad

KOMPOSE_ROOT=$(readlink -f $(dirname "${BASH_SOURCE}")/../../..)
source $KOMPOSE_ROOT/script/test/cmd/lib.sh
source $KOMPOSE_ROOT/script/test_in_openshift/lib.sh

convert::print_msg "Running tests for replica option"

# Run kompose up
kompose --provider=openshift --emptyvols --replicas 2 -f ${KOMPOSE_ROOT}/examples/docker-compose.yml up; exit_status=$?

if [ $exit_status -ne 0 ]; then
    convert::print_fail "kompose up has failed"
    exit 1;
fi

# Wait
sleep 60;

retry_up=0

# 2 is the replica count
while [ "$(oc get pods | grep redis | grep -v deploy | awk '{ print $3 }' | grep 'Running' | wc -l)" -ne 2 ] || [ "$(oc get pods | grep web | grep -v deploy | awk '{ print $3 }' | grep 'Running' | wc -l)" -ne 2  ] ;do

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
sleep 5;

# Check if all the pods are up

if [ "$(oc get pods | grep redis | grep -v deploy |  awk '{ print $3 }'| grep 'Running' | wc -l)" -eq 2  ] && [ "$(oc get pods | grep web | grep -v deploy | awk '{ print $3 }' | grep 'Running' | wc -l)" -eq 2  ] ; then
    convert::print_msg "oc get pods:"
    oc get pods
    convert::print_pass "All pods are Running now. kompose up is successful with 2 replicas."
fi

# Run Kompose down
convert::print_msg "Running kompose down"

kompose --provider=openshift --emptyvols --replicas 2 -f ${KOMPOSE_ROOT}/examples/docker-compose.yml down; exit_status=$?

if [ $exit_status -ne 0 ]; then
    convert::print_fail "Kompose down failed"
    exit 1;
fi

sleep 60

convert::kompose_down_check

if [ $(oc get pods | wc -l ) == 0 ] ; then
    convert::print_pass "All pods are down now. kompose down successful."
fi


