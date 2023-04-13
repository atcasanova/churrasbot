lembrete(){
    local id="$1" data="$2" hora="$3" antes job
    data="${data:6:4}-${data:3:2}-${data:0:2}"
    antes=$(date -d "$data $hora -03 -$ANTES hour" +%H:%M)

    SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
    REMINDER_DIR="${SCRIPT_DIR}/reminders"

    TEMPLATE_REMINDER="${SCRIPT_DIR}/template_reminder.sh"
    TEMPLATE_RUN="${SCRIPT_DIR}/template_run.sh"

    REMINDER_SCRIPT="${REMINDER_DIR}/${id}.sh"
    RUN_SCRIPT="${REMINDER_DIR}/run_${id}.sh"

    sed "s|ID_PLACEHOLDER|$id|;s|DIR_PLACEHOLDER|$SCRIPT_DIR|" "${TEMPLATE_REMINDER}" > "${REMINDER_SCRIPT}"
    (sed "s|DIR_PLACEHOLDER|${REMINDER_DIR}|" "${TEMPLATE_RUN}"; echo -e "\nbash ./$id.sh\nrm $id.sh run_$id.sh\n") > "${RUN_SCRIPT}"

    chmod +x "${REMINDER_SCRIPT}" "${RUN_SCRIPT}"
    job=$(at $antes $data -f "${RUN_SCRIPT}" 2>&1| grep -oP "(?<=job )[0-9]+")
    echo "#job $job" | tee -a "${RUN_SCRIPT}"
    echo "[+] REMINDER lembrete criado"
}
