#!/bin/bash

dnf install python3.11-pip -y
pip3.11 install botocore boto3
ansible-pull -i localhost, -U https://github.com/yamunasreeoggu/infra_ansible main.yml -e role_name=${role_name}
