#!/bin/bash

WORK_DIR="./terraform"

BUCKET_NAME="project-terraform-state-local"

[ $# -ne 1 ] &&  { echo "Utilizare: $0 start sau stop"; exit 1; } # Se verifica introducerea argumentului

[ ! -d "$WORK_DIR" ] && {  echo "[$TIMESTAMP] Eroare: Directorul $WORK_DIR nu exista."; exit 1; }

# 1. Verifica LocalStack

if [ "$1" = "start" ]; then
    if ! docker ps -q --filter "name=localstack" | grep -q .; then
        echo " LocalStack nu ruleaza. Pornire container..."
        sudo localstack start -d
        sleep 5  # Asteapta ca LocalStack sa porneasca
    else
        echo " LocalStack ruleaza deja."
    fi

    if ! command -v aws &> /dev/null; then
        echo "Eroare: AWS CLI nu este instalat. Instaleaza awscli'."
        exit 1
    else
        echo "AWS CLI este instalat."
    fi

    if ! aws --endpoint-url=http://localhost:4566 s3 ls s3://$BUCKET_NAME 2>&1 | grep -q "NoSuchBucket"; then
        echo "Bucket $BUCKET_NAME exista."
    else
        echo " Bucket $BUCKET_NAME nu exista. Se creeaza..."
        aws --endpoint-url=http://localhost:4566 s3 mb s3://$BUCKET_NAME
        if [ $? -eq 0 ]; then
            echo "Bucket $BUCKET_NAME creat cu succes."
        else
            echo "Eroare: Nu s-a putut crea bucket-ul. Verifica LocalStack."
            exit 1
        fi
    fi

    # Verifica Terraform
    echo " Verificare Terraform..."
    if ! command -v terraform &> /dev/null; then
        echo " Eroare: Terraform nu este instalat. Instaleaza-l (ex. cu 'apt install terraform')."
        exit 1
    else 
        echo "Terraform este instalat."    
    fi
    
    # Ruleaza Terraform
    cd "$WORK_DIR" || exit 1
    echo " Navigare în $WORK_DIR..."

    echo " Executare terraform init..."
    terraform init

    if [ $? -ne 0 ]; then
        echo "Eroare: terraform init a esuat. Verifica log-urile."
        exit 1
    fi

    echo " Executare terraform apply..."
    terraform apply -auto-approve

    if [ $? -ne 0 ]; then
        echo "Eroare: terraform apply a esuat. Verifica configurarea."
        exit 1
    fi
  
elif [ "$1" = "stop" ]; then
    cd "$WORK_DIR" || exit 1
    echo " Navigare în $WORK_DIR..."
    terraform destroy -auto-approve
    if [ $? -eq 0 ]; then
        echo "Terraform oprit"
    else
        echo "Eroare la oprirea Terraform"
        exit 1
    fi
else
    echo "Utilizare: $0 start sau stop" 
    exit 1
fi