# Custom Addons

## Usage

All custom addons for this project should be located here. Please prefix by system part
like "accounting", "sales", "crm" and so on to be easy to manage and move globally in
the future.

## Docker Usage

This folder is already added to the container in the odoo.conf and in the
docker-compose.yml mounted at /mnt/custom-addons.

You may add subfolders if you want to changing on both places and restarting the
container.
