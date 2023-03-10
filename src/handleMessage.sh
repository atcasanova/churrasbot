handleMessage(){
    offset
    comando="$(echo ${text//_/ }| sed -e 's/ \+$//g' | sed "s/$BOTNAME//g")"
    echo ":$comando:"
    case "$comando" in
        /newchurras\ *)   isAdmin && newchurras ${comando//\/newchurras /};;
        /delchurras\ *)   isAdmin && delchurras ${comando//\/delchurras /};;
        /newplace\ *)     isAdmin && newplace ${comando//\/newplace /};;
        /fake\ *)         isAdmin && fake ${comando//\/fake /};;
        /qualchurras)     qualchurras;;
        /ranking)         ranking;;
        /help)            ajuda;;
    esac
}