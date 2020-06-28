#!/usr/bin/bash

# Install packages
yum -y update
yum install -y gcc
yum install -y python37
yum install -y python3-devel
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
yum install -y postgresql-devel
pip install boto3 --user
pip install boto --user
pip3 install ansible --user
pip install psycopg2
pip install psycopg2-binary --user
yum install -y git

amazon-linux-extras install -y java-openjdk11
amazon-linux-extras install -y nginx1
yum install -y java-11-openjdk-devel git
su ec2-user -l -c 'curl -s "https://get.sdkman.io" | bash && source .bashrc && sdk install gradle'

# Configure/install custom software
cd /home/ec2-user
git clone https://github.com/szb0151/java-image-gallery.git
chown -R ec2-user:ec2-user java-image-gallery
git clone https://github.com/szb0151/ig-ansible.git
chown -R ec2-user:ec2-user ig-ansible

CONFIG_BUCKET="s3://edu.au.cc.ram-image-gallery-config"
aws s3 cp ${CONFIG_BUCKET}/nginx/nginx.conf /etc/nginx/nginx.conf
aws s3 cp ${CONFIG_BUCKET}/nginx/default.d/image_gallery.conf /etc/nginx/default.d/image_gallery.conf

# Start/enable services
systemctl stop postfix
systemctl disable postfix
systemctl start nginx
systemctl enable nginx

su ec2-user -l -c 'cd ~/java-image-gallery && ./start' >/var/log/image_gallery.log 2>&1 &

# Ansible commands
export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"
cd ig-ansible/Live/
ansible-playbook create_all_devel.yaml
