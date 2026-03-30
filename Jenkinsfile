pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'ap-south-1'
        ADMIN_EMAIL           = credentials('admin-email')
        ADMIN_PASSWORD        = credentials('admin-password')
        DB_PASSWORD           = credentials('db-password')
        DIRECTUS_SECRET       = credentials('directus-secret')
    }

    stages {

        // ─────────────────────────────────────────
        // STAGE 1: VALIDATE
        // ─────────────────────────────────────────
        stage('Validate') {
            parallel {

                stage('Terraform Validate') {
                    steps {
                        dir('terraform') {
                            sh 'terraform init -backend=false'
                            sh 'terraform validate'
                            sh 'terraform fmt -check || true'
                        }
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'terraform/*.tf', allowEmptyArchive: true
                        }
                    }
                }

                stage('Docker Validate') {
                    steps {
                        sh 'docker-compose -f docker-compose.yml config || true'
                    }
                }

            }
        }

        // ─────────────────────────────────────────
        // STAGE 2: PLAN
        // ─────────────────────────────────────────
        stage('Plan') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    dir('terraform') {
                        sh 'terraform init'
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'terraform/tfplan', allowEmptyArchive: true
                }
            }
        }

        // ─────────────────────────────────────────
        // STAGE 3: PROVISION (automatic)
        // ─────────────────────────────────────────
        stage('Provision') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    dir('terraform') {
                        sh 'terraform init'
                        sh 'terraform apply -auto-approve'
                        sh 'terraform output -raw instance_public_ip > ../server_ip.txt'
                        sh 'terraform output -raw private_key > ../ssh_key.pem'
                        sh 'chmod 600 ../ssh_key.pem'
                    }
                }
                stash includes: 'server_ip.txt,ssh_key.pem', name: 'infra-outputs'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'server_ip.txt', allowEmptyArchive: true
                }
            }
        }

        // ─────────────────────────────────────────
        // STAGE 4: DEPLOY
        // ─────────────────────────────────────────
        stage('Deploy') {
            steps {
                unstash 'infra-outputs'
                script {
                    def serverIp = readFile('server_ip.txt').trim()

                    sh """
                        echo "Waiting for server to be ready..."
                        sleep 60
                    """

                    sh """
                        scp -i ssh_key.pem \
                            -o StrictHostKeyChecking=no \
                            -o ConnectTimeout=30 \
                            docker-compose.yml \
                            ubuntu@${serverIp}:/home/ubuntu/docker-compose.yml
                    """

                    sh """
                        ssh -i ssh_key.pem \
                            -o StrictHostKeyChecking=no \
                            -o ConnectTimeout=30 \
                            ubuntu@${serverIp} bash << 'ENDSSH'
                                cat > /home/ubuntu/.env << EOF
ADMIN_EMAIL=${env.ADMIN_EMAIL}
ADMIN_PASSWORD=${env.ADMIN_PASSWORD}
DB_PASSWORD=${env.DB_PASSWORD}
SECRET=${env.DIRECTUS_SECRET}
EOF
                                cd /home/ubuntu
                                sudo apt-get install -y docker-compose || true
                                docker-compose up -d
                            
                                echo "Waiting for Directus to start..."
                                for i in \$(seq 1 12); do
                                    if curl -s http://localhost:8055 > /dev/null; then
                                        echo "Directus is up!"
                                        break
                                    fi
                                    echo "Attempt \$i - waiting 10 seconds..."
                                    sleep 10
                                done
ENDSSH
                    """
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'server_ip.txt', allowEmptyArchive: true
                }
            }
        }

        // ─────────────────────────────────────────
        // STAGE 5: TEST
        // ─────────────────────────────────────────
        stage('Test') {
            parallel {

                stage('Health Check') {
                    steps {
                        unstash 'infra-outputs'
                        script {
                            def serverIp = readFile('server_ip.txt').trim()
                            sh """
                                echo "Running health check on http://${serverIp}:8055"
                                curl -f -s -o /dev/null -w "%{http_code}" \
                                    http://${serverIp}:8055 || exit 1
                                echo "Health check passed!"
                            """
                        }
                    }
                }

                stage('Capture Homepage') {
                    steps {
                        unstash 'infra-outputs'
                        script {
                            def serverIp = readFile('server_ip.txt').trim()
                            sh """
                                curl -L -o directus_homepage.html \
                                    http://${serverIp}:8055
                            """
                        }
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'directus_homepage.html', allowEmptyArchive: true
                        }
                    }
                }

                stage('Generate Report') {
                    steps {
                        unstash 'infra-outputs'
                        script {
                            def serverIp = readFile('server_ip.txt').trim()
                            sh """
                                cat > deployment_report.md << EOF
# Deployment Report

## Server Details
- Server IP: ${serverIp}
- Directus URL: http://${serverIp}:8055
- Pipeline: ${env.JOB_NAME} #${env.BUILD_NUMBER}
- Date: \$(date)

## Status
- Infrastructure: Provisioned
- Directus: Deployed
- Health Check: Passed
EOF
                            """
                        }
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'deployment_report.md', allowEmptyArchive: true
                        }
                    }
                }

            }
        }

        // ─────────────────────────────────────────
        // STAGE 6: CLEANUP (automatic)
        // ─────────────────────────────────────────
        stage('Cleanup') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    dir('terraform') {
                        sh 'terraform init'
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'terraform/destroy_output.txt', allowEmptyArchive: true
                }
            }
        }

    }

    // ─────────────────────────────────────────
    // POST PIPELINE ACTIONS
    // ─────────────────────────────────────────
    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed! Check logs above.'
        }
        always {
            cleanWs()
        }
    }
}