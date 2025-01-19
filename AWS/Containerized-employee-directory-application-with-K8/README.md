## Employee Directory Application leveraging Kubernetes, Managed Node Groups, Amazon S3, and Amazon DynamoDB

Kubernetes is an open-source container orchestration system for automatic deployment, scaling, coordination, and management of containerized applications. Amazon EKS is the offering from AWS that offers a fully managed kubernetes service to run seamless kubernetes workloads in the AWS Cloud.

This terraform script and accompanying yaml configuration file have been developed to automatically provision a kubernetes cluster comprising a control plane and worker nodes to seamlessly run an employee directory application that leverages Amazon S3 and DynamoDB at the backend.

The overview of the deployment steps is given below:
1. Define foundational networking/security architecture - public subnets, private subnets, NAT gateway (NAT gateway is required for   internet connection to pods hosted in private subnets)
2. Create a kubernetes control plane in the public subnets. Associate relevant permissions by attaching required policy   (AmazonEKSClusterPolicy) to an IAM role
3. Create a managed node group in the private subnets. Associate relevant permissions by attaching required policies    (AmazonEC2ContainerRegistryReadOnly, AmazonEKS_CNI_Policy, AmazonEKSWorkerNodePolicy, AmazonDynamoDBFullAccess, AmazonS3FullAccess) to an IAM role
4. Configure an internet-facing Application Load Balancer Controller (alb) with helm:
    - create Service account for alb
    - associate an IAM OIDC (OpenID Connect) provider
5. Create a kubeconfig file that enables the kubectl command-line tool to communicate with the API of the newly created kubernetes cluster

```
aws eks update-kubeconfig --region us-west-2 --name k8-dir-app
```
6. Apply the kubernetes deployment configuration (webapp.yaml)

```
kubectl apply -f https://raw.githubusercontent.com/adejokun/Infrastructure-as-Code/refs/heads/main/AWS/Containerized-employee-directory-application-with-K8/webapp.yaml 
```
7. Use the *kubectl get ingress* command to display the address of the load balancer controller. Paste displayed address in a browser to view application

```
kubectl get ingress/ingress-employee-dir -n employee-dir-app-02
```
