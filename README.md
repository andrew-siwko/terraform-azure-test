# Andrew's Multicloud Terraform Experiment
## Overview
This experiment uses Terraform to create a single virtual machine on Microsoft's Azure.  It is part of a series of experiments begun in early 2026.  I have structured the Terraform files with sequence numbers to show the logical flow of resource creation.  Roughly the sequence is:
* 00-create-resources.bash
  * This file contains shell commands and notes used to manipulate the clound environment from the CLI.  My approach has been to make things work and then Terraform them.  Thus you may see commands to discover the instance types which I used to hard code server creation.  These were later replaced with lookups inside terraform.  the commands and notes may still be useful.
* 01-variables.auto.tfvars, 01-variables.tf
  * The two variable files contain parameters factored out of the main code and their definitions.  As the configuration code matured and I added more cloud providers, it became clear that certain parameters could be pulled up for ease of use.
* 02-providers.tf
  * This file contains the top level terraform{} block which contains required providers, by necessity, the backend definition and connects providers to required variables.  i would hav eliked to split the backend into a separate file but there may only be one terraform{} block and the rest of the world uses providers.  In these projects I have stored the tfstate file on the clound provider rather than defining local storage.  I found this proceess to be difficult and educational.
* 03-network.tf
  * This file specifies network elements.  In a basic, single VM case, it is not generally needed.  As soon as you want to control traffic with a firewall or security group, the network definition is required to attach the rules.
* 04-security-group.tf, 04-firewall.tf, 04-security-list.tf
  * This file defines how network traffic flows in and out of the network to your instance.
* 05-ec2.tf, 05-machine.tf, 05-droplet.tf, 05-servers.tf
  * This file contains the virtual machine definition and mapping to other resources.
* 06-domain.tf
  * This small file contains the DNZ zone resource for a Linode zone and an A record for the IP address of the virtual machine.  The zone record is imported from the existing Linode zone and is marked as "prevent_destroy" to avoind domain deletion.
* 07-outputs.tf
  * This file contains outputs from Terraform state at the end of the process.  During development, I leaned on this heavily to discover internal states and key names.  Once finished, I leave the public IP of the instance in the output for validation.

Except for Linode, wich whom I have an existing paid relationship, all other instances were provisioned using a free trial.
Once Terraform provisioning is complete, I use Ansible to configure and install Tomcat, set an apache proxy and install a sample application.  [More on that later...](https://github.com/andrew-siwko/ansible-multi-cloud-tomcat-hello)<br/>
It all starts with the [Cloud Console](https://portal.azure.com/).

## Multicloud
I tried to build the same basic structures in each of the cloud environments.  Each one starts with providers (and a backend), lays out the network and security, creates the VM and then registers the public IP in my DNS.  There is some variability which has been interesting to study.  The Terraform state file is stored on each provider.
* Step 1 - [AWS](https://github.com/andrew-siwko/terraform-aws-test)
* Step 2 - [Azure](https://github.com/andrew-siwko/terraform-azure-test) (you are here)
* Step 3 - [GCP](https://github.com/andrew-siwko/terraform-gcp-test)
* Step 4 - [Linode](https://github.com/andrew-siwko/terraform-linode-test)
* Step 5 - [IBM](https://github.com/andrew-siwko/terraform-ibm-test)
* Step 6 - [Oracle OCI](https://github.com/andrew-siwko/terraform-oracle-test) 
* Step 7 - [Digital Ocean](https://github.com/andrew-siwko/terraform-digital-ocean-test)

## Build Environment
I stood up my own Jenkins server and built a freestyle job to support the Terraform infrastructure builds.
* terraform init
* _some bash to import the domain (see below)_
* terraform plan
* terraform apply -auto-approve
* terraform output (This is piped to mail so I get an e-mail with the outputs.)

Yes, I know plan and apply should be separate and intentional.  In this case I found defects in plan which halted the job before apply.  That was useful.  I also commented out apply until plan was pretty close to working.<br/>
The Jenkins job contains environment variables with authentication information for the cloud environment and [Linode](https://www.linode.com/) (my registrar).<br/>
I did have a second job to import the domain zone but switched to a conditional in a script.  The code checks to see whether my zone record has been imported.  If not, the zone creation will fail.
```bash
if ! terraform state list | grep -q "linode_domain.dns_zone"; then
  echo "Resource not in state. Importing..."
  terraform import linode_domain.dns_zone 3417841
else
  echo "Domain already managed. Skipping import."
fi
```

## Observations
* Azure was the second cloud provider I provisioned with Terraform.
* I spent about 1 day getting the whole project working.
* The az cli installed easily and was critical to success.
* I had to create the bucket with the cli as I did not know how to do that with Terraform.
* Microsoft is less generous with cores and I realized from the start I could only afford one instance with Tomcat.
* I settled on Standard_L2aos_v4 after searching using the cli.
* Since AWS defined an admin user of ec2-user and Azure had an option for setting the admin user name, I set it to azureuser.  I don't know why I didn't try root, all the other providers use root.
* Here's the answer: 
  * Error: "admin_username" specified is not allowed, got "root", cannot match: "administrator, admin, user, user1, test, user2, test1, user3, admin1, 1, 123, a, actuser, adm, admin2, aspnet, backup, console, david, guest, john, owner, root, server, sql, support, support_388945a0, sys, test2, test3, user4, user5"
  * I wonder who david and john are.
* The Azure console was clear and easy to use.
* Project stats:
  * Start: 2026-01-17
  * Functional: 2026-01-17
  * Number of Jenkins builds to success: 49
  * Hurdles: 
    * Free resource constraints
* My free trial ended 2026-02-08 and all sevices were suspended.


