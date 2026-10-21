# Terraform

Terraform configuration and setup for multi-cloud infrastructure as code (IaC).

## Configuration files

- `config-files/provider.tf` defines the cloud provider configuration. The example
  configures AWS in `us-east-1`.
- `config-files/main.tf` defines infrastructure resources, including a VPC and
  subnet.
- `config-files/version.tf`where we can define terrafrom and provider version
- `config-files/variables.tf`where we can verbalise the values
- `config-files/terraform.tfvars` where we can pass the values to variables
- `config-files/output.tf`where we can print the values
- `config-files/terraform.tfstate`where we can print the values

## Resource dependencies

Terraform determines the order in which resources are created and destroyed from
their dependencies:

- **Implicit dependency:** Referencing another resource's attribute creates a
  dependency automatically. In `main.tf`, `aws_subnet.dev_subnet` uses
  `aws_vpc.dev.id`, so Terraform creates the VPC before the subnet and destroys
  the subnet before the VPC.
- **Explicit dependency:** Use `depends_on` when one resource relies on another
  for behavior that is not represented by an attribute reference.

The subnet also includes `depends_on = [aws_vpc.dev]` as an explicit dependency
example. It is redundant because `vpc_id` already references the VPC; in normal
configurations, prefer the implicit dependency and reserve `depends_on` for
dependencies Terraform cannot infer.

# Variables

No hard coded values in the resources configuration file.

# Commands

`tf init`initialises all plugins and packages from terraform repository

`tf plan`show preview of resources creating

`tf apply -auto-approve`create resources in aws need to configure the aws credentials for this command to run.


# terraform.tfstate

When terraform state file is not there first time it will create infrastructure resources on aws and creates a state file in the local 

For next requests it first verifies the state file whether it is change or add request.

Changes will be always from local to dev direction not from remote to code direction

For example some one changed a dev tagged instance on remote with test again the test will be modified to dev. 1 to change.

If the state file is changed no code changed code and remote are in sync when tf plan it says no change but tf apply will refresh the state to remote state.
