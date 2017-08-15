# Overview

Building the Conjur CE AMI happens in the following way:

It first builds a docker image that can run Ansible. This image is also configured so it can talk to AWS and CoreOS.

Then, use that image to create a docker container to build the AMI.

The first step in creating the AMI is to create a CoreOS EC2 instance.

Then, on the instance

* Pull the Conjur CE image from quay.io
* Pull the Conjur cli5 image from DockerHub
* Install a systemd description of the Conjur service, as well as a couple of scripts that will configure it when a Conjur CE instance is launched.
* Mark the Conjur service as disabled

Finally, create an AMI from the EC2 instance, which is then terminated.
