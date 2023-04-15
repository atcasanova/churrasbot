#!/bin/bash
error(){
    local erro="$1"
    echo "[-] ERROR $erro"
    exit 99
}
