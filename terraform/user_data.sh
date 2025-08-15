#!/bin/bash
apt update -y
apt install -y git curl

cd /home/ubuntu
git clone https://github.com/user/platforma-monitorizare.git
cd platforma-monitorizare
bash setup.sh