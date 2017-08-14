FROM williamyeh/ansible:alpine3-onbuild

RUN apk -v --update add openssh

RUN pip install boto

RUN ansible-galaxy install defunctzombie.coreos-bootstrap