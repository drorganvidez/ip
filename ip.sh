#!/bin/bash

# Preguntar por la dirección IP
read -p "Ingresa la dirección IP (por ejemplo, 192.168.100.3): " ip_address

# Verificar si la dirección IP es válida (puedes agregar más validaciones según tus necesidades)
if [[ ! $ip_address =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "La dirección IP ingresada no es válida."
  exit 1
fi

# Verificar si la dirección IP está disponible mediante un ping
if ping -c 1 "$ip_address" &>/dev/null; then
  echo "La dirección IP $ip_address ya está en uso. Abortando."
  exit 1
fi

# Crear el contenido del archivo de configuración
config_content="# This is the network config written by 'subiquity'
network:
  ethernets:
    enp1s0:
      dhcp4: no
      addresses:
        - $ip_address/24
      gateway4: 192.168.100.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
  version: 2"

# Sobreescribir el archivo de configuración
echo "$config_content" | sudo tee /etc/netplan/00-installer-config.yaml > /dev/null

# Aplicar la nueva configuración
sudo netplan apply

echo "La configuración ha sido actualizada con la dirección IP $ip_address."
