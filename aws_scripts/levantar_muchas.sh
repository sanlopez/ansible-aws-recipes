#!/bin/bash


# Definición de variables
# AWS CLI debe estar instalado y configurado
AMI_ID="ami-0a74e1f41e44520e0"    # Reemplaza con tu AMI ID
INSTANCE_TYPE="g4dn.4xlarge"		  # Tipo de instancia
# Para TOMO: g4dn.8xlarge
# Para SPA-FLEX: g4dn.4xlarge
KEY_NAME="i2pc-training"          # Tu key pair
SECURITY_GROUP="sg-077f5c7c"     	# Tu security group
SUBNET_ID="subnet-36480d41"      	# Tu subnet ID, subnet-36480d41 es Irlanda
HOWMANY=16                        # Número de instancias a crear    
BASE_NAME="i2pc-flex-training"		# Base name
COSTE_TAG="curso-i2pc-flex-2025"  # Tag para el coste
USER_TAG="i2pc-training"          # Tag para permitir permisos (de levantar y apagar maquinas) a otros roles
# Generalmente: curso-i2pc-NOSEQUE-AÑO
# Por ejemplo: curso-i2pc-flex-2025, curso-i2pc-tomo-2026, etc.

echo "Por favor, revisa las variables antes de continuar:"
echo "Morch, vamos a levantar $HOWMANY maquinas"
echo "Se van a levantar de tipo: $INSTANCE_TYPE"
echo "El nombre base de las instancias será: $BASE_NAME"
echo "El cost tag será: $COSTE_TAG"
echo "El username tag será: $USER_TAG"
read -p "¿Quieres continuar? (s/N): " CONTINUAR
if [[ "$CONTINUAR" != "s" ]]; then
  echo "Operación cancelada."
  exit 1
fi

# Generación de archivo CSV auxiliar para luego
OUTPUT_FILE="../list_creation/instances_output.csv"
echo "Se va a volcar la información de las instancias en el archivo: $OUTPUT_FILE"
echo "Instance Name, Elastic IP" > $OUTPUT_FILE
if [ -f $OUTPUT_FILE ]; then
    echo "El archivo fue creado correctamente."
else
    echo "Error: el archivo no fue creado, revisa la ruta de OUTPUT_FILE."
    exit 1
fi

# Instances creation
for i in $(seq -w 1 $HOWMANY); do
  NAME="${BASE_NAME}-${i}"
  echo "Creando instancia: $NAME"
  # 1. Crear la instancia
  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SECURITY_GROUP \
    --subnet-id $SUBNET_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NAME},{Key=Coste,Value=$COSTE_TAG}]" \
    "ResourceType=volume,Tags=[{Key=Name,Value=$NAME},{Key=Coste,Value=$COSTE_TAG},{Key=UserName,Value=$USER_TAG}]" \
    --query 'Instances[0].InstanceId' \
    --output text)
  echo "Instancia $NAME creada con ID: $INSTANCE_ID"

  # 2. Dar un respiro
  echo "Esperando a que la instancia $NAME esté en ejecución..."
  # Esperar a que la instancia esté en ejecución
  aws ec2 wait instance-running --instance-ids $INSTANCE_ID
  echo "Instancia $NAME ya está en ejecución"

  # 3. Crear Elastic IP
  echo "Creando Elastic IP para la instancia $NAME"
  ALLOC_ID=$(aws ec2 allocate-address --domain vpc \
    --tag-specifications "ResourceType=elastic-ip,Tags=[{Key=Name,Value=$NAME},{Key=Coste,Value=$COSTE_TAG},{Key=UserName,Value=$USER_TAG}]" \
    --query 'AllocationId' \
    --output text)
  echo "Elastic IP asignada con Allocation ID: $ALLOC_ID"

   # 4. Obtener la ID de la interfaz de red primaria
  NETWORK_IFACE=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].NetworkInterfaces[0].NetworkInterfaceId" \
    --output text)

  # 5. Asociar Elastic IP a la interfaz
  aws ec2 associate-address \
    --allocation-id $ALLOC_ID \
    --network-interface-id $NETWORK_IFACE \
    --allow-reassociation
  echo "Elastic IP asociada a $NAME"
  
  # 6. Obtener la IP pública de la instancia para guardarla
  ELASTIC_IP=$(aws ec2 describe-addresses \
              --allocation-ids $ALLOC_ID \
              --query 'Addresses[0].PublicIp' --output text)

  echo "$NAME, $ELASTIC_IP"
  echo "$NAME, $ELASTIC_IP" >> $OUTPUT_FILE
  
done
