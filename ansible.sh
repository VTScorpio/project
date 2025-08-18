#!/bin/bash

# [ -z "$SUDO_USER" ] && { echo "Scriptul nu a fost accesat cu sudo. Ex: sudo $0"; exit 1; } #Se verifica drepturile sudo

[ $# -ne 1 ] &&  { echo "Utilizare: $0 start sau stop"; exit 1; } # Se verifica introducerea argumentului

# Verifica daca Ansible este instalat
if ! command -v ansible-playbook >/dev/null 2>&1; then
    echo "Eroare: Ansible nu este instalat."
    exit 1
fi


# Verifica daca fisierele Ansible exista
for file in ansible/inventory.ini ansible/install-docker.yml ansible/start-platform.yml ansible/stop-platform.yml; do
    if [ ! -f "$file" ]; then
        echo "Eroare: Fisierul $file nu exista."
        exit 1
    fi
done

# Verifica argumentul
if [ "$1" = "start" ]; then
    ansible-playbook -i ansible/inventory.ini ansible/install-docker.yml # Install docker remote
    if [ $? -eq 0 ]; then # Executia cu succes sau nu comanda
        echo "Ansible a instalat docker pe remote si este functional" 
        
    else
        echo "Eroare la instalarea Docker"
        exit 1
    fi
    ansible-playbook -i ansible/inventory.ini ansible/start-platform.yml
    if [ $? -eq 0 ]; then # Executia cu succes sau nu comanda
        echo "Ansible a copiat si pornit proiectul" 
        
    else
        echo "Eroare la pornire proiect"
        exit 1
    fi
elif [ "$1" = "stop" ]; then  # Executia cu succes sau nu comanda
    ansible-playbook -i ansible/inventory.ini ansible/stop-platform.yml # Install docker remote
    if [ $? -eq 0 ]; then
        echo "Proiect oprit"
    else
        echo "Eroare la oprirea containere docker"
        exit 1
    fi
elif [ "$1" = "install" ]; then 
    ansible-playbook -i ansible/inventory.ini ansible/install-docker.yml
    if [ $? -eq 0 ]; then # Executia cu succes sau nu comanda
        echo "Ansible a instalat docker pe remote si este functional" 
        
    else
        echo "Eroare la instalarea Docker"
        exit 1
    fi
else
    echo "Utilizare: $0 start sau stop" 
    exit 1
fi



