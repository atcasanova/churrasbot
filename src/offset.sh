#!/bin/bash
offset(){
    [[ $offset =~ ^[0-9]+$ ]] || error "parece que zoaram o offset ($offset)"
    offset=$((offset+1))
    echo ${offset:-$offset} > offset
}