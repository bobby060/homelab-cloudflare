# Cloudflare tunnels with terraform
This repo uses Terraform to expose local apps running on docker as zero trust cloudflare tunnel applications

There are three components to this:

1. **Terraform: tunnel, routes, DNS, and Access**
Services are entries in the `services` map in `deployment/apps.tf`. Access groups and policies live in `deployment/groups.tf`; the emails in each group come from `terraform.tfvars`.

Access apps allow every login method set up in your Zero Trust organization.

2. **Cloudflared container** (`compose.yml`)

3. **Shared docker network** that cloudflared and every app join

## Prerequisites

- A Zero Trust organization (team domain) with at least one login method enabled, e.g. One-time PIN
- No existing DNS records at the hostnames you're adding
- A Cloudflare API token with these permissions:
  - Account → Cloudflare Tunnel: Edit
  - Account → Access: Apps and Policies: Edit
  - Account → Access: Organizations, Identity Providers, and Groups: Edit
  - Zone → DNS: Edit (for your domain)

Export the token before running Terraform:

```bash
export CLOUDFLARE_API_TOKEN=<your api token>
```

## Setup steps

1. Create the tunnel network

```bash
docker network create tunnel
```

2. Add each app to the tunnel network

In each app's compose file, declare the network and attach the service that cloudflared should reach:

```yaml
services:
  immich-server:
    # ...
    networks: [tunnel]

networks:
  tunnel:
    external: true
```

The service or container name (`immich-server` here) is the host you use in the `service` URL in `apps.tf`.

3. Configure Terraform

```bash
cp deployment/terraform.tfvars.example deployment/terraform.tfvars
```

Fill in your account ID, zone ID, domain, and the emails for each group.

4. Add each app to terraform

Add an entry to the `services` map in `deployment/apps.tf` (there are examples there). Set `access` to policy names from `groups.tf`, or leave it out to make the service public.

5. Apply terraform

From the `deployment` folder

`terraform init`, `terraform plan`, then `terraform apply`

Get the tunnel token from terraform

```bash
terraform output -raw tunnel_token
```

Put that in a .env file in this repo root (same level as this README.md)

```text
TUNNEL_TOKEN=<your token>
```

6. Run `docker compose up -d` to deploy the tunnel.

Badabing, everything should work.

## Notes

- `terraform.tfstate` holds the tunnel secret and token in plain text. It's gitignored; keep it out of the repo.
- Native/mobile clients (e.g. the Immich app) can't complete the Access browser login. They need a service token or a bypass policy.
