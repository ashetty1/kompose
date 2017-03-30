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

convert::print_msg "Testing kompose up/down with etherpad docker-compose file"

# Env variables for etherpad
export $(cat ${KOMPOSE_ROOT}/script/test/fixtures/etherpad/envs)

# Run kompose up
kompose --emptyvols --provider=openshift -f ${KOMPOSE_ROOT}/script/test/fixtures/etherpad/docker-compose.yml up; exit_status=$?

if [ $exit_status -ne 0 ]; then
    convert::print_fail "kompose up fails"
    exit 1
fi

# Wait
sleep 10

# Check if the pods are up
convert::kompose_up_check -p "etherpad mariadb"


# Run Kompose down
convert::print_msg "Running kompose down"

kompose --provider=openshift --emptyvols -f $KOMPOSE_ROOT/script/test/fixtures/etherpad/docker-compose.yml down; exit_status=$?

if [ $exit_status -ne 0 ]; then
    convert::print_fail "kompose down failed"
    exit 1
fi

sleep 10

convert::kompose_down_check

