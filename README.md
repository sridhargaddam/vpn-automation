# VPN Automation (using VNF) POC

This repo has ansible playbooks to automate a VNF creation in an OpenStack setup.

We spawn a CentOS7 VM (as a VNF) in an OpenStack tenant network, install StrongSwan/other-necessary-utilities in the VNF and finally setup IPSEC tunnel to AWS VPC Gateway.

The topology would be as shown below.


## Pre-setup

* Edit cloud.yml with the necessary credentials to your cloud.
* Edit inventory file and set 'ssh_key' to the right value
* Edit the strongswan config files with the appropriate AWS VPC Gateway Credentials.

## Getting Started

To create the necessary neutron networks, subnets, routers and to spawn the VNF, run the following playbook.

```bash
$ ansible-playbook setup-vnf-rdocloud.yml
```

To spawn a tiny VM on the tenant network to validate reachability to AWS VPC, use the following playbook.

```bash
$ ansible-playbook spawn-vm.yml
```
