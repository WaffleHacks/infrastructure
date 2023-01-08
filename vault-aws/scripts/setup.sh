#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y ntp

sudo systemctl start ntp
sudo systemctl enable ntp
