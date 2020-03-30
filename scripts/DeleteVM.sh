#!/bin/bash

rgName=$1
vmName=$2

# Gets virtual machine's disks ids
vmOSDisk=$(az vm show -d -g $rgName -n $vmName --query "storageProfile.osDisk.managedDisk.id" -o tsv);
vmDataDisks=$(az vm show -d -g $rgName -n $vmName --query "storageProfile.dataDisks[].managedDisk.id" -o tsv); 

# Gets virtual machine's network interface ids
vmNIC=$(az vm nic list --resource-group $rgName --vm-name $vmName --query [].id -o tsv);

# Gets virtual machine's public IP ids
vmPublicIP=$(az network nic show --ids $vmNIC --query "ipConfigurations[].publicIpAddress.id" -o tsv);

# Gets virtual machine's subnet ID
vmSubnetID=$(az network nic show --ids $vmNIC --query "ipConfigurations[].subnet.id" -o tsv)

# Gets virtual machine's network security group ids
vmNSG=$(az network nic show --ids $vmNIC --query "networkSecurityGroup.id" -o tsv);

echo "Deleting $vmName and its associated resources, it may take some minutes to deploy"

# Stops thevirtual machine (if not stopped)
az vm deallocate -n "$vmName" -g $rgName --no-wait
sleep 60
echo "$vmName stopped"

# Deletes virtual machine
az vm delete -n "$vmName" -g $rgName --yes --no-wait
sleep 600
echo "$vmName deleted"

# Deletes OS disk
az disk delete --ids $vmOSDisk --yes --no-wait
sleep 20
echo "OS disk deleted"

# Runs on all data disks and deletes them
for vmDataDisk in $vmDataDisks; do 
    az disk delete --ids $vmDataDisk --yes --no-wait
done
sleep 5
echo "Data disks deleted"

# Deletes network interface
az network nic delete --ids $vmNIC
sleep 30
echo "Network interface deleted"

# Deletes public IP
az network public-ip delete --ids $vmPublicIP
sleep 20
echo "Public IP deleted"

# Deletes network security group
az network nsg delete --ids $vmNSG
sleep 5
echo "Network security group deleted"
echo "All resources deleted successfully"

