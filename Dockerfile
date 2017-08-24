FROM williamyeh/ansible:alpine3

RUN apk -v --update add openssh

RUN pip install boto boto3 botocore

RUN ansible-galaxy install defunctzombie.coreos-bootstrap