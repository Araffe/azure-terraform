# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "subscription-id"
  client_id       = "client-id"
  client_secret   = "M1crosoft123"
  tenant_id       = "tenant-id"
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

# Create a virtual network in the web_servers resource group
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_name}"
  address_space       = ["${var.address_space}"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "tf-subnet1"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.subnet_prefix}"
}

# Create an availability set
resource "azurerm_availability_set" "avset" {
  name                         = "${var.vm_name}-avset"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

# create public ip address
resource "azurerm_public_ip" "lbpip" {
    name                           = "${var.lb_name}-pip"
    location                       = "${var.location}"
    resource_group_name            = "${azurerm_resource_group.rg.name}"
    public_ip_address_allocation   = "dynamic"
}

# create network interface
resource "azurerm_network_interface" "nic" {
    name                = "${var.vm_name}-nic${count.index}"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    count               = 3

    ip_configuration {
        name                            = "tfipconfig${count.index}"
        subnet_id                       = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation   = "dynamic"
        load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.backend_pool.id}"]
    }
}

# create load balancer
resource "azurerm_lb" "lb" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  name                = "${var.lb_name}"
  location            = "${var.location}"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.lbpip.id}"
  }
}

# create load balancer backend pool
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "BackendPool1"
}

# create load balancer rule
resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "LBRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 3000
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
}

# create load balancer probe
resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "tcp3000Probe"
  protocol            = "tcp"
  port                = 3000
  interval_in_seconds = 5
  number_of_probes    = 2
}

# create virtual machine
resource "azurerm_virtual_machine" "vm" {
    name                    = "${var.vm_name}${count.index}"
    location                = "${var.location}"
    resource_group_name     = "${azurerm_resource_group.rg.name}"
    availability_set_id     = "${azurerm_availability_set.avset.id}"
    network_interface_ids   = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
    vm_size                 = "${var.vm_size}"
    count                   = 3

    storage_image_reference {
        publisher     = "${var.image_publisher}"
        offer         = "${var.image_offer}"
        sku           = "${var.image_sku}"
        version       = "${var.image_version}"
    }

  storage_os_disk {
    name              = "${var.hostname}-osdisk${count.index}"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

    os_profile {
        computer_name   = "${var.vm_name}${count.index}"
        admin_username  = "${var.admin_username}"
        admin_password  = "${var.admin_password}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }
}

resource "azurerm_virtual_machine_extension" "script" {
  name                 = "script${count.index}"
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_machine_name = "${var.vm_name}${count.index}"
  depends_on           = ["azurerm_virtual_machine.vm"]
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"
  count = 3

  settings = <<SETTINGS
    {
        "fileUris": ["${var.script_uri}"],
        "commandToExecute": "${var.script_command}"
    }
  SETTINGS
}
