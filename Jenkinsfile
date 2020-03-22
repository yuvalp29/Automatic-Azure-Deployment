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
		stage("Initialize") {
			when { 
				anyOf {
					branch "master";  branch "azcli-Deploy"; branch "Terraform-Deploy"
				}                
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
				// Changes permissions to 'hosts' file in order to add the newly created servers 
				sh "chmod 777 ./Inventory/hosts.ini"	
				
				sh "echo Connecting to Azure cloud provider"
				sh "az login --service-principal --username $AZURE_APP_ID --password $AZURE_PASSWORD --tenant $AZURE_TENANT"				
			}
		}
	}
}