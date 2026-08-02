# learnit-project-devops-infra

Infrastructure-as-Code for the LearnIT DevOps diploma project. This repo provisions
the AWS infrastructure (Terraform) and configures it (Ansible) for the application
repository, a fork of
[TechPrimers/spring-jpa-hibernate-mysql-example](https://github.com/TechPrimers/spring-jpa-hibernate-mysql-example).

## Architecture

```
                 ┌─────────────────────────────────────────────┐
                 │                  AWS (eu-central-1)          │
                 │                                              │
                 │   VPC 10.0.0.0/16                            │
                 │   └── public subnet 10.0.1.0/24              │
                 │        ├── app_server (EC2, t3.micro)        │
                 │        │     Docker + deployed app (:8080)   │
                 │        │                                     │
                 │        └── jenkins_server (EC2, t3.small)    │
                 │              Jenkins (:8080) + Docker         │
                 └─────────────────────────────────────────────┘
```

- **app_server** — runs the Dockerized Spring Boot application.
- **jenkins_server** — runs Jenkins, builds the app, builds/pushes the Docker
  image, and triggers deployment to `app_server` on commits to `main`.
- Terraform state is stored remotely in an **S3 backend** with native state
  locking (`use_lockfile`), so runs are safe to repeat and share.
- Terraform writes `ansible/inventory.ini` automatically from
  `ansible/inventory.tmpl` after `apply`, so Ansible always targets the
  currently-provisioned IPs.

## Repository contents

| Path | Purpose |
|---|---|
| `providers.tf` | Terraform/AWS provider config + S3 backend |
| `variables.tf` | Region, instance types, AMI, key pair name, allowed SSH CIDR |
| `network.tf` | VPC, public subnet, internet gateway, route table |
| `security.tf` | Security groups (app server, Jenkins server) |
| `main.tf` | SSH key pair, `app_server` and `jenkins_server` EC2 instances |
| `outputs.tf` | Public IPs + generates `ansible/inventory.ini` |
| `ansible/playbook.yml` | Installs Docker + UFW on `app_server`, Jenkins + Docker + UFW on `jenkins_server` |
| `ansible/inventory.tmpl` | Template consumed by Terraform to produce the real inventory |
| `ansible/ansible.cfg` | Ansible defaults (inventory path, host key checking, etc.) |

## Prerequisites

- An AWS account and credentials configured locally (`aws configure` or
  environment variables).
- An S3 bucket for the Terraform state backend
  (`learnit-project-terraform-state-bucket` in `providers.tf`, or override it).
  This bucket must exist **before** the first `terraform init` — create it once,
  manually or with a small bootstrap script; it is intentionally not managed by
  this same Terraform state to avoid a chicken-and-egg problem.
- A local SSH key pair at `~/.ssh/id_rsa` / `~/.ssh/id_rsa.pub` (used to log
  into both EC2 instances).
- Terraform >= 1.0, Ansible, and an SSH client installed locally.

## Deploying from scratch

```bash
# 1. Provision the infrastructure
terraform init
terraform apply

# 2. Configure the servers (installs Docker, Jenkins, firewall rules, etc.)
cd ansible
ansible-playbook -i inventory.ini playbook.yml
```

That's it — two commands (`terraform apply`, `ansible-playbook`) take the
project from nothing to a running Jenkins + app-ready host. Re-running either
command is safe: Terraform only changes what's drifted, and every Ansible task
uses idempotent modules (`apt`, `service`, `ufw`, ...).

After `ansible-playbook` finishes, the play prints the Jenkins initial admin
password so you can log in at `http://<jenkins_public_ip>:8080` and finish the
setup wizard.

## Security notes

- HTTP (80) and the app/Jenkins port (8080) are open to `0.0.0.0/0` since this
  is a public demo/course environment.
- SSH (22) is controlled by `var.ssh_allowed_cidr` (defaults to
  `0.0.0.0/0` for convenience) — set it to your own IP, e.g.
  `terraform apply -var="ssh_allowed_cidr=1.2.3.4/32"`, to lock it down.

## Tearing down

```bash
terraform destroy
```

## Related repository

The application source, Dockerfile, and CI/CD pipeline (Jenkinsfile /
GitHub Actions) live in the separate application repository (fork of
`spring-jpa-hibernate-mysql-example`), linked from this project's diploma
submission.
