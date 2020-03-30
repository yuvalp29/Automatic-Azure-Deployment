#!/bin/bash

# DONE: List all unmanaged disks inside resource groups, write them into a .txt file and tag them as "Action=ToValidate"
# DONE: List the tagged unmanaged disks and ask for further processing: update the tag to "Action=ToDeleted" 
# DONE: List the tagged unmanaged disks and delete them

# Stage1: Run on all unmanaged disks inside Azure cloud provider and tag them for deletion validation
# Runs on all resource groups
rgNames=$(az group list --query [].name -o tsv)
for rgName in $rgNames; do 
    # Gets all unmanaged disks inside a specific resource group
    unmanagedDiskNames=$(az disk list -g $rgName --query "[?(managedBy==null) && (tags.Action!='ToValidate') && (tags.Action!='ToDelete')].name" -o tsv)
    if (( ${#unmanagedDiskNames[@]} )); then
        #  Runs on all unmanaged disks inside non empty resource groups
        for diskName in $unmanagedDiskNames; do
            # Tags each unmanaged disk for deletion validtion
            az disk update -g $rgName -n $diskName --set tags.Action=ToValidate
        done
    fi
done

# Stage2: Run on all unmanaged disks that tagged as 'deletion validation' inside Azure cloud provider and tag them for deletion 
rgNames=$(az group list --query [].name -o tsv)
for rgName in $rgNames; do 
    # Gets all unmanaged disks inside a specific resource group
    unmanagedDiskNames=$(az disk list -g $rgName --query "[?tags.Action=='ToValidate'].name" -o tsv)
    if (( ${#unmanagedDiskNames[@]} )); then
        #  Runs on all unmanaged disks inside non empty resource groups
        for diskName in $unmanagedDiskNames; do
            # Tags each unmanaged disk for deletion
            az disk update -g $rgName -n $diskName --set tags.Action=ToDelete
        done
    fi
done

# Stage3: Run on all unmanaged disks inside Azure cloud provider that tagged for deletion and delete them
# Runs on all resource groups
rgNames=$(az group list --query [].name -o tsv)
for rgName in $rgNames; do 
    # Gets all unmanaged disks names inside a specific resource group
    unmanagedDiskNames=$(az disk list -g $rgName --query "[?tags.Action=='ToDelete'].name" -o tsv)
    if (( ${#unmanagedDiskNames[@]} )); then
        #  Runs on all unmanaged disks inside non empty resource groups
        for diskName in $unmanagedDiskNames; do
            # Deletes each disk
            az disk delete -g $rgName -n $diskName --yes
            echo $diskName >> Deleted_Disks.txt
        done
    fi
done

echo "Press ENTER to continue"
read varName