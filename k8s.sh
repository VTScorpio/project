#!/bin/bash

# [ -z "$SUDO_USER" ] && { echo "Scriptul nu a fost accesat cu sudo. Ex: sudo $0"; exit 1; } #Se verifica drepturile sudo

[ $# -ne 1 ] &&  { echo "Utilizare: $0 start sau stop"; exit 1; } # Se verifica introducerea argumentului

# Verifica daca minikube este instalat
if ! command -v kubectl version >/dev/null 2>&1; then
    echo "Eroare: kubectl nu este instalat."
    exit 1
fi

# Verifica daca fisierele yaml exista
for file in k8s/monitor-deployment.yaml k8s/backup-deployment.yaml k8s/monitor-service.yaml k8s/backup-service.yaml; do
    if [ ! -f "$file" ]; then
        echo "Eroare: Fisierul $file nu exista."
        exit 1
    fi
done

# Verifica argumentul
if [ "$1" = "start" ]; then
    kubectl apply -f k8s/  # Pornire  minikube 
    if [ $? -eq 0 ]; then # Executia cu succes sau nu comanda
        echo "kubectl  a pornit  si este functional" 
        kubectl get all
        kubectl describe svc backup-service
        kubectl describe svc monitor-service
        sleep 11
        kubectl logs deployment/backup        
    else
        echo "Eroare la pornire"
        exit 1
    fi
elif [ "$1" = "stop" ]; then  # Executia cu succes sau nu comanda
    kubectl delete -f k8s/
    if [ $? -eq 0 ]; then
        echo "Proiect oprit"
        kubectl get all
    else
        echo "Eroare la oprirea containere docker"
        exit 1
    fi
else
    echo "Utilizare: $0 start sau stop" 
    exit 1
fi



