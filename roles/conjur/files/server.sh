#!/bin/sh -e

cmd="$1"; shift

set -a
. /etc/default/conjur

run() {
  docker run --rm \
    -e CONJUR_DATA_KEY \
    -e DATABASE_URL \
    -e RAILS_ENV \
    -e CONJUR_ACCOUNT \
    conjur "$@"
}

migrate() {
  run db migrate
}

create() {
  docker rm -f conjur || true

  migrate

  run account create $CONJUR_ACCOUNT || true

  docker create \
    --name conjur \
    --restart always \
    -p 80:80 \
    -e CONJUR_DATA_KEY \
    -e DATABASE_URL \
    -e RAILS_ENV \
    -e CONJUR_ACCOUNT \
    conjur server

  systemctl enable conjur
  systemctl restart conjur
}

wait_for_server() {
  for i in `seq 1 10`; do
    curl -fs -X OPTIONS http://localhost >/dev/null && break
    sleep 2
  done

  # This will fail if the server didn't come up
  curl -f -X OPTIONS http://localhost
}

start() {
  migrate

  docker start -a conjur 

  docker attach conjur
}

stop() {
  docker stop conjur || true
}

restart() {
  stop
  start
}

case "$cmd" in
  create)
    create
    ;;
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  wait_for_server)
    wait_for_server
    ;;
  *)
    echo "Usage: $0 {create|start|stop|restart}"
    exit 1
esac
