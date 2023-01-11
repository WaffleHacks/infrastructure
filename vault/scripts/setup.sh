#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

set -eux -o pipefail

# Setup NTP
sudo apt-get update
sudo apt-get install -y gnupg ntp wget

sudo systemctl start ntp
sudo systemctl enable ntp

# Install AWS SSM Agent
mkdir /tmp/ssm
wget -O /tmp/ssm/amazon-ssm-agent.deb https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_arm64/amazon-ssm-agent.deb
sudo dpkg -i /tmp/ssm/amazon-ssm-agent.deb

sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
