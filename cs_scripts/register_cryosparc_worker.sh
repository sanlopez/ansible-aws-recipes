#!/bin/bash

full_host_name=`hostname -f`

# Register the new worker
echo "Registering new worker $full_host_name"
cd /home/scipion/cryosparc4/cryosparc_worker
./bin/cryosparcw connect --master localhost --port 39000 --worker $full_host_name --nossd
# Refresh CS
/home/scipion/cryosparc4/cryosparc_master/bin/cryosparcm cli "reload()"
sleep 30
