#!/bin/bash
#
# Copyright 2024 Kitware Inc.
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
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function shutdown
{
  docker compose \
    -f "${SCRIPT_DIR}"/docker-compose.yaml \
    --env-file "${SCRIPT_DIR}"/.env \
    --profile ollama-cli \
    down
}

trap shutdown EXIT

# Start another ollama service with network exposure attached to the same
# volume.
docker compose \
  -f "${SCRIPT_DIR}"/docker-compose.yaml \
  --env-file "${SCRIPT_DIR}"/.env \
  --profile ollama-cli \
  up -d

docker compose \
  -f "${SCRIPT_DIR}"/docker-compose.yaml \
  --env-file "${SCRIPT_DIR}"/.env \
  --profile ollama-cli \
  exec ollama-cli bash
