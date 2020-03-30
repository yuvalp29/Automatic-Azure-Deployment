#!/bin/bash

# DONE: Stage3 - Runs on all unused resources tagged for deletion inside Azure cloud provider deletes them 
# Runs on all resource groups
rgNames=$(az group list --query [].name -o tsv)
for rgName in $rgNames; do 
    # Gets all stopped virtual machines inside a specific resource group
    vmNames=$(az vm list -d -g $rgName --query "[?tags.Action=='ToDelete'].name" -o tsv)
    if (( ${#vmNames[@]} )); then
        #  Runs on all stopped virtual machines inside non empty resource groups
        for vmName in $vmNames; do
            # Deletes each virtual machine and its associated resources
            ./scripts/DeleteVM.sh "$rgName" "$vmName"
            echo $vmName >> DeletedResources.txt
        done
    fi

    # Gets all unmanaged disks inside a specific resource group
    unmanagedDiskNames=$(az disk list -g $rgName --query "[?tags.Action=='ToDelete'].name" -o tsv)
    if (( ${#unmanagedDiskNames[@]} )); then
        #  Runs on all unmanaged disks inside non empty resource groups
        for diskName in $unmanagedDiskNames; do
            # Deletes each disk
            az disk delete -g $rgName -n $diskName --yes
            echo $diskName >> DeletedResources.txt
        done
    fi

    # Gets all unattached network interfaces inside a specific resource group
    unattachedNicsIds=$(az network nic list -g $rgName --query "[?tags.Action=='ToDelete'].id" -o tsv)
    #  Runs on all tagged unattached network interfaces inside non empty resource groups
    for unattachedNICId in ${unattachedNicsIds[@]}; do
        # Gets assitional network parameters associated to the specific network interface
        publicIP=$(az network nic show --ids $unattachedNICId --query "ipConfigurations[].publicIpAddress.id" -o tsv)
        NSGID=$(az network nic show --ids $unattachedNICId --query "networkSecurityGroup.id" -o tsv)
        subnetID=$(az network nic show --ids $unattachedNICId --query "ipConfigurations[].subnet.id" -o tsv)

        # Deletes network interface
        az network nic delete --ids $unattachedNICId
        sleep 30
        
        # Deletes public IP
        az network public-ip delete --ids $publicIP
        sleep 20
        
        # Deletes network security group
        az network nsg delete --ids $NSGID
        sleep 10

        # Deletes subnet inside virtual network 
        az network vnet subnet delete --ids &subnetID
        sleep 5
        
        echo $unattachedNICId >> DeletedResources.txt
        echo $publicIP >> DeletedResources.txt
        echo $NSGID >> DeletedResources.txt
        echo $subnetID >> DeletedResources.txt
    done
done