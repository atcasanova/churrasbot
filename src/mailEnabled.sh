mailEnabled(){
    [ "$EMAIL" == "yes" ] || return 1
}