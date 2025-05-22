#!/bin/bash

# 👇 ID del security group que quieres añadir (ej: sg-0abc123def4567890)
# sg-077f5c7c is Scipion SG
NEW_SG_ID="sg-077f5c7c"

HOWMANY=16
BASE_NAME="i2pc-flex-training"		# Base name

echo "Will change security group for $HOWMANY machines"

for i in $(seq -w 1 $HOWMANY); do
  NAME="${BASE_NAME}-${i}"
  echo "Cambiando security group de la instancia: $NAME"
  
  # Obtener el ID de la instancia por su nombre
  INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$NAME" \
    --query "Reservations[0].Instances[0].InstanceId" \
    --output text)
  
  # 1. Obtener el ID de la interfaz de red principal
  ENI_ID=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].NetworkInterfaces[0].NetworkInterfaceId" \
    --output text)

  # 2. Obtener los SGs actuales
  CURRENT_SGS=$(aws ec2 describe-network-interfaces \
    --network-interface-ids $ENI_ID \
    --query "NetworkInterfaces[0].Groups[*].GroupId" \
    --output text)

  # 3. Construir nueva lista con el SG nuevo
  UPDATED_SGS=($CURRENT_SGS $NEW_SG_ID)

  # 4. Reasignar los security groups a la interfaz
  aws ec2 modify-network-interface-attribute \
    --network-interface-id $ENI_ID \
    --groups "${UPDATED_SGS[@]}"

  echo "✔ Añadido SG $NEW_SG_ID a $INSTANCE_ID"
  done