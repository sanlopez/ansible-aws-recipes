#!/bin/bash

# Get License id from first argument

license=$1

# Update hostname and license on master and worker config
host_name=`hostname`
sed -i -e "s+ip-172-xxx-xxx-xxx+$host_name+g" /home/scipion/cryosparc4/cryosparc_master/config.sh
sleep 30
sed -i -e "s+xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx+$license+g" /home/scipion/cryosparc4/cryosparc_master/config.sh
sleep 30
sed -i -e "s+xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx+$license+g" /home/scipion/cryosparc4/cryosparc_worker/config.sh
sleep 30

# Remove bad worker and add the good one
/home/scipion/cryosparc4/cryosparc_master/bin/cryosparcm start
/home/scipion/cryosparc4/cryosparc_master/bin/cryosparcm cli "remove_scheduler_target_node('ip-172-xxx-xxx-xxx.eu-west-1.compute.internal')"
cd /home/scipion/cryosparc4/cryosparc_worker
./bin/cryosparcw connect --master localhost --port 39000 --worker $host_name'.eu-west-1.compute.internal' --nossd
/home/scipion/cryosparc4/cryosparc_master/bin/cryosparcm cli "reload()"
sleep 30
/home/scipion/cryosparc4/cryosparc_master/bin/cryosparcm cli "refresh_job_types()"
