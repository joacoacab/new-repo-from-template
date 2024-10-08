# Odoo ERP on Docker

# Run with docker

## Prerequisites

- We recommend a minimum of a compatible i5/i7 processor with 16GB of RAM to use docker
  locally with good performance and all other tools needed. You may find more
  information on docker usage here:

https://www.freecodecamp.org/news/docker-simplified-96639a35ff36/

- Install latest Docker Desktop environment:

https://www.docker.com/products/docker-desktop

- Please follow the python recommendatiomns setup for Visual Studio Code:

https://code.visualstudio.com/docs/languages/python

## .env file

In .env file you can set the project name and the Odoo version uncomenting the proper docker image. We use out git packages repository with our custom images, that contains many usefull tools for debug, manage, test, etc, the dev environment.

## Start Odoo On Docker Containers

1 -  You need to ask the AWS Admin for your credentials with AWS ECR permissions.

**You can use make login command to run a login wizard or do it manual:

2 -  Install AWS CLI in your SO

>https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

3 - Put your credentials in AWS CLI (if you only need one profile configured in AWS CLI) with the command:

>aws configure

It will ask you for the ID and KEY. The others parameters can stay at default

Now, you are abble to download dev-databases.

4 - Login Docker with GITHUB Packages, for docker images downloading:

You need to generate a Personal Acces Tokem (PAT) following the steps shown in link below:

>https://docs.github.com/es/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token

>docker login ghcr.io -U YOUR-GIT-USER

Will ask your PAT.

5 - Navegate in yout terminal (on Linux or WSL in windows) to src/

>cd src/

6 - To run DEV Container with dev database auto-restore, use:

>make setup

7 - You can turn on the debuging tool with:

>make debug

**If you have another Odoo instance running, you may have to change the ports configuration in docker-compose.yml file ej.: change 8069:8069 - 5432:5432 - 1025:1025 with 8089:8069 - 5433:5432 - 1026:1025

## Precommit Hooks

This project have all precommit hooks configured that will check the code on our addons
folder (to be renamed to app_addons).

All checks will be run server side at the CI infrastructure so save time and don't
ignore them or even exclude them.

## Module Documentation

Please document each module clearly and add links to the corresponding ticket and Use
Case documentation.

https://www.odoo.com/documentation/15.0/developer/reference/backend/module.html

In addition please follow and apply the Sphinx documentation for all modules:

https://www.sphinx-doc.org/en/master/

## Linting and Formatting

We are using black and flake8 already preconfigured to valid code quality and may be add
more.

## Security

We are using safety and bandit plus validating credentials and large files are not
allowed in the repo. Please also review and apply the Odoo.com recommendations as from
here:

https://www.odoo.com/documentation/15.0/developer/reference/backend/security.html

A more in depth video can be seen here: https://www.youtube.com/watch?v=wpgtL02kPP4

## Test Suites

We are not including unit tests on the precommit hook as we understand that it should be
run not so often to speed up development time and we encourage all code to be tested
properly.

Here is the link to all the minimum documentation to rea and learn to use the testing
framework of Odoo:

- https://www.odoo.com/documentation/15.0/developer/reference/backend/testing.html
- https://docs.python.org/3/library/unittest.html
- Odoo Cookbook (Testing Chapter):
  https://subscription.packtpub.com/book/programming/9781800200319/18/ch18lvl1sec97/technical-requirements
- Please watch the Odoo.com video on detaild usage of Odoo Unit Test framework:
  https://www.youtube.com/watch?v=JEIscps0OOQ
- Good practices to see here: https://www.youtube.com/watch?v=pQ7TZELSpKY

```
You can also access the full Odoo Development Cookbook 14.0 or 15.0 e-Book in our private Nybble Training material folder.
```

You can also access the book in our private training material folder.

All unit tests will be run in the docker container and a coverage report will be
included once executed with:

Frontend unit tests are based on https://qunitjs.com/. Frontend tests and tour tests are
not being run actually because of some configuration issue with the database under
review.

```
make test
```

All same test suites should be run on the DEV/TEST environment in the CI infrastructure
as well using this command and should pass.

You may need to install more modules or to start with a more complete DB from a backup
and that should be done in the:

```
make test-initialize
```

This command will be run in the ci and should have access to the backup file in S3.

### API & Integration Testing

As from the Odoo.com documentation this is the minimum documentation to test a complete
feature:

- https://www.odoo.com/documentation/15.0/developer/reference/backend/testing.html#integration-testing
- How to screen record a case: https://www.youtube.com/watch?v=5NEwqTzgDnA

Some additionales tools to analyze are:

- https://www.katalon.com/resources-center/blog/open-source-testing-tools/
- https://www.softwaretestinghelp.com/best-gui-testing-tools/
- https://openexpoeurope.com/en/6-open-source-frameworks-for-test-automation/

## Continous Integration

On every pull request we will demand to be synched with dev branch to pass:

- All code will be validated using the pre-commit configuration

```bash
pre-commit run -a
```

- We will demand up to 80% code coverage to be executed on the addons module for our
  generated code

# Local Execution (Old)

We recommend to review the Odoo Docker repository for a workaround to run an Odoo
instance locally.
