# I2PC AWS COURSE TOOLKIT
This repository contains the necessary tools to set up CryoEM course machines in Amazon AWS.

 ## Execution order and guide (Usage)
Although the intended user for this repository is an ADVANCED system administrator, here you can find the recommended workflow:
 * Use the *levantar_muchas.sh* script in *aws_scripts* to deploy your desired machines. Carefully review the variables.

## Requirements
The program requires the following information to be provided:
 - A CSV file containing the already-launched AWS machines. This can be obtained through the *levantar_muchas.sh* script.
 - A CSV file containing a sufficient amount of valid CryoSPARC licenses. Please respect the CS license scheme.
 - Amazon EC2 CLI tools to be configured in the executing computer, with administrative access to an active AWS account.

## Script explaination
### levantar_muchas.sh
Script that interacts with AWS-CLI and launches the required EC2 instances, with their required IP and storage.
 - A set of AWS machines cloned from a specified AMI, with compute, storage and elastic IP properly tagged (both name and cost tags).
 - A CSV file containing the name, instance ID and elastic IP of the machines.

### generate_ansible_cs_vars.sh (needs levantar_muchas CSV)
Script that takes the CSV from levantar_muchas, and compiles a dictionary that is shown on screen.
 - A text you can copy into your *playbook.yml* with the precompiled dictionary of machine-CS key

### generate_ansible_inventory.sh (needs levantar_muchas CSV)
Script that takes the CSV from levantar_muchas, and compiles an Ansible inventory file.
 - A text you can copy into your *inventory* file with the precompiled list of machines

 ### playbook.yml (requires all of the previous to be executed for automation)
 Ansible playbook script that does the following:
  * Copy the cryosparc-related scripts to the machine
  * Reassign node information for CS: CS master IP, CS worker IP and license
  * Warm-up the disks

