# <makefile>
help:
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//'`); \
	for help_line in $${help_lines[@]}; do \
	    IFS=$$'#' ; \
	    help_split=($$help_line) ; \
	    help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
	    help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
	    printf "%-30s %s\n" $$help_command $$help_info ; \
	done
# </makefile>

default: ; @echo 'no target provided'

check-env:
ifndef VAULT_PASSWORD_FILE
	$(error VAULT_PASSWORD_FILE is undefined)
endif

prod-provision: check-env
	cd configure && ansible-playbook -i prod prod-provision.yml --vault-password-file ${VAULT_PASSWORD_FILE} -vvv

decrypt:
	ansible-vault decrypt configure/group_vars/prod/vars.yml --vault-password-file ${VAULT_PASSWORD_FILE}
	ansible-vault decrypt configure/group_vars/test/vars.yml --vault-password-file ${VAULT_PASSWORD_FILE}

encrypt:
	ansible-vault encrypt configure/group_vars/prod/vars.yml --vault-password-file ${VAULT_PASSWORD_FILE}
	ansible-vault encrypt configure/group_vars/test/vars.yml --vault-password-file ${VAULT_PASSWORD_FILE}

prod-deploy: check-env
	cd configure && ansible-playbook -i prod prod-deploy.yml --tags  deploy-appserver,deploy-web --vault-password-file ${VAULT_PASSWORD_FILE} -vvv

#Reference command: APPLICATION_ZIP_PATH=/Users/himeshr/IdeaProjects/SamanvayOrg/budget-planner-server/build/libs APPLICATION_ZIP_FILE_NAME=budget-planner-server-0.0.1-SNAPSHOT.jar WEBAPP_ZIP_PATH=/Users/himeshr/IdeaProjects/SamanvayOrg/budget-planner-web WEBAPP_ZIP_FILE_NAME=budget-planner-web.zip make prod-deploy VAULT_PASSWORD_FILE=~/.ssh/budget-valut-pwd-file