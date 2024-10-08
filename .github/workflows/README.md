# Repository README

## Workflows Overview

In the `.github/workflows` folder, you can find various workflows used across different repositories. They are centralized here to maintain version control and facilitate their reuse in new projects.

Workflows in this repository are categorized into two main types based on the project infrastructure:

### Docker Workflows

These workflows are designed to operate within a Docker or Docker Swarm environment. They are used for tasks like building images, pushing them to Docker AWS ECR, or GitHub Packages.

### Onpremise Workflows

These workflows are tailored for on-premise server instances.

Additionally, there are utility workflows designed to perform actions on the server, primarily used by developers (DEVs) and project managers (PMs).

### Utility Workflows

Utility workflows do not change their content based on infrastructure. Instead, the scripts executed by these actions vary depending on the infrastructure. These workflows are used for tasks like manual deployment, configuration changes, and more.

## Repository-Specific Workflows

The repository also includes workflows responsible for testing pull requests, creating pre-commit caches, and analyzing code with SonarQube.

### Repository Workflows

- `cache-precommit-creator.yml`: This action creates pre-commit caches for repositories that require them. It runs whenever a modification is made to the `.pre-commit-config.yaml` file or its parent directory. The created cache is stored in the repository and is used by pre-commit workflows.

- `sonarqube-pre-commit-pr.yml`: This action analyzes code within pull requests using pre-commit hooks and SonarQube.

- `sonarqube-push.yml`: This action analyzes code using SonarQube whenever a pull request is merged.

## Deployment Workflows

- `deploy-to-dev-from-feature.yml`: This action manually deploys changes from a feature branch to the DEV environment. The user selects the branch to be deployed.

- `deploy-to-uat-from-master.yml`: This action automatically deploys changes from the `master` branch to the UAT environment each time a merge to `master` occurs.

## Utility Workflows

These workflows offer various utility actions for managing an Odoo service on the server.

- `service-state.yml`: This action allows users to change the state of the Odoo service on the server manually. Users can select options like start, stop, or restart.

- `update-modules.yml`: This action enables the updating of Odoo modules on the server. Users can manually trigger this action and select the modules to update along with the database to use.

- `log-odoo-config.yml`: This action permits the modification of the Odoo log level on the server. It can be manually executed, and users can choose the log level they want to use.

- `timeout-change-odoo.yml`: This action allows users to modify the timeout settings for Odoo on the server. It's a manual action where users can select the desired timeout.

**For utility workflows, it's recommended to create one for each environment you need to control, such as DEV and UAT.**
