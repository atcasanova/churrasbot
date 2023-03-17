lembrete(){
    SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
    echo $SCRIPT_DIR
    local id="$1" data="$2" hora="$3"
    data="${data:6:4}-${data:3:2}-${data:0:2}"
    antes=$(date -d "$data $hora -03 -1 hour" +%H:%M)
#    depois=$(date -d "$data $hora -03 +2 hours" +%H:%M)
    sed "s|ID_PLACEHOLDER|$id|;s|DIR_PLACEHOLDER|$SCRIPT_DIR|" "${SCRIPT_DIR}/template_reminder.sh" > "${SCRIPT_DIR}/reminders/$id.sh"
    (sed "s|DIR_PLACEHOLDER|${SCRIPT_DIR}/reminders|" "${SCRIPT_DIR}/template_run.sh"; echo -e "bash ./$id.sh\nrm $id.sh run_$id.sh") > "${SCRIPT_DIR}/reminders/run_$id.sh"
    chmod +x "${SCRIPT_DIR}/reminders/run_$id.sh" "${SCRIPT_DIR}/reminders/$id.sh"
    echo $hora $data -f "${SCRIPT_DIR}/reminders/run_$id.sh"
    at $antes $data -f "${SCRIPT_DIR}/reminders/run_$id.sh"
    #at $depois $data -f "${SCRIPT_DIR}/reminders/run_$id.sh"
}