# External Addons

## Usage

Only when we ne need to add external addons (from another provider) which are not
currently in our main docker repo centralized.

If it's an OCA or ingadhoc repo please first ask to be added to the main Odoo Docker
repository.

If you consider this repository to be useful for all projects don't add it here without
speaking with the Odoo architecture team.

## Docker Usage

This folder is already added to the container in the odoo.conf and in the
docker-compose.yml mounted at /mnt/external_addons.

You may add subfolders if you want to changing on both places and restarting the
container.
