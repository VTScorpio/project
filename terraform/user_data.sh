#!/bin/bash
apt update -y
apt install -y git curl

cd /home/ubuntu
git clone https://github.com/VTScorpio/project
cd project
bash setup.sh