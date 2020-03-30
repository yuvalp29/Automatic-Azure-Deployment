#!/bin/bash

# DONE: List all stopped vms inside resource groups, write them into a .txt file and tag them as "Action=ToValidate"
# DONE: List the tagged vms and ask for further processing: update the tag to "Action=ToDeleted" 
# DONE: List the tagged vms and delete them and its associated resources
# TODO: Monitor running virtual machines that didn't make anything (0 CPU and memory) and stop them automatically.

# Stage1: Run on all stopped virtual machines inside Azure cloud provider and tag them for deletion validation
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
        done
    fi
done

# Stage2: Run on all virtual machines that tagged as 'deletion validation' inside Azure cloud provider and tag them for deletion 
# Runs on all resource groups
rgNames=$(az group list --query [].name -o tsv)
for rgName in $rgNames; do 
    # Gets all stopped virtual machines inside a specific resource group
    vmNames=$(az vm list -d -g $rgName --query "[?tags.Action=='ToValidate'].name" -o tsv)
    if (( ${#vmNames[@]} )); then
        #  Runs on all stopped virtual machines inside non empty resource groups
        for vmName in $vmNames; do
            # Tags each virtual machine for deletion process
            az vm update -g $rgName -n $vmName --set tags.Action=ToDelete
        done
    fi
done

# Stage3: Run on all virtual machines that tagged for deletion and delete them and its associated resources inside Azure cloud provider
# Runs on all resource groups
rgNames=$(az group list --query [].name -o tsv)
for rgName in $rgNames; do 
    # Gets all stopped virtual machines inside a specific resource group
    vmNames=$(az vm list -d -g $rgName --query "[?tags.Action=='ToDelete'].name" -o tsv)
    if (( ${#vmNames[@]} )); then
        #  Runs on all stopped virtual machines inside non empty resource groups
        for vmName in $vmNames; do
            # Deletes each virtual machine and its associated resources
            ./Delete_VM.sh "$rgName" "$vmName"
            echo $vmName >> Deleted_VMs.txt
        done
    fi
done

echo "Press ENTER to continue"
read varName