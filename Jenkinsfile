pipeline {
    environment {
        commit_id            = ""		
		VM_TYPE              = ""
		VM_NAME              = ""
		VM_SIZE              = ""
		AZURE_RESOURCE_GROUP = "Technology-RG"
		AZURE_APP_ID         = "e135aa97-15a7-46da-9d2a-6c18e47bf7eb"
		AZURE_PASSWORD       = "3cb64ca4-82f8-495e-bf35-c121e8b316e1"
		AZURE_TENANT         = "093e934e-7489-456c-bb5f-8bb6ea5d829c"
    }

    agent { label 'slave01-ssh' }

    stages {
		// Gets commit_id in GitHub
        stage("Preparation") {
			when { 
				anyOf { 
					branch "master";  branch "azcli-Deploy"; branch "Terraform-Deploy"
				}
			}
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
				anyOf { 
					branch "master";  branch "azcli-Deploy"; branch "Terraform-Deploy"
				}
			}
			steps {
				script {		
					// TODO: Read vm creation parameters from txt file and assign them to global parameters for furthur creation process 
					// while read -r line; do let lineNumber++; echo "LINE $lineNumber : value $line"; done < file.txt
					// sh "while read line; do echo $line; done < ./txtFiles/company.txt"
					def file = readFile ./txtFiles/Parameters.txt
					def lines = file.readLines()

					// sh "read -d '' -r -a lines < ./txtFiles/Parameters.txt"
					VM_TYPE = "${lines[0]}"
					VM_NAME = "${lines[1]}"
					VM_SIZE = "${lines[2]}"
				}

				sh "echo Connecting to Azure cloud provider"
				sh "az login --service-principal --username $AZURE_APP_ID --password $AZURE_PASSWORD --tenant $AZURE_TENANT"				

				sh "echo VM TYPE: ${VM_TYPE}, VM NAME: ${VM_NAME}, VM SIZE: ${VM_SIZE}"
			}
		}
	}
}


		// // TODO: Install Terraform using the script
		// // Installing prerequisites using Ansible playbook and inittiating Terraform
		// stage("Prerequisites") {
		// 	when { 
		// 		anyOf { 
		// 			branch "Ansible-Deploy"; branch "Terraform-Deploy"
		// 		}
		// 	}
		// 	steps {
		// 		sh "echo Installing prerequisites and inittialyzing Terraform"
	    // 		sh "ansible-playbook -i ./Inventory/hosts.ini -u jenkins ./ymlFiles/Prerequisites.yml"
		// 		sh "ansible-playbook -i ./Inventory/hosts.ini -u jenkins ./ymlFiles/AzureCLI.yml"
		// 	}
		// }
		// // Getting from user what vm version to create
		// stage("VM Deployment Option") {
			
		// 	agent { label 'k8s' }

		// 	when { 
		// 		branch "Terraform-Deploy"
		// 	}
		// 	steps {
		// 		timeout(time: 45, unit: 'SECONDS') {
		// 			script {
		// 				def userInput = input id: 'userInput', message: 'Please Provide Parameters', ok: 'Next', 
		// 				                parameters: [[$class: 'ChoiceParameterDefinition', 
		// 											  choices: ["Deploy both virtual mechines", 
		// 											            "Deploy Linux Ubuntu 16.04 virtual machine", 
		// 														"Deploy Windows Server 2019 virtual machine"].join('\n'), 
		// 											  description: 'Please select deployment option and operating system version', 
		// 											  name:'DEPLOYMENT']]
    					
		// 				// Saving user choise in global variable for furthur steps 
		// 				DEPLOYMENT_INPUT = userInput
		// 			}	
		// 		}
		// 	}
		// }
		// // TODO:
		// // Creating virtual machines according to user's choise + validating the creation
		// stage("VM Creation") {

		// 	agent { label 'k8s' }

		// 	when { 
		// 		branch "Terraform-Deploy"
		// 	}
		// 	steps {		
		// 		script {
		// 			if ("${DEPLOYMENT_INPUT}" == "Deploy Linux Ubuntu 16.04 virtual machine") {
		// 				// TODO: Retrieve public IP
		// 				sh """
		// 				echo Creating Azure resources for Linux Ubuntu 16.04 virtual machine.
		// 				terraform plan -target=./tfFiles/Linux_VM.tf
		// 				terraform apply -target=./tfFiles/Linux_VM.tf -auto-approve
		// 				"""
		// 			}
		// 			else if ("${DEPLOYMENT_INPUT}" == "Deploy Windows Server 2019 virtual machine") {
		// 				// TODO: Retrieve public IP
		// 				sh """
        //                 echo Creating Azure resources for Windows Server 2019 virtual machine.
		// 				terraform plan -target=./tfFiles/Windows_VM.tf
		// 				terraform apply -target=./tfFiles/Windows_VM.tf -auto-approve
        //                 """
		// 			}
		// 			else {
		// 				// TODO: Retrieve public IP
		// 				sh "echo Creating Azure resources for both Windows and Linux virtual machines."
		// 				parallel {
		// 					stage('Windows Server 2019') {
		// 						when { 
		// 							branch "Terraform-Deploy"
		// 						}
        //             			steps {
		// 							sh """
		// 							terraform plan -target=./tfFiles/Windows_VM.tf
		// 							terraform apply -target=./tfFiles/Windows_VM.tf -auto-approve
        //                 			"""
        //             			}
        //         			}
		// 					stage('Linux Ubuntu 16.04') {
		// 						when { 
		// 							branch "Terraform-Deploy"
		// 						}
		// 						steps {
		// 							sh """
		// 							terraform plan -target=./tfFiles/Linux_VM.tf
		// 							terraform apply -target=./tfFiles/Linux_VM.tf -auto-approve
		// 							"""
		// 						}
		// 					}			
		// 				}
		// 			}
		// 		}
		// 	}
		// }		
		// // TODO:
		// stage('Configure Jenkins Slaves') {
		// 	// Configuring the vms as jenkins slaves: connecting the VM to the master using ssh configuration
		// 	// Pring a message that says that vm are ready and configured for slave 
			
		// 	agent { label 'k8s' }
			
		// 	when { 
		// 		branch "Terraform-Deploy"
		// 	}
		// 	steps {		
		// 		sh "echo Configuring Jenkins slaves."	
		// 	}
		// }