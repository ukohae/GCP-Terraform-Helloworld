pipeline {
    agent any
    stages {        
        stage ("init") {
            steps {
                sh 'terraform init'
            }
        }

        stage ("validate") {
            steps {
                sh 'terraform validate'
            }
        }

        stage ("tfsec") {
            steps {
                catchError(stageResult: 'UNSTABLE', buildResult: currentBuild.result) {
                    sh 'tfsec .'
                }
            }
        }

        stage ( "plan") {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage ("deploy") {
            steps {
                script {
                    def applyPerformed = fileExists('selected_region.txt')
                    def action = input(
                        id: 'userInput',
                        message: 'Terraform action',
                        parameters: [
                            choice(
                                choices: applyPerformed ? ['apply', 'destroy'] : ['apply'],
                                description: 'Choose the action',
                                name: 'action'
                            )
                        ]
                    )

                    if (action == 'apply') {
                        def region = input(
                            id: 'regionInput',
                            message: 'Select the region',
                            parameters: [
                                choice(
                                    choices: ['us-east4', 'us-east2', 'us-central1'],
                                    description: 'Choose the region',
                                    name: 'region'
                                )
                            ]
                        )
                        echo "Selected region: ${region}"
                        env.AWS_DEFAULT_REGION = region

                        writeFile(file: 'selected_region.txt', text: region)
                    } else {
                        def region = ''
                        if (applyPerformed) {
                            region = readFile('selected_region.txt').trim()
                            env.AWS_DEFAULT_REGION = region
                        } else {
                            error('Region not selected. Destroy action is disabled.')
                        }

                        echo "Selected region: ${region}"
                    }

                    echo "Terraform action is --> ${action}"
                    sh "$USER"
                    sh "sudo chown root:$USER /run/docker.sock"
                    sh "terraform ${action} --auto-approve"
                }
            }
        }
    }
}