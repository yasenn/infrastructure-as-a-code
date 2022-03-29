#!/bin/bash

set -e

start_time=`date +%s`
date1=$(date +"%s")
TF_IN_AUTOMATION=1 terraform init
TF_IN_AUTOMATION=1 terraform apply -auto-approve
rm -rf postgresql_cluster || true
git clone https://github.com/vitabaks/postgresql_cluster.git
ansible-playbook -i host.ini postgresql_cluster/deploy_pgcluster.yml
end_time=`date +%s`
date2=$(date +"%s")
echo "###############"
echo Execution time was `expr $end_time - $start_time` s.
DIFF=$(($date2-$date1))
echo "Duration: $(($DIFF / 3600 )) hours $((($DIFF % 3600) / 60)) minutes $(($DIFF % 60)) seconds"
echo "###############"
