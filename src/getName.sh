#!/bin/bash
getName(){
    local id="$1"
    grep -m1 "$id:" members | cut -f2 -d:
}

getId(){
    local username="$1"
    grep -m1 ":$username$" members | cut -f1 -d:
}