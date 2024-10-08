#!/bin/bash
set -ex

. ./.env

mkdir -p tmp/

OBJECT="$(aws s3 ls s3://$AWS_BUCKET/$PROJECT_NAME --recursive | sort | tail -n 1 | awk '{print $4}')"
if [ ! -f "./tmp/db.zip" ]; then
    aws s3 cp s3://$AWS_BUCKET/$OBJECT tmp/db.zip
fi

docker-compose -p=${PROJECT_NAME} up -d

WEBID=$(docker ps --no-trunc -aqf "name=${PROJECT_NAME}-web")
DBID=$(docker ps --no-trunc -aqf "name=${PROJECT_NAME}-db")

#Install unzip, uuid-runtime, python3 and postgresql-plpython3-13 to fix python3u language error
docker exec -it $DBID sh -c "apt update && apt install -y unzip zip uuid-runtime python3 postgresql-plpython3-13"

#Fixes for python3u language error
docker exec -it $WEBID sh -c "createdb -h db -U odoo ${LOCAL_DATABASE_NAME}"
docker exec -it $DBID sh -c "psql -U odoo ${LOCAL_DATABASE_NAME} -c 'CREATE EXTENSION pg_stat_statements;'"
docker exec -it $DBID sh -c "psql -U odoo ${LOCAL_DATABASE_NAME} -c 'CREATE ROLE postgres WITH LOGIN SUPERUSER PASSWORD '\''postgres'\'';'"
docker exec -it $DBID sh -c "psql -U postgres ${LOCAL_DATABASE_NAME} -c 'CREATE LANGUAGE plpython3u;'"

docker exec -it $WEBID sh -c "mkdir -p /mnt/db && unzip /mnt/tmp/db.zip -d /mnt/db"
docker exec -it $WEBID sh -c "mkdir -p /var/lib/odoo/.local/share/Odoo/filestore/${LOCAL_DATABASE_NAME}/"
docker exec -it $WEBID sh -c "rsync -raz /mnt/db/filestore/ /var/lib/odoo/.local/share/Odoo/filestore/${LOCAL_DATABASE_NAME}/"

docker exec -it $WEBID sh -c "psql -h db -U odoo -q ${LOCAL_DATABASE_NAME} < /mnt/db/dump.sql"

docker exec -it $WEBID sh -c "psql -h db -U odoo ${LOCAL_DATABASE_NAME} -c \"update fetchmail_server set active = False;\""
docker exec -it $WEBID sh -c "psql -h db -U odoo ${LOCAL_DATABASE_NAME} -c \"update ir_mail_server set active = False;\""
docker exec -it $WEBID sh -c "psql -h db -U odoo ${LOCAL_DATABASE_NAME} -c \"DELETE FROM ir_mail_server;\""
docker exec -it $WEBID sh -c "psql -h db -U odoo ${LOCAL_DATABASE_NAME} -c \"DELETE FROM fetchmail_server;\""

## UPDATE Ribbon
docker-compose -p=${PROJECT_NAME} down; \
docker-compose -p=${PROJECT_NAME} run --name=${PROJECT_NAME}-odoo-update --entrypoint "/usr/bin/odoo --config /etc/odoo/odoo.conf -d ${LOCAL_DATABASE_NAME} -i web_environment_ribbon --no-http --stop-after-init" odoo
docker rm ${PROJECT_NAME}-odoo-update --force
docker-compose -p=${PROJECT_NAME} run --name=${PROJECT_NAME}-odoo-update --entrypoint "/usr/bin/odoo --config /etc/odoo/odoo.conf -d ${LOCAL_DATABASE_NAME} -u web_environment_ribbon --no-http --stop-after-init" odoo
docker rm ${PROJECT_NAME}-odoo-update --force
docker-compose -p=${PROJECT_NAME} up -d
WEBID=$(docker ps --no-trunc -aqf "name=${PROJECT_NAME}-web")
docker exec -it $WEBID sh -c "psql -h db -U odoo ${LOCAL_DATABASE_NAME} -c \"UPDATE ir_config_parameter SET value = '${PROJECT_NAME} <br> LOCAL' where key = 'ribbon.name'\""

#Set password 'Nybble9060!' to all users
docker exec -it $WEBID sh -c "psql -h db -U odoo ${LOCAL_DATABASE_NAME} -c \"UPDATE res_users SET password='Nybble9060!';\""

docker exec -it $WEBID sh -c "rm -rf /mnt/db"
