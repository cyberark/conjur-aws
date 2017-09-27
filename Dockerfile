FROM williamyeh/ansible:alpine3

RUN apk -v --update add openssh curl groff

RUN pip install boto boto3 botocore awscli

RUN ansible-galaxy install defunctzombie.coreos-bootstrap
