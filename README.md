# Terraform Challenge
This is a terraform_deploy script to create sample Elasticbeanstalk application.
## Prerequisites
Install terraform and awscli
## Usage
Clone repository and make application_deploy.sh executable
```
 > chmod +x application_deploy.sh
 > application_deploy.sh -h
  Usage: application_deploy.sh [options] -n APPLICATION_NAME -e ENV [command]
  Options:
    -h, --help           output help information
  Commands:
    [command]            terraform command and options
```

## Plan application stack
```
application_deploy.sh -n application-php -e development -e staging plan
```

## Create application stack for development
```
application_deploy.sh -n application-php -e development -e staging apply
```

## Create application stack for all environments (development,staging,production) with auto-approve
```
application_deploy.sh -n application-php -e development -e staging -e production apply -auto-approve
```

## Show application stack
```
application_deploy.sh -n application-php -e development -e staging plan
```
## Destroy application stack
```
application_deploy.sh -n application-php -e development  destroy
```