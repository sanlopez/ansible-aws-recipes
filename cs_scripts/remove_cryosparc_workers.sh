#!/bin/bash

# Wait for master to be up
sleep 5
full_host_name=`hostname -f`

/home/scipion/cryosparc4/cryosparc_master/bin/cryosparcm start

# Find possible existing workers
old_workers=$(/home/scipion/cryosparc4/cryosparc_master/bin/cryosparcm cli "get_worker_nodes()" | grep -o 'ip-[0-9]\{1,3\}-[0-9]\{1,3\}-[0-9]\{1,3\}-[0-9]\{1,3\}\.eu-west-1\.compute\.internal' | awk '!seen[$0]++')
# Kill them
/home/scipion/cryosparc4/cryosparc_master/bin/cryosparcm cli "remove_scheduler_target_node('localhost')"
sleep 5
for worker in $old_workers; do
  echo "Removing worker $worker"
  /home/scipion/cryosparc4/cryosparc_master/bin/cryosparcm cli "remove_scheduler_target_node('$worker')"
  sleep 2
done
echo "Done deleting old workers, bye!"
sleep 2
