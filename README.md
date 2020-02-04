# DevOps-Minds-30-Jan
This repository contains all resources used on the DevOps Minds - The Magic of IaC in the cloud held on 30 January 2020, sponsored by BULPROS. For more info you can check the event [page](http://events.bulpros.com/devopsminds/?fbclid=IwAR1BHD_XN2jkEO150v6mAc89ZxK7eI7stn0w1M2kF3t5-GBK3arHi6sll-s) .

## Agenda 

1. Show how to initialize Kubernetes Cluster based on AWS EKS via terraform scripts

1.1. Define local variables to be used over the terraform script

1.2. Define provider - AWS

1.3. Define Terraform requirements such as S3 bucket to store the Terraform state file

1.4. Define Amazon VPC for the EKS cluster

1.5. Define Amazon EKS

1.6. Define Amazon ECR to be used later on

 

2. Install and Setup Jenkins CI/CD instance in the K8S cluster

2.1. Initialize helm on the K8s cluster

2.2. Setup Jenkins helm chart.

2.3. Install Jenkins as a helm chart.

 

3. Build containerized application and push the image to ECR

3.1. Create an application

3.2. Create a Dockerfile for the application

3.3. Build and push the image to ECR( previosly created via Terraform on step 1)

 

4. Get the new app to the K8S Cluster 

4.1. Define a helm chart / K8s manifest for the application

4.2. Setup Jenkins job to deploy the new application

4.3. Deploy the application to K8s via Jenkins job defined on the previous step

## Notes

Quick setup of an EKS cluster with EKSCTL [HERE](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html) 

> eksctl create cluster  --name demo-cluster-1 --version 1.14  --region eu-central-1 --nodegroup-name standard-workers  --node-type t2.micro  --nodes 3  --nodes-min 1  --nodes-max 3  --ssh-access  --ssh-public-key my-public-key.pub  --managed

Delete EKS cluster
> eksctl delete cluster --name demo-cluster-1