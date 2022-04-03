#!/bin/bash

set -e

start_time=`date +%s`
date1=$(date +"%s")
TF_IN_AUTOMATION=1 terraform init
TF_IN_AUTOMATION=1 terraform apply -auto-approve
# ansible-galaxy install git+https://github.com/AlexeySetevoi/ansible-clickhouse.git,master
# ansible-playbook -i inventory.yml playbook.yml
git clone https://git.blindage.org/21h/ansible-clickhouse-deploy.git || true
ansible-playbook -i host.ini ansible-clickhouse-deploy/playbook.yml
end_time=`date +%s`
date2=$(date +"%s")
echo "###############"
echo Execution time was `expr $end_time - $start_time` s.
DIFF=$(($date2-$date1))
echo "Duration: $(($DIFF / 3600 )) hours $((($DIFF % 3600) / 60)) minutes $(($DIFF % 60)) seconds"
echo "###############"
