#!/usr/bin/env bash 

usage() {
  cat <<-EOF
  Usage: application_deploy.sh [options] -n APPLICATION_NAME -e ENV [command]
  Options:
    -h, --help           output help information
  Commands:
    [command]            terraform command and options
EOF

}

abort() {
    echo
    echo "  $@" 1>&2
    echo
    exit 1
}

log () {
    echo 
    echo "  • $@"
}

required_vars() {

    [ -z $NAME ] && abort "-n NAME was not provided, aborting deploy..."

    [ -z "$ENV" ] && abort "-e ENV was not provided, aborting deploy..."

    # Define AWS credentials
    for i in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION ssh_key_pair_name; do 
        read -p "$i: " input
        eval $(echo "$i=$input") 
    done

    start=$(date +%s)
    ([ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_REGION" ]) && abort "AWS_ACCOUNT_ID, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY was not provided, aborting deploy..."

}

#terraform_init() {

#}

awscli_init() {
    # pip awscli install
    [ -d "${CWD}/bin" ] || { \
        mkdir -p ${CWD}/bin; \
        ln -sf /usr/bin/python2.7 ${CWD}/bin/python; \
        wget https://bootstrap.pypa.io/get-pip.py && ${CWD}/bin/python get-pip.py --user; \
        pip install -U awscli --user; \
        export PATH=${CWD}/bin:$PATH; \
    }
}

terraform_application_create() {
    local NAME=$1
    local CMD=$2

    $TERRAFORM workspace select $NAME || $TERRAFORM workspace new $NAME
    cd ${CWD}/global || abort "Terraform configuration $ENV does not exists"

    log "Elacticbeanstalk application create"
    set -x
    $TERRAFORM get
    $TERRAFORM init
    #$TERRAFORM plan --var-file=terraform.tfvars --var application_name=$NAME -var aws_access_key=$AWS_ACCESS_KEY_ID -var aws_secret_key=$AWS_SECRET_ACCESS_KEY -var aws_region=$AWS_REGION && \
    $TERRAFORM $CMD $args -var aws_access_key=$AWS_ACCESS_KEY_ID -var aws_secret_key=$AWS_SECRET_ACCESS_KEY -var aws_region=$AWS_REGION -var application_name=$NAME
    set +x
}

terraform_deploy() {
    log " ---------------------------- Terraform deployment ----------------------------"
    echo $@
    local NAME=$1
    local ENV=$2
    local CMD=$3
    
    $TERRAFORM workspace select $NAME || $TERRAFORM workspace new $NAME

    cd ${CWD}/$ENV || abort "Terraform configuration $ENV does not exists"

    $TERRAFORM get
    $TERRAFORM init 
    #&& read -n 1 -s -r -p "Press any key to build infrastructure with terraform" && \
    set -x
    #$TERRAFORM plan -var ssh_key_pair_name=$ssh_key_pair_name -var aws_access_key=$AWS_ACCESS_KEY_ID -var aws_secret_key=$AWS_SECRET_ACCESS_KEY -var service_name=$NAME --var application_name=$NAME --state=$ENV/terraform.tfstate --var env=$ENV ${CWD}/$ENV && \
    #-auto-approve
    $TERRAFORM $CMD $args -var service_name=$NAME -var application_name=$NAME -var env=$ENV \
        -var aws_access_key=$AWS_ACCESS_KEY_ID -var aws_secret_key=$AWS_SECRET_ACCESS_KEY -var aws_region=$AWS_REGION -var ssh_key_pair_name=$ssh_key_pair_name
    #    -state=$ENV/terraform.tfstate $ENV/
    set +x
    [ $? != 0 ] && abort "Terraform deployment was not successful."

}

eb_deploy_app(){

    local ENV=$1
    # Elasticbeanstalk parameters
    local EB_BUCKET=$NAME-$ENV-deployments
    local VERSION=$NAME-$ENV-$(date +%s)
    local ZIPFILE=Dockerrun.aws.json.zip

    sleep 10 && set -x
    # Create new application revision and deploy to environment
    aws s3 cp $ZIPFILE s3://$EB_BUCKET/$ZIPFILE
    eb_create_rev=$(aws elasticbeanstalk create-application-version --application-name $NAME --version-label $VERSION --source-bundle S3Bucket=$EB_BUCKET,S3Key=$ZIPFILE)
    eb_deploy_rev=$(aws elasticbeanstalk update-environment --environment-name $NAME-$ENV --version-label $VERSION)
    set +x

    [ -z "$eb_deploy_rev" ] &&  abort "Elasticbeanstalk application deployment failed." \
                            || log "Elasticbeanstalk application deployment successful. Please wait to deployment to finish..." 

    
}

start=$(date +%s)

CWD="${PWD}"
TERRAFORM=$(command -v terraform)
AWS=$(command -v aws)
[ -z "$TERRAFORM" ] && abort "Terraform is not installed"
[ -z "$AWS" ] && abort "AWSCLI is not installed"

log "$TERRAFORM"
log "$AWS"

[ -z "$1" ] && usage && exit

set +x
while true; do
    case $1 in
        -h|--help) usage; exit ;;
        -n|--name) ([[ $2 == -* ]] || [ -z "$2" ]) && abort "$1 <- declared but not defined..." || NAME=$2; shift 2;;
        -e|--env)  ([[ $2 == -* ]] || [ -z "$2" ]) && abort "$1 <- declared but not defined..." || ENV="$ENV $2"; shift 2;;
        -*) args="$args $1"; shift;;
        destroy) 
            required_vars $@
            for env in $ENV; do terraform_deploy $NAME $env destroy $args; done
            terraform_application_create $NAME destroy $args
            break
        ;;
        "") echo ---

            required_vars $@
            terraform_application_create $NAME $COMMANDS

            log "$TERRAFORM $NAME $ENV $CMD $args"
            for env in $ENV; do
                for cmd in $COMMANDS; do 
                
                    log "Terraform execute."
                    terraform_deploy $NAME $env $cmd $args                    
                    [[ "$cmd" == "apply" ]] && log "Deploying sample PHP application." \
                                            && eb_deploy_app $ENV
                done                
            done
            break
        ;;
        *) COMMANDS="$COMMANDS $1"; shift;
        ;;
    esac
done


end=$(date +%s)

log "Deployment time : $((end-start)) seconds"

for env in $ENV; do log "env url: $NAME-$env.$AWS_REGION.elasticbeanstalk.com"; done

set +x