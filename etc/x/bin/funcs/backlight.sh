source $( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )/notify.sh

backlightUpdate() {
  local change="${1}"
  local cmd="brightnessctl set ${change}"
  local newVal=$(
    eval "${cmd}" | \
      grep "Current brightness" | \
      awk -F'[()]' '{print $2}'
  )

  notifySend "backlight" "Brightnesss ${newVal}"
}
