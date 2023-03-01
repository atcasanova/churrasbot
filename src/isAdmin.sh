isAdmin(){
    for admin in ${ADMINS[@]}; do
        [ "$username" == "$admin" ] && return 0;
    done
    return 1
}