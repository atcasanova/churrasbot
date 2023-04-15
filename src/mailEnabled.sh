#!/bin/bash
mailEnabled(){
    [ "$EMAIL" == "yes" ] || return 1
}