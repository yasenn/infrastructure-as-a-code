#!/bin/bash

set -euxo pipefail

start_time=`date +%s`
date1=$(date +"%s")
TF_IN_AUTOMATION=1 terraform init
TF_IN_AUTOMATION=1 terraform apply -auto-approve
ansible-galaxy collection install -r requirements.yml
ansible-galaxy collection install community.postgresql
ansible-galaxy install --force git+https://github.com/tcdi/ansible-postgresql.git,master
ansible-galaxy install geerlingguy.php
ansible-galaxy install geerlingguy.apache-php-fpm
ansible-playbook -i inventory.yml playbook.yml
end_time=`date +%s`
date2=$(date +"%s")
echo "###############"
echo Execution time was `expr $end_time - $start_time` s.
DIFF=$(($date2-$date1))
echo "Duration: $(($DIFF / 3600 )) hours $((($DIFF % 3600) / 60)) minutes $(($DIFF % 60)) seconds"
echo "###############"
