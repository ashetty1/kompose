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


KOMPOSE_ROOT=$(readlink -f $(dirname "${BASH_SOURCE}")/../../..)
source $KOMPOSE_ROOT/script/test/cmd/lib.sh
source $KOMPOSE_ROOT/script/test_in_openshift/lib.sh

convert::print_msg "Running tests for ports with protocol"

# Run kompose up
kompose --provider=openshift --emptyvols -f ${KOMPOSE_ROOT}/script/test/fixtures/ports-with-proto/docker-compose.yml up; exit_status=$?

if [ $exit_status -ne 0 ]; then
    convert::print_fail "kompose up has failed"
    exit 1
fi

# Wait
sleep 60;

# convert::kompose_up_check -s "'6379/TCP,1234/UDP' '5000/TCP'"

# Run Kompose down
convert::print_msg "Running kompose down"

kompose --provider=openshift --emptyvols -f ${KOMPOSE_ROOT}/script/test/fixtures/ports-with-proto/docker-compose.yml down; exit_status=$?

if [ $exit_status -ne 0 ]; then
    convert::print_fail "Kompose down failed"
    exit 1
fi

sleep 60


convert::kompose_down_check

