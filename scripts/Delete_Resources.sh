#!/bin/bash

# Just to notice:
# $1 = VM_NAME

VM_NAME=$1
AZURE_RESOURCE_GROUP="Technology-RG"
NIC=$VM_NAME$"VMNic"
PUBIP=$VM_NAME$"PublicIP"
NSG=$VM_NAME$"NSG"

echo "Gathering network interface connector information"
az vm nic list --vm-name "$VM_NAME" --resource-group $AZURE_RESOURCE_GROUP

echo $'\nStopping virtual machine, it may take up to 60 seconds'
az vm deallocate -n "$VM_NAME" -g $AZURE_RESOURCE_GROUP --no-wait
sleep 60

echo "Deleting virtual machine, it may take up to 10 minutes"
az vm delete -n "$VM_NAME" -g $AZURE_RESOURCE_GROUP --yes --no-wait
sleep 600

echo "Deleting data disks, it may take up to 15 seconds"
az disk delete --name "$VM_NAME-disk01" --resource-group $AZURE_RESOURCE_GROUP --yes --no-wait
sleep 15

echo "Deleting network interface, it may take up to 30 seconds"
az network nic delete -g $AZURE_RESOURCE_GROUP -n $NIC
sleep 30

echo "Deleting public IP, it may take up to 30 seconds"
az network public-ip delete -g $AZURE_RESOURCE_GROUP -n $PUBIP
sleep 30

echo "Deleting network security group, it may take up to 15 seconds"
az network nsg delete -g $AZURE_RESOURCE_GROUP -n $NSG