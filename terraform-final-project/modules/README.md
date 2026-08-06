# Terraform Module Library

This directory contains reusable infrastructure modules consumed by the root stack in the parent folder.

## Module Layout

Each module should keep the same basic contract:

- `variables.tf`: input interface for values supplied by a root module.
- `outputs.tf`: exported IDs, ARNs, names, and other values needed by other modules.
- Domain `.tf` files: resources and data sources owned by that module.
- Optional `versions.tf`: provider alias declarations or module-specific provider requirements.

The root stack composes these modules from `../main.tf` using local source paths such as:

```hcl
module "network" {
  source = "./modules/network"
}
```

## Boundaries

Modules should own resources for one infrastructure domain and expose only the outputs that other modules need. Cross-domain wiring should stay in the root module.

Examples:

- `network` owns VPCs, subnets, routes, NACLs, security groups, endpoints, and peering.
- `storage` owns S3, CloudFront, and EFS.
- `database` owns RDS and DynamoDB.
- `compute` owns EC2 launch templates, Auto Scaling, and optional admin instances.

## Reuse Guidance

When adding a new root stack later, prefer reusing these modules instead of copying resource files. Pass environment-specific values through variables and consume module outputs for dependencies.

Keep module inputs general enough for reuse, but avoid turning modules into broad catch-all abstractions. If a resource belongs to a different operational owner or lifecycle, place it in a separate module.
