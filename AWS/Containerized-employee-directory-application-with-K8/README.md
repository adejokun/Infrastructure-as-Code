## Employee Directory Application leveraging Kubernetes, Managed Node Groups, Amazon S3, and Amazon DynamoDB

### Introduction

Kubernetes is an open-source container orchestration system for automated deployment, scaling, coordination, and management of containerized applications. Amazon EKS is an AWS offering that offers a fully managed Kubernetes service to run seamless Kubernetes workloads in the AWS Cloud. (*Containers, unlike virtual machines, provide an isolated light-weight environment that enables fast and reliable deployment of applications*)

Examples of other container orchestrators include Amazon ECS (proprietary to AWS), Docker Swarm, Hashicorp Nomad.

An overview of the architecture of EKS is given below:

![EKS Architecture](https://github.com/adejokun/Infrastructure-as-Code/blob/main/Image/EKS-Architecture.png)

### Project Architecture and Deployment

This project presents a terraform script and accompanying Kubernetes configuration file that automates the provisioning of a kubernetes cluster comprising a control plane and worker nodes to seamlessly deploy a multi-tier application that leverages Amazon S3 and DynamoDB at the backend.

An overview of the architecture is given below:

![EKS Project Architecture](https://github.com/adejokun/Infrastructure-as-Code/blob/main/Image/EKS-Project-Architecture.png)

Deployment Steps:
1. Define foundational networking/security architecture - public subnets, private subnets, NAT gateway (NAT gateway is required for   internet connection to pods hosted in private subnets), security groups etc
2. Create a kubernetes control plane in the public subnets. Associate relevant permissions by attaching required policy   (AmazonEKSClusterPolicy) to an IAM role
3. Create a managed node group in the private subnets. Associate relevant permissions by attaching required policies    (AmazonEC2ContainerRegistryReadOnly, AmazonEKS_CNI_Policy, AmazonEKSWorkerNodePolicy, AmazonDynamoDBFullAccess, AmazonS3FullAccess) to an IAM role
4. Configure an internet-facing Application Load Balancer Controller (alb) with helm:
    - create Service account for alb
    - associate an IAM OIDC (OpenID Connect) provider
5. Create a kubeconfig file that enables the kubectl command-line tool to communicate with the API of the newly created kubernetes cluster

```
aws eks update-kubeconfig --region us-west-2 --name k8-dir-app
```
6. Create and apply the kubernetes deployment configuration (webapp.yaml)

```
kubectl apply -f https://raw.githubusercontent.com/adejokun/Infrastructure-as-Code/refs/heads/main/AWS/Containerized-employee-directory-application-with-K8/webapp.yaml 
```
7. Use the *kubectl get ingress* command to display the address of the load balancer controller. Paste displayed address in a browser to view application

```
kubectl get ingress/ingress-employee-dir -n employee-dir-app-02
```
