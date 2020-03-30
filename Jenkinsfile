pipeline {
    environment {
        commit_id            = ""		
		AZURE_APP_ID         = "e135aa97-15a7-46da-9d2a-6c18e47bf7eb"
		AZURE_PASSWORD       = "3cb64ca4-82f8-495e-bf35-c121e8b316e1"
		AZURE_TENANT         = "093e934e-7489-456c-bb5f-8bb6ea5d829c"
    }

    agent { label 'slave01-ssh' }
	// triggers { cron('0 0/5 * ? * * *') }
	
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
		// Changes scripts permissions and logs into Azure cloud provider
		stage("Initialize") {
			when { 
				anyOf {
					branch "master";  branch "azcli-Cleanup"
				}                
			}
			steps {
				// Changes scripts permissions for execution
				sh "chmod +x ./scripts/ResourcesByStages/*"
				
				// Connects to Azure cloud provider
				sh "echo Connecting to Azure cloud provider"				
				sh "az login --service-principal --username $AZURE_APP_ID --password $AZURE_PASSWORD --tenant $AZURE_TENANT"				
			}
		}
		stage("Gatherring Resources") {
			steps{
				// sh "./scripts/ResourcesByStages/ValidationTag.sh"
				sh "echo Validation Tag stage"
			}
		}
		stage("Validation") {
			steps{
				// sh "./scripts/ResourcesByStages/DeletionTag.sh"
				sh "echo Deletion Tag stage"
			}
		}
		stage("Deletion") {
			steps{
				// sh "./scripts/ResourcesByStages/Deletion.sh"
				sh "echo Deletion stage"
			}
		}
	}
}