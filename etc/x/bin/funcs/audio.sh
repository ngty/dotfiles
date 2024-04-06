source $( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )/notify.sh

audioUpdate() {
  local change="${1}"
  local cmd="pactl set-sink-volume @DEFAULT_SINK@ ${change}"
  local newVal=$(
    eval "${cmd}"; \
      pactl get-sink-volume @DEFAULT_SINK@ | \
      head -n1 | \
      awk '{print $5}'
  )

  pactl set-source-volume @DEFAULT_SOURCE@ ${newVal}

  notifySend "audio" "Audio Volume: ${newVal}"
}
