pipeline {
    environment {
        commit_id         = ""		
		VM_TYPE           = ""
		VM_NAME           = ""
		VM_SIZE           = ""
		LINUX_PUBLIC_IP   = ""
		WINDOWS_PUBLIC_IP = ""
		TERMINATION_INPUT = ""
		AZURE_APP_ID      = "e135aa97-15a7-46da-9d2a-6c18e47bf7eb"
		AZURE_PASSWORD    = "3cb64ca4-82f8-495e-bf35-c121e8b316e1"
		AZURE_TENANT      = "093e934e-7489-456c-bb5f-8bb6ea5d829c"
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
		// Reads virtual machine's parameters from text file, loggs into Azure cloud provider and initializes Terraform
		stage("Initialize") {
			when { 
				branch "Terraform-Deploy"
			}
			steps {
				script {
					// Reads parameters file and splits the lines to parameters for furthur creation proccesing 
					def filePath = readFile "./txtFiles/Parameters.txt"
				    def lines = filePath.readLines() 
					VM_TYPE = "${lines[0]}"
					VM_NAME = "${lines[1]}"
					VM_SIZE = "${lines[2]}"

					if ("${VM_TYPE}" == "Linux Ubuntu 16.04") {
						sh "echo > ./tfFiles/WindowsVM.tf"
					}
					else {
						sh "echo > ./tfFiles/LinuxVM.tf"
					}
                }
				
				// Changes permissions to 'hosts' file in order to add the newly created servers 
				sh "chmod 777 ./Inventory/hosts.ini"				
				sh """echo -en "\n\\[azcli_servers\\]" >> ./Inventory/hosts.ini"""

				sh "echo Connecting to Azure cloud provider"
				sh "az login --service-principal --username $AZURE_APP_ID --password $AZURE_PASSWORD --tenant $AZURE_TENANT"

				sh "echo Preparing Terraform"
          		dir('./tfFiles') {
            		sh """
					chmod +x ./*
					terraform init -input=false
                	terraform plan -input=false -out tfplan
                	terraform show -no-color tfplan > tfplan.txt
					"""
          		}
			}
		}
		// Decides whether to continue and apply Terraform for virtual machive creation
		stage("Approval") {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
				branch "Terraform-Deploy"
            }
            steps {
				dir('./tfFiles') {
					script {
                    	def plan = readFile 'tfplan.txt'
                    	input message: "Do you want to apply the plan?",
	                                   parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                	}
				}
            }
        }
	}
// 		// Applyes Terraform and creates virtual machine 
// 		stage("Apply") {
// 			when { 
// 				branch "Terraform-Deploy"
// 			}
//             steps {
// 				dir('./tfFiles') {
// 					sh "terraform apply -input=false tfplan"
// 				}
// 				//TODO: retrieves theirs public IPs and configures DNS for them
//             }
//         }
// 		// Tests connection to other servers using 'PING' command through Ansible playbook
// 		stage("Connection Test") {
// 			when { 
// 				anyOf { 
// 					branch "azcli-Deploy"; branch "Terraform-Deploy"
// 				}
// 			}
// 			steps {
// 				// TODO: Configure ssh from Ansible server to newly created servers and run Ansible playbook
// 				sh "echo Testing connection"
// 	    		// sh "ansible-playbook -i ./Inventory/hosts.ini -u jenkins ./ymlFiles/TestConnection.yml"
// 			}
// 		}
// 		// Validates whether to cleanup all Terraform created resources
// 		stage("Validation") {
// 			when { 
// 				branch "Terraform-Deploy"
// 			}
// 			steps {
// 				timeout(time: 300, unit: 'SECONDS') {
// 					script {
// 						def userInput = input id: 'userInput', message: 'Please Provide Parameters', ok: 'Next', 
// 						                parameters: [[$class: 'ChoiceParameterDefinition', choices: ["Yes, delete my server", "No, keep it alive"].join('\n'), 
// 										            description: 'Do you want to cleanup all created resources?', name:'TERMINATION']]
    					
// 						// Saves user choise in global variable for furthur steps 
// 						TERMINATION_INPUT = userInput
// 					}	
// 				}
// 			}
// 		}
// 		// Cleans all created and modified resources 
// 		stage("Cleanup") {
// 			when { 
// 				branch "Terraform-Deploy"
// 			}
// 			steps {		
// 				sh "echo Cleaning up resources"	
// 				script{
// 					if ("${TERMINATION_INPUT}" == "Yes, delete my server") {
// 						parallel (
// 							"Cleanup Files" : {
// 								script {
// 									// Checks whether to remove new added lines into 'hosts' file and removes them
// 									if ("${VM_TYPE}" == "Linux Ubuntu 16.04" || "${VM_TYPE}" == "Windows Server 2016") {
// 										sh "tail -n 2 './Inventory/hosts.ini' | wc -c | xargs -I {} truncate './Inventory/hosts.ini' -s -{}"
// 									}
// 									else {
// 										sh "tail -n 3 './Inventory/hosts.ini' | wc -c | xargs -I {} truncate './Inventory/hosts.ini' -s -{}"
// 									}
// 								}
// 							},
// 							"Cleanup Resources" : {
// 								dir('./tfFiles') {
// 									sh "terraform destroy --auto-approve"
// 									sh "echo All resources deleted successfully"
// 								}
// 							}
// 						)
// 					}
// 				}
// 			}
// 		}
// 	}
	post {
        always {
            archiveArtifacts artifacts: "tfFiles/tfplan.txt"
        }
		failure {
			dir('./tfFiles') {
				sh "terraform destroy --auto-approve"
				sh "echo All resources deleted successfully"
			}            
        }
    }
}