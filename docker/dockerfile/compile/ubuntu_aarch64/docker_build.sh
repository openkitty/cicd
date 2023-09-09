#!/bin/bash
# Copyright 2023 The Openkitty Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================

set -e

# Global parameter
IMAGE_NAME="ubuntu_aarch64"
IMAGE_VERSION="ubuntu18.04-20230909"
SWR_PREFIX="swr.cn-south-1.myhuaweicloud.com/hellokitty"
WORKSPACE=$(dirname "${BASH_SOURCE-$0}")
WORKSPACE=$(cd -P "${WORKSPACE}"; pwd -P)

# Docker build
docker build -t ${IMAGE_NAME}:${IMAGE_VERSION} ${WORKSPACE}

# Docker push
docker tag ${IMAGE_NAME}:${IMAGE_VERSION} ${SWR_PREFIX}/${IMAGE_NAME}:${IMAGE_VERSION}
docker push ${SWR_PREFIX}/${IMAGE_NAME}:${IMAGE_VERSION}
