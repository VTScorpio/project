#!/bin/bash

[ -z "$SUDO_USER" ] && { echo "Scriptul nu a fost accesat cu sudo. Ex: sudo $0"; exit 1; } #Se verifica drepturile sudo

[ $# -ne 1 ] &&  { echo "Utilizare: $0 start sau stop"; exit 1; } # Se verifica introducerea argumentului


# Verifica argumentul
if [ "$1" = "start" ]; then
    docker compose up -d
    if [ $? -eq 0 ]; then # Executia cu succes sau nu comanda
        echo "Docker monitor si backup functional" # Start containere
        docker ps -a
    else
        echo "Eroare la pornirea Docker Compose"
        exit 1
    fi
elif [ "$1" = "stop" ]; then  # Executia cu succes sau nu comanda
    docker compose down # Stop containere
    if [ $? -eq 0 ]; then
        echo "Docker monitor si backup oprit"
        docker ps -a
    else
        echo "Eroare la oprirea Docker Compose"
        exit 1
    fi
else
    echo "Utilizare: $0 start sau stop" 
    exit 1
fi



