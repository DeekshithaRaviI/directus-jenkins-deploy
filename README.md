# 🚀 Jenkins Directus Deployment: Automated CI/CD Pipeline
A fully automated DevOps pipeline designed to provision AWS infrastructure and deploy Directus Headless CMS using Jenkins, Terraform, and Docker.

## 🏗️ Project Architecture
This project demonstrates a complete CI/CD lifecycle:

Infrastructure as Code (IaC): Terraform provisions an AWS EC2 instance, Security Groups, and SSH Key Pairs.

CI/CD Pipeline: A 6-stage Jenkins pipeline validates code, plans infrastructure, provisions resources, and deploys the application.

Container Orchestration: Directus and PostgreSQL are deployed via Docker Compose with automated health checks.

Security: All secrets (AWS Keys, DB Passwords) are managed securely via the Jenkins Credentials Store.

## 🛠️ Tech Stack
CI/CD: Jenkins

IaC: Terraform

Cloud: AWS (EC2, VPC, IAM)

Containers: Docker & Docker Compose

CMS: Directus (Headless)

Database: PostgreSQL

## 🚀 Quick Start
Install Jenkins Plugins: Ensure Pipeline, Terraform, SSH Agent, and Credentials Binding are installed.

Configure Credentials: Add your AWS and Directus secrets to the Jenkins Credentials Store.

Run Pipeline: Create a "Pipeline" job in Jenkins pointing to this repository.

Access CMS: Once the build finishes, access your CMS at http://<EC2_IP>:8055.

## 📝 Key Features
Automated Cleanup: Includes a DESTROY_INFRA parameter to tear down AWS resources instantly.

Zero-Manual Config: The server is bootstrapped with Docker via Terraform user_data.

Environment Isolation: Uses .env generation on-the-fly to keep secrets out of source control.
