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

Add an entry to the `services` map in `deployment/apps.tf` (there are examples there). Set `access` to policy names from `groups.tf`, or leave it out to make the service public. If native or mobile apps need to reach the service, also set `service_token = true` (see [App access with service tokens](#app-access-with-service-tokens)).

5. Apply terraform

From the `deployment` folder

`terraform init`, `terraform plan`, then `terraform apply`

6. Get the tunnel token from terraform

```bash
terraform output -raw tunnel_token
```

Put that in a .env file in this repo root (same level as this README.md)

```text
TUNNEL_TOKEN=<your token>
```

7. Run `docker compose up -d` to deploy the tunnel.

Badabing, everything should work.

## SSH

The `ssh` entry in `apps.tf` exposes this machine's sshd at `ssh.<domain>`, behind the admins policy. cloudflared reaches the host through `host.docker.internal` (set in `compose.yml`). If ufw is on, allow the docker network to reach port 22:

```bash
sudo ufw allow from 172.18.0.0/16 to any port 22 proto tcp
```


### Client SSH Access Instructions
**From a terminal:** install `cloudflared` on your laptop and add to `~/.ssh/config`:

```text
Host ssh.<domain>.com
  ProxyCommand cloudflared access ssh --hostname %h
  User <server username>
  
```

Then `ssh ssh.<domain>.com`. The first connection opens a browser for the Access login.

**From a browser:** open `https://ssh.<domain>.com`, log in through Access, then enter your username and private key (or password if you don't do the SEC in DevSecOps)

## App access with service tokens

Native and mobile clients (e.g. the Karakeep or Immich apps) can't complete the Access browser login. If the client lets you set custom headers, give the service an Access service token instead:

```hcl
karakeep = {
  name          = "Karakeep"
  subdomain     = "karakeep"
  service       = "http://karakeep:3000"
  access        = ["admins"]   # browser logins still work
  service_token = true
}
```

This creates a service token and a `non_identity` (Service Auth) policy for that app. `access` is optional when `service_token` is set, so you can have an app that only accepts the token.

After `terraform apply`, get the credentials:

```bash
terraform output -json service_tokens
```

Then configure the client to send these headers on every request:

```text
CF-Access-Client-Id: <client_id>
CF-Access-Client-Secret: <client_secret>
```

The app's own auth (e.g. Karakeep's API key in `Authorization`) is unaffected.

**Single-header clients:** if the client can only send one custom header, also set `service_token_header = "X-Access-Token"` (any name). The client then sends that header with a JSON value:

```text
X-Access-Token: {"cf-access-client-id":"<client_id>","cf-access-client-secret":"<client_secret>"}
```

**Notes:**
- Tokens expire after one year by default, after which the app will be blocked. Set `service_token_duration = "forever"` on the service for a non-expiring token.
- The client secret is stored in plain text in `terraform.tfstate`, so keep that file private.
- Anyone with the token gets through Access, so treat it like a password.
