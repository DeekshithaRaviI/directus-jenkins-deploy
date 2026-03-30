# 🚀 Automated Jenkins Directus Deployment on AWS
## 📖 Overview
This project demonstrates a production-grade CI/CD pipeline for deploying Directus Headless CMS on AWS. While the initial assessment suggested GitLab, I engineered this solution using Jenkins to showcase deep adaptability and expertise in custom pipeline orchestration.

## 🏗️ Architecture & Engineering
This repository implements Infrastructure as Code (IaC) to eliminate manual configuration errors:

Terraform: Automates the lifecycle of EC2 (t3.small), Security Groups, and RSA-4096 Key Pairs.

Jenkins Pipeline: A modular 6-stage workflow (Validate ➔ Plan ➔ Provision ➔ Deploy ➔ Test ➔ Cleanup).

Docker Orchestration: Directus and PostgreSQL 15 are deployed via Docker Compose with service_healthy conditions for database readiness.

Security-First: Zero secrets are hardcoded. Credentials (AWS IAM, DB Passwords, App Secrets) are injected at runtime via the Jenkins Credentials Store.

## 🛠️ Tech Stack

| Layer | Technology |
| :--- | :--- |
| **CI/CD** | Jenkins (Pipeline-as-Code) |
| **Cloud** | AWS (EC2, VPC, Security Groups) |
| **Infrastructure** | Terraform (IaC) |
| **Runtime** | Docker & Docker Compose |
| **Application** | Directus CMS & PostgreSQL |

## 💡 Problem Solving (Hiring Highlights)
I encountered and resolved several production-level challenges during this build:

Memory Optimization: Solved t3.micro RAM exhaustion by automating a 2GB Linux Swap partition via Terraform user_data.

Permission Automation: Eliminated Docker socket "Permission Denied" errors by automating group assignments in the bootstrap script.

Data Persistence: Implemented Docker Volumes to ensure CMS uploads and database records survive container restarts.

## 🚀 Quick Start
Plugins: Install Pipeline, Terraform, SSH Agent, and Credentials Binding in Jenkins.

Secrets: Add your IAM Keys and Directus credentials to the Jenkins Credentials Store.

Run: Point a Jenkins Pipeline job to this repo and click Build Now.

Cleanup: Use the DESTROY_INFRA parameter to tear down AWS resources and save costs.
