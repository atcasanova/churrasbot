handleMessage(){
    local comando="$(echo ${1//_/ }| sed -e 's/ \+$//g' | sed "s/$BOTNAME//g")"
    offset
    echo ":$comando:"
    case "$comando" in
        /newchurras\ *)   isAdmin && newchurras ${comando//\/newchurras /};;
        /delchurras\ *)   isAdmin && delchurras ${comando//\/delchurras /};;
        /newplace\ *)     isAdmin && newplace ${comando//\/newplace /};;
        /fake\ *)         isAdmin && fake ${comando//\/fake /};;
        /email\ *)        mailEnabled && cadastraEmail ${comando//\/email /};;
        /qualchurras)     qualchurras;;
        /ranking)         ranking;;
        /help)            ajuda;;
    esac
}