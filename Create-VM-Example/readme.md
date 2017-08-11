# Create 3 virtual machines under a Load balancer and configures Load Balancing rules for the VMs

This Terraform template creates a resource group, 3 virtual machines, a load balancer, and LB rule for Port 80. This template also deploys a virtual network, public IP address, availability set, and network interfaces. In addition, it will run a custom script on each VM to install a basic demo application. You can browse to the public IP address of the load balancer to see the application.

To run this template, you will need to create an Azure application / service principal and fill in the details inside the main.tf template.

## main.tf
The `main.tf` file contains the actual resources that will be deployed.

## variables.tf
The `variables.tf` file contains all of the input parameters that the user can specify when deploying this Terraform template.