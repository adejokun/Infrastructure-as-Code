## Ecommerce Application with Azure VMSS + Load Balancer

This template deploys an ecommerce application on a Virtual Machine Scale Set (VMSS) equipped with a Load Balancer to periodically monitor the health and CPU utilization of Virtual Machines within the VMSS and direct web traffic accordingly.

A VMSS enables optimal utilization of resouces by incorporating autoscaling of Virtual Machines based on pre-defined rules. These rules either scale-in or scale-out the VMSS by decreasing or increasing the Virtual Machine instances ultimately ensuring cost-optimization of resources

The steps involved are given below:
1. Create Load Balancer (Lb) - including Lb probe, frontend, backend pool, and Lb rules
2. Create VMSS with custom script to install Apache web server and ecommerce application 
3. Create Network Security Group and associate with network interface of VMSS. Add an inbound security rule to allow web traffic from the internet
4. Enable autoscaling on the VMSS
