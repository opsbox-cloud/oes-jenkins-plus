#!/bin/bash

. .env

eval "cat <<EOF
$(cat "$1")
EOF
"
