## Ecommerce Application with Azure VMSS + Application Gateway

This template deploys an ecommerce application on a Virtual Machine Scale Set (VMSS) equipped with an Appplication Gateway to periodically monitor the health and CPU utilization of Virtual Machines within the VMSS and direct web traffic accordingly. Unlike traditional load balancers that route requests based only on source and destination IP addresses/ports, Application Gateway can make smart traffic routing decisions based on details in the HTTP requests themselves.

A VMSS enables optimal utilization of resouces by incorporating autoscaling of Virtual Machines based on pre-defined rules. These rules either scale-in or scale-out the VMSS by decreasing or increasing the Virtual Machine instances ultimately ensuring cost-optimization of resources

The steps involved are given below:
1. Create Application Gatewy (AG) - including frontend, routing rules, and backend pool
2. Create VMSS with custom script to install Apache web server and ecommerce application
3. Create Network Security Group and associate with network interface of VMSS. Add an inbound security rule to allow web traffic from the internet
4. Enable autoscaling on the VMSS