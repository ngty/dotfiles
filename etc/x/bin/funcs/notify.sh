notifySend() {
  local name="${1}"
  local msg="${2}"
  local ttl=${3:-1000}
  local tracker=/tmp/notify-$(whoami)/${name}
  local nid

  if [ "$( type notify-send 2>/dev/null | wc -l )x" = "1x" ]; then
    mkdir -p $( dirname ${tracker} )

    nid=$( cat ${tracker} 2>/dev/null )

    if [ "${nid}x" != "x" ]; then
      nid=$( notify-send -p -r ${nid} -t ${ttl} "${msg}" )
    else
      nid=$( notify-send -p -t ${ttl} "${msg}" )
    fi

    echo -n ${nid} > ${tracker}
  fi
}
