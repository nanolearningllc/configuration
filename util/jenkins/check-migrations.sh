#!/usr/bin/env bash
set -x

if [[
        -z $WORKSPACE       ||
        -z $environment     ||
        -z $deployment
    ]]; then
    echo "Environment incorrect for this wrapper script"
    env
    exit 1
fi


env
cd $WORKSPACE/edx-platform

# install requirements
pip install --exists-action w -r requirements/edx/pre.txt
pip install --exists-action w -r requirements/edx/base.txt
pip install --exists-action w -r requirements/edx/post.txt
pip install --exists-action w -r requirements/edx/repo.txt
pip install --exists-action w -r requirements/edx/github.txt
pip install --exists-action w -r requirements/edx/local.txt

cd $WORKSPACE/configuration/playbooks/edx-east

if [[ -f ${WORKSPACE}/configuration-secure/ansible/vars/${environment}.yml ]]; then
  extra_var_args+=" -e@${WORKSPACE}/configuration-secure/ansible/vars/${environment}.yml"
fi

extra_var_args+="-e@${WORKSPACE}/configuration-secure/ansible/vars/${environment}-${deployment}.yml"

ansible_cmd="ansible-playbook -c local $extra_var_args -e edxapp_user=jenkins -e edxapp_app_dir=${WORKSPACE} --tags edxapp_cfg -i localhost, -s -U jenkins edxapp.yml"

cd $WORKSPACE/edx-platform

$ansible_cmd
#if [ $dry_run = "true" ]; then
#  db_dry_run="--db-dry-run"
#fi

#$migration_cmd $db_dry_run
