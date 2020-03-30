#!/bin/bash

# DONE: Deletes unattached NICs, public IPs, NSGs, subnets etc.

# Stage1: Run on all unattached network interfaces inside Azure cloud provider and tag them and its associated network parameters for deletion validation
# Runs on all resource groups
rgNames=$(az group list --query [].name -o tsv)
for rgName in $rgNames; do 
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
    done
done

# Stage2: Run on all unattached network interfaces that tagged as 'deletion validation' inside Azure cloud provider and tag them and its associated network parameters for deletion 
# Runs on all resource groups
rgNames=$(az group list --query [].name -o tsv)
for rgName in $rgNames; do 
    # Gets all tagged unattached network interfaces inside a specific resource group
    unattachedNICsIds=$(az network nic list -g $rgName --query "[?tags.Action=='ToValidate'].id" -o tsv)
    # Runs on all tagged unattached network interfaces inside non empty resource groups and taggs them and its associated network parameters
    for unattachedNICId in ${unattachedNICsIds[@]}; do
        # Gets assitional network parameters associated to the specific network interface
        publicIP=$(az network nic show --ids $unattachedNICId --query "ipConfigurations[].publicIpAddress.id" -o tsv)
        NSGID=$(az network nic show --ids $unattachedNICId --query "networkSecurityGroup.id" -o tsv)
        subnetID=$(az network nic show --ids $unattachedNICId --query "ipConfigurations[].subnet.id" -o tsv)

        # Tags each network variable for deletion
        az network nic update --ids $unattachedNICId --set tags.Action=ToDelete
        az network public-ip update --ids $publicIP --set tags.Action=ToDelete
        az network nsg update --ids $NSGID --set tags.Action=ToDelete
        az network vnet subnet update --ids $subnetID --set tags.Action=ToDelete
        done
    fi
done

# Stage3: Run on all unattached network interfaces that tagged for deletion inside Azure cloud provider and delete them and its associated network parameters
# Runs on all resource groups
rgNames=$(az group list --query [].name -o tsv)
for rgName in $rgNames; do
    # Gets all tagged unattached network interfaces Ids inside a specific resource group
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
        
        echo $unattachedNICId >> Deleted_NetworkResources.txt
        echo $publicIP >> Deleted_NetworkResources.txt
        echo $NSGID >> Deleted_NetworkResources.txt
        echo $subnetID >> Deleted_NetworkResources.txt
    done
done

echo "Press ENTER to continue"
read varName