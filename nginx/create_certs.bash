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
# -----------------------------------------------------------------------------
#
# Helper script to start the process of generating the required certificate and
# additional dhparams files.
#
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
  -keyout "${SCRIPT_DIR}"/nginx-selfsigned.key -out "${SCRIPT_DIR}"/nginx-selfsigned.crt
chmod 400 "${SCRIPT_DIR}"/nginx-selfsigned.key "${SCRIPT_DIR}"/nginx-selfsigned.crt

>&2 echo "Creating custom dhparam.pem 4096 file. This may take a while..."
openssl dhparam -out "${SCRIPT_DIR}"/dhparam.pem 4096
chmod 400 "${SCRIPT_DIR}"/dhparam.pem
