#!/bin/bash

# Get License id from first argument

license=$1

# Update hostname and license on master and worker config
full_host_name=`hostname -f`

/home/scipion/cryosparc4/cryosparc_master/bin/cryosparcm stop
# Modify MASTER config
sed -i "s/^export CRYOSPARC_LICENSE_ID=.*/export CRYOSPARC_LICENSE_ID=$license/" /home/scipion/cryosparc4/cryosparc_master/config.sh
sed -i "s/^export CRYOSPARC_MASTER_HOSTNAME=.*/export CRYOSPARC_MASTER_HOSTNAME=$full_host_name/" /home/scipion/cryosparc4/cryosparc_master/config.sh

# Modify WORKER config
sed -i "s/^export CRYOSPARC_LICENSE_ID=.*/export CRYOSPARC_LICENSE_ID=$license/" /home/scipion/cryosparc4/cryosparc_worker/config.sh

/home/scipion/cryosparc4/cryosparc_master/bin/cryosparcm start
