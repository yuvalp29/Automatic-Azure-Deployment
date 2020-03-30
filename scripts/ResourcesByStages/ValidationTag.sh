#!/bin/bash

# DONE: Stage1 - Runs on all unused resources inside Azure cloud provider and tags them for deletion validation
# Runs on all resource groups
rgNames=$(az group list --query [].name -o tsv)
for rgName in $rgNames; do 
    # Gets all stopped virtual machines inside a specific resource group
    vmNames=$(az vm list -d -g $rgName --query "[?(powerState=='VM deallocated' || powerState=='VM stopped') && (tags.Action!='ToValidate') && (tags.Action!='ToDelete')].name" -o tsv)
    if (( ${#vmNames[@]} )); then
        #  Runs on all stopped virtual machines inside non empty resource groups
        for vmName in $vmNames; do
            # Tags each virtual machine for deletion validtion
            az vm update -g $rgName -n $vmName --set tags.Action=ToValidate
            echo $vmName >> ToValidate.txt
        done
    fi

    # Gets all unmanaged disks inside a specific resource group
    unmanagedDiskNames=$(az disk list -g $rgName --query "[?(managedBy==null) && (tags.Action!='ToValidate') && (tags.Action!='ToDelete')].name" -o tsv)
    if (( ${#unmanagedDiskNames[@]} )); then
        #  Runs on all unmanaged disks inside non empty resource groups
        for diskName in $unmanagedDiskNames; do
            # Tags each unmanaged disk for deletion validtion
            az disk update -g $rgName -n $diskName --set tags.Action=ToValidate
            echo $diskName >> ToValidate.txt
        done
    fi

    # Gets all unattached network interfaces inside a specific resource group
    unattachedNICsIds=$(az network nic list -g $rgName --query "[?(virtualMachine==null) && (tags.Action!='ToValidate') && (tags.Action!='ToDelete')].id" -o tsv)
    # Runs on all unattached network interfaces inside non empty resource groups and taggs them and its associated network parameters
    for unattachedNICId in ${unattachedNICsIds[@]}; do
        # Gets assitional network parameters associated to the specific network interface
        publicIP=$(az network nic show --ids $unattachedNICId --query "ipConfigurations[].publicIpAddress.id" -o tsv)
        NSGID=$(az network nic show --ids $unattachedNICId --query "networkSecurityGroup.id" -o tsv)
        subnetID=$(az network nic show --ids $unattachedNICId --query "ipConfigurations[].subnet.id" -o tsv)

        # Tags each network variable for deletion validtion
        az network nic update --ids $unattachedNICId --set tags.Action=ToValidate
        az network public-ip update --ids $publicIP --set tags.Action=ToValidate
        az network nsg update --ids $NSGID --set tags.Action=ToValidate
        az network vnet subnet update --ids $subnetID --set tags.Action=ToValidate

        echo $unattachedNICId >> ToValidate.txt
        echo $publicIP >> ToValidate.txt
        echo $NSGID >> ToValidate.txt
        echo $subnetID >> ToValidate.txt
    done
done