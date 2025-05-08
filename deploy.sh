#!/bin/bash

# tear down
terraform destroy -auto-approve 

# build and deploy
terraform init --upgrade
terraform apply -auto-approve