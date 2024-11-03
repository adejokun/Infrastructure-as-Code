## Employee Directory Application leveraging ECS, Fargate, Amazon S3, and Amazon DynamoDB

This configuration deploys a containerized application that leverages Amazon ECS and Fargate. Containers, unlike virtual machines, provide an isolated light-weight environment that enables fast and reliable deployment of applications. Amazon ECS is a container management service that facilitates the deployment and management of these containers on a cluster. AWS Fargate is a managed severless compute platform for ECS and EKS, abstracting the underlying EC2 instances.

The simple steps to derive the configuration are given below:

1. Build image from Dockerfile
2. Push image to Amazon ECR
3. Task definition
  - Create IAM task role (temporary credentials to interact with s3 and DynamoDB)
  - Create IAM task execution role (temporary credentials to pull image from ECR)
  - Configure container definition(s)
4. Define cluster
  - Configure application load balancer to distribute traffic to tasks
  - Configure ECS service autoscaling with target tracking 
5. Create service within cluster
  


