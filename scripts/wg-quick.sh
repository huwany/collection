#!/bin/sh

LIST=`ls -1 /usr/local/etc/wireguard |grep '.conf$'|cut -d. -f1`

status(){
  echo "==========status======="
  sudo wg
}

up() {
  echo "==========up===========";
  for i in $LIST;do sudo wg-quick up $i;done
}

down() {
  echo "===========down============";
  for i in $LIST;do sudo wg-quick down $i;done
}

reup() {
  down $1;
  echo "sleeping.........";
  sleep 1;
  up $1;
}

usage(){
  echo "Usage: $0 {up|down|reup|status} [<all>, <wireguard name>]"
  exit 1

}

case "$1" in
  'up')
    up
  ;;
  'down')
    down
  ;;
  'status')
    status
  ;;
  'reup')
    reup
  ;;
  '--help')
    usage
  ;;
  *)
    usage
  ;;
esac

#
# eof.
#
