#!/bin/sh -e
# Control script for Conjur service on a Conjur CE AMI.
#
# Called by userdata script to intialize the service, as well as by systemd to manage it.

set -a
. /etc/default/conjur

# Handle command line.
main() {
  cmd="$1"; shift
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
      echo "Usage: $0 {create|start|stop|restart|wait_for_server}"
      exit 1
  esac
}

# Run database migrations, create the admin account (if neccessary), start the container, and start the service.
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

# Run db migrations, start the container
start() {
  migrate

  docker start -a conjur 

  docker attach conjur
}

# Stop the container, ok if it's already down.
stop() {
  docker stop conjur || true
}

# Stop and start the container.
restart() {
  stop
  start
}

# Wait for the container to be ready to process requests
wait_for_server() {
  for i in `seq 1 10`; do
    curl -fs -X OPTIONS http://localhost >/dev/null && break
    sleep 2
  done

  # Fail if the server really didn't come up
  curl -f -X OPTIONS http://localhost
}

### Internal functions

# Start a container with the appropriate environment to run a command
run() {
  docker run --rm \
    -e CONJUR_DATA_KEY \
    -e DATABASE_URL \
    -e RAILS_ENV \
    -e CONJUR_ACCOUNT \
    conjur "$@"
}

# Run database migrations
migrate() {
  run db migrate
}

# Here we go....
main "$@"
