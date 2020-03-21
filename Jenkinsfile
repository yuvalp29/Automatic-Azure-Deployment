pipeline {
    environment {
        commit_id            = ""		
		VM_TYPE              = ""
		VM_NAME              = ""
		VM_SIZE              = ""
		LINUX_PUBLIC_IP      = ""
		Windows_PUBLIC_IP    = ""
		AZURE_RESOURCE_GROUP = "Technology-RG"
		AZURE_APP_ID         = "e135aa97-15a7-46da-9d2a-6c18e47bf7eb"
		AZURE_PASSWORD       = "3cb64ca4-82f8-495e-bf35-c121e8b316e1"
		AZURE_TENANT         = "093e934e-7489-456c-bb5f-8bb6ea5d829c"
    }

    agent { label 'slave01-ssh' }

    stages {
		// Gets commit_id in GitHub
        stage("Preparation") {
            steps {
		        sh "echo Preparations are running."
                checkout scm  
				script {
					sh "git rev-parse --short HEAD > .git/commit-id"
					commit_id = readFile('.git/commit-id').trim()
				}
            }
        }
		// Reads virtual machine's parameters from text file and loggs into Azure cloud provider
		stage("Inittialize") {
			when { 
				branch "azcli-Deploy"
			}
			steps {
				script {
					// TODO: Read vm creation parameters from txt file and assign them to global parameters for furthur creation process 
					// while read -r line; do let lineNumber++; echo "LINE $lineNumber : value $line"; done < file.txt

					VM_TYPE = "Linux Ubuntu 16.04"
					VM_NAME = "Technology-Automated"
					VM_SIZE = "Standard_D2_v2" 
				}
				sh "echo Connecting to Azure cloud provider"
				sh "az login --service-principal --username $AZURE_APP_ID --password $AZURE_PASSWORD --tenant $AZURE_TENANT"
			}
		}
		// Creates virtual machines using azcli
		stage("Apply") {
			when { 
				branch "azcli-Deploy"
			}
            steps {		
				script {
					// Creates virtual machines, retrieves theirs public IPs and configures DNS for them
					sh "echo Creating '$VM_NAME' $VM_TYPE virtual machine"
					if ("${VM_TYPE}" == "Linux Ubuntu 16.04") {
						// sh "az vm create --resource-group $AZURE_RESOURCE_GROUP --name '$VM_NAME' --image 'UbuntuLTS' --size $VM_SIZE --admin-username 'techadmin' --admin-password 'Aa123456123456' --tags 'tagname=DevOps' 'environment=Staging' 'method=azcli'"
						// sh "sleep 60"
						sh "az vm show -d -g $AZURE_RESOURCE_GROUP -n 'DockerCompose' --query publicIps -o table > myfile.txt"
						LINUX_PUBLIC_IP = readFile('myfile.txt').trim()
					}
					else if ("${VM_TYPE}" == "Windows Server 2016") {
						sh "az vm create --resource-group $AZURE_RESOURCE_GROUP --name '$VM_NAME' --image 'win2016datacenter' --size $VM_SIZE --admin-username 'techadmin' --admin-password 'Aa123456123456' --tags 'tagname=DevOps' 'environment=Staging' 'method=azcli'"
						sh "sleep 60"
						WINDOWS_PUBLIC_IP = az vm show -d -g $AZURE_RESOURCE_GROUP -n '$VM_NAME' --query publicIps -o tsv
					}
					else {
						sh "echo Creating both '$VM_NAME-Windows' and '$VM_NAME-Linux' virtual machines"
						parallel {
							stage('Linux Ubuntu 16.04') {
								when { 
									branch "azcli-Deploy"
								}
								steps {
									sh "az vm create --resource-group $AZURE_RESOURCE_GROUP --name '$VM_NAME-Linux' --image 'UbuntuLTS' --size $VM_SIZE --admin-username 'techadmin' --admin-password 'Aa123456123456' --tags 'tagname=DevOps' 'environment=Staging' 'method=azcli'"
									sh "sleep 60"
									LINUX_PUBLIC_IP = az vm show -d -g $AZURE_RESOURCE_GROUP -n '$VM_NAME-Linux' --query publicIps -o tsv
								}
							}	
							stage('Windows Server 2016') {
								when { 
									branch "azcli-Deploy"
								}
                    			steps {
									sh "az vm create --resource-group $AZURE_RESOURCE_GROUP --name '$VM_NAME-Windows' --image 'win2016datacenter' --size $VM_SIZE --admin-username 'techadmin' --admin-password 'Aa123456123456' --tags 'tagname=DevOps' 'environment=Staging' 'method=azcli'"
									sh "sleep 60"
									WINDOWS_PUBLIC_IP = az vm show -d -g $AZURE_RESOURCE_GROUP -n '$VM_NAME-Windows' --query publicIps -o tsv
                    			}
                			}		
						}
					}
				}
				echo "${LINUX_PUBLIC_IP}" 
			}
        }
		// // Pinging to servers using Ansible playbook
		// stage("Connection Test") {
		// 	when { 
		// 		anyOf { 
		// 			branch "Terraform-Deploy"; branch "azcli-Deploy"
		// 		}
		// 	}
		// 	steps {
		// 		// script {
		// 		// 	// TODO:
		// 		// 	// Retrieves created virtual machine's public IP using azcli and taggs and configures DNS for the machines
		// 		// 	if ("${VM_TYPE}" == "Linux Ubuntu 16.04") {
		// 		// 		LINUX_PUBLIC_IP = az vm show -d -g $AZURE_RESOURCE_GROUP -n '$VM_NAME' --query publicIps -o tsv
		// 		// 	}
		// 		// 	else if ("${VM_TYPE}" == "Windows Server 2016") {
		// 		// 		WINDOWS_PUBLIC_IP = az vm show -d -g $AZURE_RESOURCE_GROUP -n '$VM_NAME' --query publicIps -o tsv
		// 		// 	}
		// 		// 	else {
		// 		// 		LINUX_PUBLIC_IP = az vm show -d -g $AZURE_RESOURCE_GROUP -n '$VM_NAME-Linux' --query publicIps -o tsv
		// 		// 		WINDOWS_PUBLIC_IP = az vm show -d -g $AZURE_RESOURCE_GROUP -n '$VM_NAME-Windows' --query publicIps -o tsv
		// 		// 	}
		// 		// }
		
		// 		// TODO:
		// 		// Adds the virtual machines into Ansible 'hosts' file and tests connection using 'PING' command

		// 		sh "echo Testing connection"
	    // 		sh "ansible-playbook -i ./Inventory/hosts.ini -u jenkins ./ymlFiles/TestConnection.yml"
		// 	}
		// }
	}
}