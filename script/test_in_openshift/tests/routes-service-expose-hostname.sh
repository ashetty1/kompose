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

# Test case for checking kompose.service.expose construct in kompose

KOMPOSE_ROOT=$(readlink -f $(dirname "${BASH_SOURCE}")/../../..)
source $KOMPOSE_ROOT/script/test/cmd/lib.sh
source $KOMPOSE_ROOT/script/test_in_openshift/lib.sh

docker_compose_file="${KOMPOSE_ROOT}/script/test/fixtures/expose-service/compose-files/docker-compose-expose-hostname.yml"

convert::print_msg "Running tests for routes construct"

# Run kompose up
convert::kompose_up $docker_compose_file

# Check if the service has been exposed
convert::oc_check_route "batman.example.com"

# Run Kompose down
convert::kompose_down $docker_compose_file
