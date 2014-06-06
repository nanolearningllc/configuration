#!/usr/bin/env bash
set -x
env
ansible_cmd=ansible-playbook -c local -e@${WORKSPACE}/configuration-secure/ansible/vars/prod-mckinsey.yml -e edxapp_user=jenkins -e edxapp_app_dir=${WORKSPACE} --tags edxapp_cfg -i localhost, -s -U jenkins edxapp.yml

cd $WORKSPACE/configuration
pip install -r requirements.txt
cd $WORKSPACE/edx-platform

# install requirements
pip install --exists-action w -r requirements/edx/pre.txt
pip install --exists-action w -r requirements/edx/base.txt
pip install --exists-action w -r requirements/edx/post.txt
pip install --exists-action w -r requirements/edx/repo.txt
pip install --exists-action w -r requirements/edx/github.txt
pip install --exists-action w -r requirements/edx/local.txt

cd $WORKSPACE/configuration/playbooks/edx-east
$ansible_cmd

$tunnel_cmd

cd $WORKSPACE/edx-platform

#if [ $dry_run = "true" ]; then
#  db_dry_run="--db-dry-run"
#fi

#$migration_cmd $db_dry_run
