## Employee Directory Application leveraging Kubernetes, Managed Node Groups, Amazon S3, and Amazon DynamoDB

Kubernetes is an open-source container orchestration system for automatic deployment, scaling, and management of containerized applications. Amazon EKS is the offering from AWS that offers a fully managed kubernetes service to run seamless kubernetes workloads in the AWS Cloud.

This terraform script has been developed to automatically provision a kubernetes cluster and worker nodes to seamlessly run an employee directory application that leverages Amazon S3 and DynamoDB at the backend.

The overview of the deployment steps is given below:
1. Define foundational networking/security architecture - public subnets, private subnets, NAT gateway (NAT gateway is required for   internet connection to pods hosted in private subnets)
2. Create the kubernetes control plane in the public subnets. Associated relevant permissions by attaching required policy   (AmazonEKSClusterPolicy) to an IAM role
3. Create the worker nodes in the private subnets. Associated relevant permissions by attaching required policies    (AmazonEC2ContainerRegistryReadOnly, AmazonEKS_CNI_Policy, AmazonEKSWorkerNodePolicy, AmazonDynamoDBFullAccess, AmazonS3FullAccess) to an IAM role
4. Configure internet-facing Application Load Balancer Controller (alb) with helm:
    - create Service account for alb
    - associate an IAM OIDC (OpenID Connect) provider
5. Create a kubeconfig file that enables the kubectl command-line tool to communication with the API of the newly created kubernetes cluster

```
aws eks update-kubeconfig --region us-west-2 --name k8-dir-app
```
6. Apply the kubernetes deployment configuration (webapp.yaml)

```
kubectl apply -f https://raw.githubusercontent.com/adejokun/Infrastructure-as-Code/refs/heads/main/AWS/Containerized-employee-directory-application-with-K8/webapp.yaml 
```
