#DO NOT CHANGE
include .env

LAUNCH_JSON_PATH = ../.vscode/launch.json
MANUAL_FILE = Makefile.1
COMPRESSED_MANUAL_FILE = $(MANUAL_FILE).gz
MAKEFILE_PATH = ./Makefile

# DESC: Opens an interactive terminal in the Odoo container as user "odoo".
bash:
	@docker exec -it ${PROJECT_NAME}-web /bin/bash

# DESC: Opens an interactive terminal in the Odoo container as user "root".
bash-root:
	@docker exec -u root -it ${PROJECT_NAME}-web /bin/bash

# DESC: Opens an interactive terminal in the PostgreSQL container as user "root".
bashdb:
	@docker exec -it ${PROJECT_NAME}-db /bin/bash

# DESC: Builds the local Docker image for the project, pulling the latest Docker image and initializing git submodules.
build:
	@docker rm ${PROJECT_NAME}-odoo-update --force; \
	mkdir -p tmp/; \
	docker pull ${DOCKER_IMAGE}; \
	git submodule update --init --recursive; \
	docker build -t ${PROJECT_NAME}-web-local --build-arg DOCKER_IMAGE=${DOCKER_IMAGE} .

# DESC: Deletes all log volumes related to Odoo and PostgreSQL.
clean-logs: rm
	@docker volume rm ${PROJECT_NAME}_odoo-logs ${PROJECT_NAME}_odoo-db-logs

# DESC: Deletes log volumes from PostgreSQL.
clean-db-logs: rm
	@docker volume rm ${PROJECT_NAME}_odoo-db-logs

# DESC: Deletes log volumes from Odoo.
clean-odoo-logs: rm
	@docker volume rm ${PROJECT_NAME}_odoo-logs

# DESC: Creates a launch.json file for debugging in VSCode.
create-launch-json:
	@echo "Creating launch.json file for debugging in VSCode..."; \
    echo "{" > ${LAUNCH_JSON_PATH} ;\
    echo '  "version": "0.2.0",' >> ${LAUNCH_JSON_PATH} ;\
    echo '  "configurations": [' >> ${LAUNCH_JSON_PATH} ;\
    echo '    {' >> ${LAUNCH_JSON_PATH} ;\
    echo '      "name": "Odoo: Attach",' >> ${LAUNCH_JSON_PATH} ;\
    echo '      "type": "python",' >> ${LAUNCH_JSON_PATH} ;\
    echo '      "request": "attach",' >> ${LAUNCH_JSON_PATH} ;\
    echo '      "port": 8069,' >> ${LAUNCH_JSON_PATH} ;\
    echo '      "justMyCode": false,' >> ${LAUNCH_JSON_PATH} ;\
    echo '      "debugServer": 8888,' >> ${LAUNCH_JSON_PATH} ;\
    echo '      "host": "localhost",' >> ${LAUNCH_JSON_PATH} ;\
    echo '      "pathMappings": [' >> ${LAUNCH_JSON_PATH} ;\
    echo '        {' >> ${LAUNCH_JSON_PATH} ;\
    echo '          "localRoot": "$${workspaceFolder}/src/odoo-base/odoo",' >> ${LAUNCH_JSON_PATH} ;\
    echo '          "remoteRoot": "/usr/lib/python3/dist-packages/odoo"' >> ${LAUNCH_JSON_PATH} ;\
    echo '        },' >> ${LAUNCH_JSON_PATH} ;\
    echo '        {' >> ${LAUNCH_JSON_PATH} ;\
    echo '          "localRoot": "$${workspaceFolder}/src/python-env/dist-packages",' >> ${LAUNCH_JSON_PATH} ;\
    echo '          "remoteRoot": "/usr/local/lib/python${PYTHON_VERSION_DOCKER}/dist-packages"' >> ${LAUNCH_JSON_PATH} ;\
    echo '        },' >> ${LAUNCH_JSON_PATH} ;\
    echo '        {' >> ${LAUNCH_JSON_PATH} ;\
    echo '          "localRoot": "$${workspaceFolder}/src/custom-addons",' >> ${LAUNCH_JSON_PATH} ;\
    echo '          "remoteRoot": "/mnt/custom-addons"' >> ${LAUNCH_JSON_PATH} ;\
    echo '        },' >> ${LAUNCH_JSON_PATH} ;\
    echo '        {' >> ${LAUNCH_JSON_PATH} ;\
    echo '          "localRoot": "$${workspaceFolder}/src/external-modified",' >> ${LAUNCH_JSON_PATH} ;\
    echo '          "remoteRoot": "/mnt/external-modified"' >> ${LAUNCH_JSON_PATH} ;\
    echo '        },' >> ${LAUNCH_JSON_PATH} ;\
    echo '        {' >> ${LAUNCH_JSON_PATH} ;\
    echo '          "localRoot": "$${workspaceFolder}/src/external-addons",' >> ${LAUNCH_JSON_PATH} ;\
    echo '          "remoteRoot": "/mnt/external-addons"' >> ${LAUNCH_JSON_PATH} ;\
    echo '        },' >> ${LAUNCH_JSON_PATH} ;\
    echo '        {' >> ${LAUNCH_JSON_PATH} ;\
    echo '          "localRoot": "$${workspaceFolder}/src/enterprise",' >> ${LAUNCH_JSON_PATH} ;\
    echo '          "remoteRoot": "/mnt/enterprise"' >> ${LAUNCH_JSON_PATH} ;\
    echo '        }' >> ${LAUNCH_JSON_PATH} ;\
    echo '      ]' >> ${LAUNCH_JSON_PATH} ;\
    echo '    }' >> ${LAUNCH_JSON_PATH} ;\
    echo '  ]' >> ${LAUNCH_JSON_PATH} ;\
    echo '}' >> ${LAUNCH_JSON_PATH} ;\
    echo "launch.json file created successfully!"

# DESC: Stops all containers and restarts them in debug mode.
debug: create-launch-json
	@if [ -d "./odoo-base" ]; then \
		read -p "Do you want to discard all changes you made on Odoo Base code? If Not, will start debug with your changes (y/n) " confirmation ; \
		if [ "$$confirmation" = "y" ] ; then \
			docker-compose -p=${PROJECT_NAME} down ; \
			mkdir ./odoo-base ; \
			mkdir ./python-env; \
			PWD=$(pwd); \
			docker run --rm -u root -v ${PWD}/odoo-base:/mnt/odoo-base -it  ${PROJECT_NAME}-web-local sh -c "rm /mnt/odoo-base/* -R"; \
			docker run --rm -u root -v ${PWD}/python-env:/mnt/python-env -it  ${PROJECT_NAME}-web-local sh -c "rm /mnt/python-env/* -R"; \
			pip=$$(docker run --rm -u root -it ${PROJECT_NAME}-web-local bash -c "python3 -c 'import site; print(site.getsitepackages()[0])'" | tr -d '\r'); \
			echo "Will copy Python libraries and Odoo base modules to local."; \
			echo "Copying python libraries to local..." ; \
			docker run --rm -u root -v ${PWD}/python-env:/mnt/python-env -it ${PROJECT_NAME}-web-local bash -c "rsync -aL --chmod=ugo+rwX $$pip /mnt/python-env"; \
			echo "Copying Odoo base modules to local..." ; \
			docker run --rm -u root -v ${PWD}/odoo-base:/mnt/odoo-base -it  ${PROJECT_NAME}-web-local sh -c "rsync -a -r --chmod=ugo+rwX /usr/lib/python3/dist-packages/odoo/ /mnt/odoo-base/odoo"; \
			echo "Copy complete!" ; \
			docker-compose -p=${PROJECT_NAME} -f docker-compose-debug.yml up -d ; \
		else \
			if [ "$$confirmation" = "n" ] ; then \
				docker rm ${PROJECT_NAME}-odoo-shell --force ; \
				docker-compose -p=${PROJECT_NAME} down ; \
				docker-compose -p=${PROJECT_NAME} -f docker-compose-debug.yml up -d ; \
			fi \
		fi \
	else \
		docker run --rm -u root -v ${PWD}/odoo-base:/mnt/odoo-base -it  ${PROJECT_NAME}-web-local sh -c "rm /mnt/odoo-base/* -R"; \
		docker run --rm -u root -v ${PWD}/python-env:/mnt/python-env -it  ${PROJECT_NAME}-web-local sh -c "rm /mnt/python-env/* -R"; \
		pip=$$(docker run --rm -u root -it ${PROJECT_NAME}-web-local bash -c "python3 -c 'import site; print(site.getsitepackages()[0])'" | tr -d '\r'); \
		echo "Will copy Python libraries and Odoo base modules to local."; \
		echo "Copying python libraries to local..." ; \
		docker run --rm -u root -v ${PWD}/python-env:/mnt/python-env -it ${PROJECT_NAME}-web-local bash -c "rsync -aL --chmod=ugo+rwX $$pip /mnt/python-env"; \
		echo "Copying Odoo base modules to local..." ; \
		docker run --rm -u root -v ${PWD}/odoo-base:/mnt/odoo-base -it  ${PROJECT_NAME}-web-local sh -c "rsync -a -r --chmod=ugo+rwX /usr/lib/python3/dist-packages/odoo/ /mnt/odoo-base/odoo"; \
		echo "Copy complete!" ; \
		docker-compose -p=${PROJECT_NAME} -f docker-compose-debug.yml up -d ; \
	fi

# DESC: Displays the size of the database in a readable format using PostgreSQL.
db-size:
	@docker exec -it ${PROJECT_NAME}-db psql -U odoo -d ${LOCAL_DATABASE_NAME} -c "SELECT pg_size_pretty(pg_database_size('${LOCAL_DATABASE_NAME}')) AS Database_Size;"

# DESC: Generates the manual file for the Makefile targets and descriptions.
generate-manual:
	@echo ".TH 'Makefile' 'User Manual' 'May 2024' 'Version 2.0'" > $(MANUAL_FILE)
	@echo ".SH MAKEFILE" >> $(MANUAL_FILE)
	@echo "Set of rules to automate common tasks in the project." >> $(MANUAL_FILE)
	@echo ".SH SYNOPSIS" >> $(MANUAL_FILE)
	@echo "make <target>" >> $(MANUAL_FILE)
	@echo ".SH DESCRIPTION" >> $(MANUAL_FILE)
	@grep -E '^[a-zA-Z0-9_-]+:|# DESC:' $(MAKEFILE_PATH) | \
	awk '/# DESC:/{desc=$$0; next} {gsub(/:$$/,""); print ".SS "$$1"\n"substr(desc,8)}' >> $(MANUAL_FILE)
	@gzip -f $(MANUAL_FILE)
	@echo "Manual file generated: $(COMPRESSED_MANUAL_FILE)"

# DESC: Displays this help manual.
.PHONY: help
help: generate-manual
	@man ./$(COMPRESSED_MANUAL_FILE)

# DESC: Starts the log viewer for the Odoo server using lnav.
log:
	docker rm ${PROJECT_NAME}-log --force; \
	docker run --rm --name ${PROJECT_NAME}-log -it -v ${PROJECT_NAME}_odoo-logs:/mnt/logs:ro bauagonzo/lnav sh -c "lnav /mnt/logs/odoo-server.log"

# DESC: Starts the log viewer for the PostgreSQL database using lnav.
logdb:
	docker rm ${PROJECT_NAME}-logdb --force; \
	docker run --rm --name ${PROJECT_NAME}-logdb -it -v ${PROJECT_NAME}_odoo-db-logs:/mnt/logs:ro bauagonzo/lnav sh -c "lnav /mnt/logs/postgres-log.log"

# DESC: Logs in to AWS and GitHub, and installs AWS CLI if necessary.
login:
	@if [ -z `command -v aws` ]; then \
		read -p "This proccess will install AWS CLI, curl and unzip on your system, do you want to proceed (y/n): " confirmation; \
    	if [ $$confirmation = "y" ]; then \
			echo "This proccess will install AWS CLI on your system"; \
			sudo apt-get install curl unzip -y; \
			which aws; \
			ls -l /usr/local/bin/aws; \
			sudo rm /usr/local/bin/aws; \
			sudo rm /usr/local/bin/aws_completer; \
			sudo rm -rf /usr/local/aws-cli; \
			sudo rm -rf ~/.aws/; \
			sudo rm -rf ~/aws-install/; \
			mkdir ~/aws-install; \
			sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o ~/awscliv2.zip; \
			unzip ~/awscliv2.zip -d ~/aws-install; \
			sudo sh ~/aws-install/aws/install; \
		else \
			exit 1; \
		fi; \
	fi
	@aws configure ;\
	echo "Now will ask for your GitHub user and your Personal Access Token (PAT) as 'Password'. \n You can generate a PAT by following the detailed steps in this url: \n https://docs.github.com/es/enterprise-server@3.5/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token"
	docker login ghcr.io

# DESC: Installs and activates pre-commit hooks in the project.
pre-commit-install:
	@if which pre-commit > /dev/null; then \
		echo "pre-commit is already installed."; \
		if [ -f .git/hooks/pre-commit ]; then \
			echo "pre-commit is already active in the project."; \
		else \
			echo "Activating pre-commit in the project..."; \
			pre-commit install || { echo "Failed to activate pre-commit in the project."; exit 1; }; \
			echo "pre-commit has been activated successfully in the project."; \
		fi \
	else \
		echo "Installing pre-commit..."; \
		sudo apt-get update || { echo "Failed to update package lists."; exit 1; }; \
		sudo apt-get install -y python3-pip || { echo "Failed to install python3-pip."; exit 1; }; \
		pip3 install --upgrade pip || { echo "Failed to upgrade pip."; exit 1; }; \
		sudo pip3 install --ignore-installed pre-commit || { echo "Failed to install pre-commit."; exit 1; }; \
		echo "pre-commit has been installed successfully."; \
		echo "Activating pre-commit in the project..."; \
		pre-commit install || { echo "Failed to activate pre-commit in the project."; exit 1; }; \
		echo "pre-commit has been activated successfully in the project."; \
	fi

# DESC: Shows PostgreSQL activity using pg_activity.
pg_activity:
	@docker exec -it ${PROJECT_NAME}-web pg_activity -h db -U odoo -d ${LOCAL_DATABASE_NAME}

# DESC: Displays real-time statistics of PostgreSQL using pg_top.
pg_top:
	@docker exec -it ${PROJECT_NAME}-web pg_top --host=db --username=odoo --dbname=${LOCAL_DATABASE_NAME}

# DESC: Installs the pg_stat_statements extension in the PostgreSQL database.
pg_stat_statements_install:
	@OUTPUT=$$(docker ps --no-trunc -aqf "name=${PROJECT_NAME}-db") && \
	docker exec -it $$OUTPUT sh -c "psql -U odoo ${LOCAL_DATABASE_NAME} -c 'CREATE EXTENSION pg_stat_statements;'" && \
	docker exec -it $$OUTPUT sh -c "psql -U odoo ${LOCAL_DATABASE_NAME} -c 'CREATE ROLE postgres WITH LOGIN SUPERUSER PASSWORD '\''postgres'\'';'" && \
	docker-compose -p=${PROJECT_NAME} restart pg_stat_statements

# DESC: Opens an interactive psql session in the Odoo container.
psql:
	@docker exec -it ${PROJECT_NAME}-web psql -h db -U odoo -d ${LOCAL_DATABASE_NAME}

# DESC: Restores the database from a backup in S3.
restore: build
	docker-compose -p=${PROJECT_NAME} down
	sh restore.sh

# DESC: Deletes all containers without deleting data volumes.
rm:
	@read -p "Do you want to remove all containers? (Data volumes will not be deleted) (y/n) " confirmation; \
    if [ $$confirmation = "y" ]; then \
        echo "Running the command..."; \
        docker-compose -p=${PROJECT_NAME} down; \
		docker rm ${PROJECT_NAME}-odoo-update --force; \
		docker rm ${PROJECT_NAME}-odoo-shell --force; \
    fi

# DESC: Starts the scaffold process to create a module template folder structure.
scaffold:
	@read -p "Please, enter the new module name to create with scaffold: " module; \
	if [ -d "./$$module" ]; then \
		echo "Module already exists" ; \
	else \
		docker rm ${PROJECT_NAME}-odoo-update --force; \
		docker rm ${PROJECT_NAME}-odoo-scaffold --force; \
		docker-compose -p=${PROJECT_NAME} down; \
		docker-compose -p=${PROJECT_NAME} run --name=${PROJECT_NAME}-odoo-scaffold --entrypoint "/usr/bin/odoo scaffold $$module /var/lib/odoo/"  odoo; \
		docker cp ${PROJECT_NAME}-odoo-scaffold:/var/lib/odoo/$$module ./custom-addons ;\
		docker-compose -p=${PROJECT_NAME} down; \
		docker rm ${PROJECT_NAME}-odoo-scaffold --force; \
		docker-compose -p=${PROJECT_NAME} up -d ; \
	fi

# DESC: Performs initial project setup, including building the Docker image and restoring the database.
setup: build
	@docker-compose -p=${PROJECT_NAME} down
	sh setup.sh

# DESC: Starts an interactive Odoo shell session.
shell: start
	@docker exec -it ${PROJECT_NAME}-web sh -c "python3 /usr/bin/odoo shell -c /etc/odoo/odoo.conf -d ${LOCAL_DATABASE_NAME} --no-http"

# DESC: Starts all containers for the project.
start:
	@docker rm ${PROJECT_NAME}-odoo-update --force; \
	docker-compose -p=${PROJECT_NAME} --env-file=.env up -d

# DESC: Displays real-time stats of the running containers.
stats:
	@docker-compose -p ${PROJECT_NAME} ps -q | xargs docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.PIDs}}"

# DESC: Stops all containers for the project.
stop:
	@docker-compose -p=${PROJECT_NAME} stop; \
	docker rm ${PROJECT_NAME}-odoo-update --force

# DESC: Runs tests on modules listed in src/config/test.conf.
test:
	@modules=$$(cat ./config/test.conf); \
    modules_show=$$(cat ./config/test.conf | tr ',' '\n '); \
	echo ""; \
	echo "────────────────────────────────────────────────"; \
	echo "\033[1m- Will run test on modules:\033[0m\n\n$$modules_show"; \
	echo "────────────────────────────────────────────────"; \
	echo ""; \
    docker rm ${PROJECT_NAME}-odoo-test --force; \
    docker-compose -p=${PROJECT_NAME} down; \
	echo "\nRunning tests..."; \
    output=$$( \
		docker-compose -p=${PROJECT_NAME} run --name=${PROJECT_NAME}-odoo-test -v ${PROJECT_NAME}_odoo-logs:/var/log/odoo --entrypoint \
        "/usr/bin/odoo --config /etc/odoo/odoo.conf --logfile=False -d ${LOCAL_DATABASE_NAME} --log-level debug \
		 --test-enable -i $$modules -u $$modules --stop-after-init" odoo 2>&1); \
	echo "$$output" > ./tmp/log.tmp; \
	docker run --rm -v ${PROJECT_NAME}_odoo-logs:/var/log/odoo -v ./tmp:/mnt/odoo ubuntu:22.04 bash -c "cat /mnt/odoo/log.tmp >> /var/log/odoo/odoo-server.log"; \
	echo "Tests finished!"; \
	echo "Analyzing tests..."; \
	python3 analyze_tests.py "$$output" | tee ./tmp/tests.log; \
    docker-compose -p=${PROJECT_NAME} down; \
    docker rm ${PROJECT_NAME}-odoo-test --force; \
    docker-compose -p=${PROJECT_NAME} up -d

# DESC: Deletes all containers and data volumes for the project.
uninstall:
	@read -p "Do you want to remove all containers and data volumes from ${PROJECT_NAME} project? (ALL PROJECT DATA WILL BE DELETED) (y/n) " confirmation; \
    if [ $$confirmation = "y" ]; then \
        echo "Deleting ALL data and containers from ${PROJECT_NAME} project ..."; \
        docker-compose -p=${PROJECT_NAME} down; \
		docker rm ${PROJECT_NAME}-odoo-update --force; \
		docker rm ${PROJECT_NAME}-odoo-initialice --force; \
		docker volume rm ${PROJECT_NAME}_odoo-db-logs ${PROJECT_NAME}_odoo-db-data ${PROJECT_NAME}_odoo-logs ${PROJECT_NAME}_odoo-data ; \
	fi

# DESC: Updates specific Odoo modules.
update-module:
	@read -p "Please, enter the modules to update separated by commas: " modules; \
	docker rm ${PROJECT_NAME}-odoo-update --force; \
	docker-compose -p=${PROJECT_NAME} down; \
	docker-compose -p=${PROJECT_NAME} run --name=${PROJECT_NAME}-odoo-update --entrypoint "/usr/bin/odoo -c /etc/odoo/odoo.conf -d ${LOCAL_DATABASE_NAME} -u $$modules --no-http --stop-after-init"  odoo; \
	docker-compose -p=${PROJECT_NAME} down; \
	docker rm ${PROJECT_NAME}-odoo-update --force; \
	docker-compose -p=${PROJECT_NAME} up -d

# DESC: Updates all Odoo modules.
update-all:
	@docker rm ${PROJECT_NAME}-odoo-update --force; \
	docker-compose -p=${PROJECT_NAME} down; \
	docker-compose -p=${PROJECT_NAME} run --name=${PROJECT_NAME}-odoo-update --entrypoint "/usr/bin/odoo --config /etc/odoo/odoo.conf -d ${LOCAL_DATABASE_NAME} -u all --no-http --stop-after-init" odoo; \
	docker rm ${PROJECT_NAME}-odoo-update --force; \
	docker-compose -p=${PROJECT_NAME} up -d
