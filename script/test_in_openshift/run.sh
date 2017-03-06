#!/bin/bash

set -x;

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
source $KOMPOSE_ROOT/kompose/script/test/cmd/lib.sh
source $KOMPOSE_ROOT/script/test_in_openshift/lib.sh


convert::start_test "Functional tests on OpenShift"
install_oc_client
convert::oc_cluster_up

for test_case in $KOMPOSE_ROOT/script/test_in_openshift/tests/*; do
    $test_case
done

convert::oc_cluster_down

# if [ $result -ne 0 ]; then
#     echo "oc cluster up failed"
#     exit 1;
# fi

# oc login -u system:admin;

# # Env variables for etherpad
# export $(cat ${KOMPOSE_ROOT}/kompose/script/test/fixtures/etherpad/envs)

# # Run kompose up
# kompose --emptyvols --provider=openshift -f $KOMPOSE_ROOT/kompose/script/test/fixtures/etherpad/docker-compose.yml up; result=$?;

# if [ $result -ne 0 ]; then
#     echo "Kompose up failed"
#     exit 1;
# fi

# # Wait
# sleep 60;

# retry_up=0
# while [ "$(oc get pods | grep etherpad | grep -v deploy | awk '{ print $3 }')" != 'Running'  ] ||
# 	  [ "$(oc get pods | grep mariadb | grep -v deploy | awk '{ print $3 }')" != 'Running'  ] ;do

#     if [ $retry_up -lt 10 ]; then
# 	echo "Waiting for the pods to come up ..."
# 	retry_up=$(($retry_up + 1))
# 	sleep 30;
#     else
# 	echo "FAIL: kompose up has failed to bring the pods up"
# 	exit 1;
#     fi
# done

# # Wait
# sleep 5;

# # Check if all the pods are up
# if [ "$(oc get pods | grep etherpad | grep -v deploy | awk '{ print $3 }')" == 'Running'  ] &&
#        [ "$(oc get pods | grep mariadb | grep -v deploy | awk '{ print $3 }')" == 'Running'  ] ; then
#     echo "PASS: All pods are Running now. kompose up is successful."
#     oc get pods;
# fi

# # Run Kompose down
# echo "Running kompose down"

# kompose --provider=openshift --emptyvols -f $KOMPOSE_ROOT/kompose/script/test/fixtures/etherpad/docker-compose.yml down; result=$?;

# if [ $result -ne 0 ]; then
#     echo "Kompose down command failed"
#     exit 1;
# fi

# sleep 60;

# retry_down=0
# while [ $(oc get pods | wc -l ) != 0 ] ; do
#     if [ $retry_down -lt 10 ]; then
# 	echo "Waiting for the pods to go down ..."
# 	retry_down=$(($retry_down + 1))
# 	sleep 30;
#     else
# 	echo "FAIL: kompose down has failed to bring the pods up"
# 	exit 1;
#     fi
# done

# if [ $(oc get pods | wc -l ) == 0 ] ; then
#     echo "PASS: All pods are down now. kompose down successful."
# else
#     echo "FAIL: Kompose down failed."
#     exit 1;
# fi

# oc cluster down;
