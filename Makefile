#From https://gist.github.com/mpneuried/0594963ad38e68917ef189b4e6a269db
# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

ifeq ($(strip $(tags)),)
tags := all
endif

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

pushkeys: ## Push Ansible ssh Keys
	ansible-playbook -i inventories/bee-server.yaml roles/tools/authorized_key.yaml -k

upgrade: ## Update and upgrade OS
	ansible-playbook -i inventories/bee-server.yaml roles/tools/upgrade.yaml -b

check: ## Check HomeBee Ansible Deployment
	ansible-playbook -i inventories/bee-server.yaml roles/bee.yaml -b --check --diff --tags $(tags)

mastodon-init: ## Init Mastodon DB Deploy and Start Mastodon Ansible Deployment. ***No init force over existing DB***
	ansible-playbook -i inventories/bee-server.yaml roles/bee.yaml --extra-vars 'command_init="rails db:setup" init_db=true' -b --diff --tags mastodon

update: ## Update HomeBee Ansible Deployment
	ansible-playbook -i inventories/bee-server.yaml roles/bee.yaml -b --diff --tags $(tags)

start: update ## Alias: Update and Start HomeBee Ansible Deployment

deploy: update ## Alias: Update and Start HomeBee Ansible Deployment

restart: ## Update and Restart HomeBee Ansible Deployment
	ansible-playbook -i inventories/bee-server.yaml roles/bee.yaml --extra-vars 'command_restart=true' -b --diff --tags $(tags)

stop: ## Update and stop HomeBee Ansible Deployment
	ansible-playbook -i inventories/bee-server.yaml roles/bee.yaml --extra-vars 'command_stop=true' -b --diff --tags $(tags)

clean: ## remove stopped containers and unused networks
	ansible-playbook -i inventories/bee-server.yaml roles/tools/cleanup.yaml
