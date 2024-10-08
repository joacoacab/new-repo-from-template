#!/bin/bash
set -ex

. ./.env

docker-compose -p=${PROJECT_NAME} up -d
#sleep 5

WEBID=$(docker ps --no-trunc -aqf "name=${PROJECT_NAME}-web")

#docker exec -it $WEBID sh -c "createdb -h db -U odoo ${LOCAL_DATABASE_NAME}"
docker stop ${PROJECT_NAME}-web
docker-compose -p=${PROJECT_NAME} run --name=${PROJECT_NAME}-odoo-initialice --entrypoint "python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d ${LOCAL_DATABASE_NAME} --stop-after-init" odoo
docker rm ${PROJECT_NAME}-odoo-initialice --force; \
docker-compose -p=${PROJECT_NAME} down
docker-compose -p=${PROJECT_NAME} up -d

## UPDATE Ribbon
docker-compose -p=${PROJECT_NAME} down; \
docker-compose -p=${PROJECT_NAME} run --name=${PROJECT_NAME}-odoo-update --entrypoint "/usr/bin/odoo --config /etc/odoo/odoo.conf -d ${LOCAL_DATABASE_NAME} -i web_environment_ribbon --no-http --stop-after-init" odoo
docker rm ${PROJECT_NAME}-odoo-update --force
docker-compose -p=${PROJECT_NAME} run --name=${PROJECT_NAME}-odoo-update --entrypoint "/usr/bin/odoo --config /etc/odoo/odoo.conf -d ${LOCAL_DATABASE_NAME} -u web_environment_ribbon --no-http --stop-after-init" odoo
docker rm ${PROJECT_NAME}-odoo-update --force
docker-compose -p=${PROJECT_NAME} up -d
WEBID=$(docker ps --no-trunc -aqf "name=${PROJECT_NAME}-web")
docker exec -it $WEBID sh -c "psql -h db -U odoo ${LOCAL_DATABASE_NAME} -c \"UPDATE ir_config_parameter SET value = '${PROJECT_NAME} <br> LOCAL' where key = 'ribbon.name'\""
