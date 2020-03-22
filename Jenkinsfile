pipeline {
    environment {
        commit_id            = ""		
		VM_TYPE              = ""
		VM_NAME              = ""
		VM_SIZE              = ""
		TERMINATION_INPUT    = ""
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
					// Reads parameters file and splits the lines to parameters for furthur creation proccesing 
					def filePath = readFile "./txtFiles/Parameters.txt"                 
				    def lines = filePath.readLines() 
					VM_TYPE = "${lines[0]}"
					VM_NAME = "${lines[1]}"
					VM_SIZE = "${lines[2]}"
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
					if ("${VM_TYPE}" == "Linux Ubuntu 16.04") {
						sh "echo Creating '$VM_NAME' $VM_TYPE virtual machine, it may take up to 3 minutes"
						sh "az vm create --resource-group $AZURE_RESOURCE_GROUP --name '$VM_NAME' --image 'UbuntuLTS' --size $VM_SIZE --os-disk-name '$VM_NAME-disk01' --public-ip-address-dns-name 'automatedlinux01' --admin-username 'techadmin' --admin-password 'Aa123456123456' --tags 'Owner=Yuval' 'method=azcli'"
						sh "az vm show -d -g $AZURE_RESOURCE_GROUP -n '$VM_NAME' --query publicIps -o tsv > PublicIPs.txt"
						LINUX_PUBLIC_IP = readFile('PublicIPs.txt').trim() 
						// sh "echo ${LINUX_PUBLIC_IP}"
					}
					else if ("${VM_TYPE}" == "Windows Server 2016") {
						sh "echo Creating '$VM_NAME' $VM_TYPE virtual machine, it may take up to 3 minutes"
						sh "az vm create --resource-group $AZURE_RESOURCE_GROUP --name '$VM_NAME' --image 'win2016datacenter' --size $VM_SIZE --os-disk-name '$VM_NAME-disk01' --public-ip-address-dns-name 'automatedwindows01' --admin-username 'techadmin' --admin-password 'Aa123456123456'  --tags 'Owner=Yuval' 'method=azcli'"
						sh "az vm show -d -g $AZURE_RESOURCE_GROUP -n '$VM_NAME' --query publicIps -o tsv > PublicIPs.txt"
						WINDOWS_PUBLIC_IP = readFile('PublicIPs.txt').trim()
					}
					else {
						sh "echo Creating both '$VM_NAME-Windows' and '$VM_NAME-Linux' virtual machines, it may take up to 3 minutes"
						parallel {
							stage('Linux Ubuntu 16.04') {
								when { 
									branch "azcli-Deploy"
								}
								steps {
									sh "az vm create --resource-group $AZURE_RESOURCE_GROUP --name '$VM_NAME-Linux' --image 'UbuntuLTS' --size $VM_SIZE --os-disk-name '$VM_NAME-disk01' --public-ip-address-dns-name 'automatedlinux01' --admin-username 'techadmin' --admin-password 'Aa123456123456' --tags 'tagname=DevOps' 'environment=Staging' 'method=azcli'"
								}
							}	
							stage('Windows Server 2016') {
								when { 
									branch "azcli-Deploy"
								}
                    			steps {
									sh "az vm create --resource-group $AZURE_RESOURCE_GROUP --name '$VM_NAME-Windows' --image 'win2016datacenter' --size $VM_SIZE --os-disk-name '$VM_NAME-disk01' --public-ip-address-dns-name 'automatedwindows01' --admin-username 'techadmin' --admin-password 'Aa123456123456' --tags 'tagname=DevOps' 'environment=Staging' 'method=azcli'"									
                    			}
                			}		
						}
						sh "az vm show -d -g $AZURE_RESOURCE_GROUP -n '$VM_NAME-Linux' --query publicIps -o tsv > PublicIPs.txt"
						LINUX_PUBLIC_IP = readFile('PublicIPs.txt').trim()
						sh "'' > PublicIPs.txt"  
						sh "az vm show -d -g $AZURE_RESOURCE_GROUP -n '$VM_NAME-Windows' --query publicIps -o tsv > PublicIPs.txt"
						WINDOWS_PUBLIC_IP = readFile('PublicIPs.txt').trim()
					}
				}
				// Clears the file
				sh "echo > PublicIPs.txt"				
			}
        }
		// Tests connection to other servers using 'PING' command through Ansible playbook
		stage("Connection Test") {
			when { 
				anyOf { 
					branch "azcli-Deploy"; branch "Terraform-Deploy"
				}
			}
			steps {
				// TODO:
				// Adds the virtual machines into Ansible 'hosts' file and tests connection using 'PING' command

				sh "echo Testing connection"
	    		// sh "ansible-playbook -i ./Inventory/hosts.ini -u jenkins ./ymlFiles/TestConnection.yml"
			}
		}
		// Validates whether to cleanup all created resources
		stage("Validtaion") {
			when{ 
				branch "azcli-Deploy"
			}
			steps {
				timeout(time: 60, unit: 'SECONDS') {
					script {
						def userInput = input id: 'userInput', message: 'Please type your answer', ok: 'Next', 
						                parameters: [[$class: 'ChoiceParameterDefinition', 
										            choices: ["Yes, delete my server", "No, keep it alive"].join('\n'), 
										            description: 'Would you like to delete all created resources?', 
													name:'TERMINATION']]
    					
						// Saves user's choise  for furthur steps 
						TERMINATION_INPUT = userInput
					}	
				}
			}
		}
		// Cleaning the resources 
		stage("Cleanup") {
			when{ 
				branch "azcli-Deploy"
			}
			steps{		
				sh "echo Cleaning up resources"	
				script{
					if ("${TERMINATION_INPUT}" == "Yes, delete my server") {
						sh "chmod +x ./scripts/Delete_Resources.sh"
						sh "./scripts/Delete_Resources.sh ${VM_NAME}"
						sh "echo All resources deleted successfully"   	
					}
				}
			}
		}
	}
	post {
        success {
            mail to:"ypodoksik29@gmail.com", subject:"SUCCESS: ${currentBuild.fullDisplayName}", body: "$VM_NAME $VM_TYPE virtual machine in size $VM_SIZE was created and then deleted successfully."
        }
        failure {
            mail to:"ypodoksik29@gmail.com", subject:"FAILED: ${currentBuild.fullDisplayName}", body: "There were problems in creating/deleting $VM_NAME $VM_TYPE virtual machine in size $VM_SIZE."
        }
    }   
}