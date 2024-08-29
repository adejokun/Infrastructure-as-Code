## Employee Directory Application leveraging AWS Autoscaling Group, Amazon S3, and Amazon DynamoDB

This template deploys an application that collects Employee information and stores in a backend database comprising Amazon Simple Storage Service (Amazon S3) and DynamoDB. The application is hosted on a load-balanced and auto-scaled architecture of EC2 instances

Autoscaling is achieved by deploying an autoscaling group comprising a custom launch template and scaling definitions, alongside a CloudWatch alarm.

DynamoDB is preferred over Amazon RDS due to its flexible billing model and superior performance in high-scale applications

The steps involved are given below:
1. Create the networking architecture - VPC, internet gateway, route tables, subnets
2. Configure an application load balancer
3. Create a launch template for EC2 instance
4. Define the IAM role that enables temporary credentials for API calls to Amazon S3 and DynamoDB
5. Configure the autoscaling group
6. Configure CloudWatch alarm
7. Create S3 bucket and DynamoDB table

Architecture is given below:
![Solution Architecture](https://github.com/adejokun/Infrastructure-as-Code/blob/main/Image/Architecture.png)