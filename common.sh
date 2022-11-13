#!/bin/bash

# instance-simpleimage - simple image-based OS provider for Ganeti
# Copyright (C) 2022 The Ganeti Project

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


IMAGE_STORAGE=/tmp/ganeti-instance-simpleimage
VARIANTS_PATH=/etc/ganeti/instance-simpleimage
DOWNLOAD_CACHE_MAX_DAYS=7
PROXY=
CUSTOM_CURL_OPTS=


VARIANTS_CONFIG=$VARIANTS_PATH/$OS_VARIANT/config
VARIANTS_HOOKS=$VARIANTS_PATH/$OS_VARIANT/hooks
if [[ -f "$VARIANTS_CONFIG" ]]; then
    . $VARIANTS_CONFIG
else
    echo "Variant config file '$VARIANTS_CONFIG' could not be found/read" 1>&2
    exit 1
fi

if [[ -n "$PROXY" ]]; then
    echo "Using proxy $PROXY for all HTTP(S) requests" 1>&2
    export http_proxy=$PROXY
    export HTTPS_PROXY=$PROXY
fi

if [[ -z "$IMAGE_STORAGE" ]]; then
    echo "IMAGE_STORAGE path must not be empty" 1>&2
    exit 1
fi

