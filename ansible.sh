#!/bin/bash -e

docker build -t ansible-boto .

tty=$(tty -s && echo "-t" || true)

docker run -i ${tty} --rm \
  --env-file ansible.env \
  ${SSH_KEY+-v $SSH_KEY:/root/.ssh/id_rsa} \
  -v $PWD:/ansible \
  -w /ansible \
  ansible-boto $@
