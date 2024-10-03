no# myHomeBee

Run home Debian Linux multipurpose server

- Docker only
- Ansible deployment script

(I used Beelink S12 Pro)

**Content:**
- General tools, keys, etc
- Plex Media Server
- Transmission
- acpid to enable Power-Off key
- Prometheus / Grafana for monitoring
- Mastodon server
- GitHub Actions Runner
- Mastodon Maintenance Automation 
- Pi-hole for local DNS
- Home Assistant
- Motion (USB Cam to RTSP, Motion Detection)
- Zigbee2MQTT
- MJPEG Streamer (http://localhost:8090/?action=stream)


# Preparation steps

**On the target host**
- Install minimal no-UI Debian deployment with sshd. UEFI boot, GPT, LVM with distro auto-partitioning are recommended.
- Install sudo
- Add your user to the sudo group
- Create DHCP reservation on your router/DHCP server

**On your PC:**
- Install Ansible, git, make, sshpass
- Create ssh keys if you haven't had it yet
- Add your target host IP and desired host name to /etc/hosts
- Clone this repo

# Deploying the server

## Creating secrets
Create secrets only for services you are going to use.
copy example.config.env to config.env and pace your passwords (sudo and ansible-vault) there. Keep it private, or don't use it at all.

### Create Mastodon secrets
Refer to mastodon docs for details https://docs.joinmastodon.org/admin/install/#creating-a-new-mastodon-instance

```shell
ansible-vault create inventories/group_vars/mastodon.yaml
```
and paste
```yaml
---
vault_cloudflared_api_key: <your_cloudflared_api_key>
vault_postgres_password: <your_postgres_password>
vault_secret_key_base: <your_mastodon_secret_key_base>
vault_otp_secret: <your_mastodon_otp_secret>
vault_vapid_private_key: <your_mastodon_vapid_private_key>
vault_vapid_public_key: <your_mastodon_vapid_public_key>
vault_amtp_password: <your_smtp_password>
```
### Create Transmission secrets
```shell
ansible-vault create inventories/group_vars/transmission.yaml
```
and paste
```yaml 
---
vault_transmission_pass: <your_transmission_ui_password>
```
### Create Grafana secrets
```shell
ansible-vault create inventories/group_vars/monitoring.yaml
```
and paste
```yaml
---
vault_gf_security_admin_password: <your_grafana_admin_ui_pass>
```
### Create GitHub Runner secrets
```shell
ansible-vault create inventories/group_vars/garunner.yaml
```
and paste
```yaml
---
vault_gh_runner_token: <your_github_runner_token>
```

### Create Pi-hole secrets
```shell
ansible-vault create inventories/group_vars/pihole.yaml
```
and paste
```yaml
---
vault_pihole_web_password: <your_pihole_ui_password>
```

## Updating the inventory
Inventory file contains group, hosts and vars.
Each host-grou represents some service.
Edit inventories/bee-server.yaml. Add your host name to each host-groups you are interesting to use, and set proper variables values. 

## Make 
You can trigger ansible playbook using make targets (see details below)
Some targets accept ansible tags. Tag *All* is default if no tags provided

```shell
make <target> [tags=<tag1,tag2...>]
```
### Targets, available for tagging:
- check
- deploy
- update
- start
- stop
- restart

### Tags available:
- mastodon
- garunner
- monitoring
- plex
- transmission
- prereq

## Deploy ssh keys
```shell
make pushkeys
```
## Update/upgrade OS
```shell
make upgrade
```

## Test deployment
```shell
make check
```
## Init, run and deploy Mastodon
```shell 
make mastodon-init
```

## Init and run all services, except Mastodon db initialization
```shell 
make deploy
```

## For more info
```shell 
make help
```

# Backlog
- Combine Ha and zigbee2mqtt in one docker-compose, move mqtt to the internal network, protect zigbee2mqtt UI with password
- Some local https support with split-dns
- Nginx revers proxy for local services
- smtp to gmail local relay
- PhotoPrism
- Prometheus / Grafana for Alerting
- Mastodon Upgrade Automation