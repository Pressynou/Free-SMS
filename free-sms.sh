#!/bin/bash

CONFIG_FILE="/etc/free-sms/config.json"

# Fonction pour lire les identifiants dans le fichier de configuration
read_config() {
    USER=$(jq -r '.user' "$CONFIG_FILE")
    PASS=$(jq -r '.pass' "$CONFIG_FILE")
}

# Vérifier si le fichier de configuration existe
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Le fichier de configuration n'existe pas. Veuillez le créer à $CONFIG_FILE."
    exit 1
fi

# Lire les identifiants dans le fichier de configuration
read_config

# Vérifier si les identifiants sont présents
if [ -z "$USER" ] || [ -z "$PASS" ]; then
    echo "Identifiants manquants dans le fichier de configuration."
    exit 1
fi

# Vérifier si des arguments sont fournis en ligne de commande
if [ "$#" -gt 0 ]; then
    # Si des arguments sont présents, utiliser le premier argument comme message
    message="$1"
else
    # Sinon, lire l'entrée depuis stdin et stocker les lignes dans une variable
    message=""
    while IFS= read -r line; do
        message+="$line\n" # Utilisation de \n pour les sauts de ligne
    done

    # Supprimer le dernier saut de ligne
    message=$(echo -e "${message%\n}")

    # Vérifier si le message est vide
    if [ -z "$message" ]; then
        echo "Veuillez fournir un message à envoyer."
        exit 1
    fi
fi

# Fonction pour URL-encoder le message
urlencode() {
    # Utilisation de Python pour l'encodage URL
    python -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]))" "$1"
}

# Encoder le message pour l'URL
encoded_message=$(urlencode "$message")

# Envoyer le SMS en utilisant l'API Free Mobile
curl -s "https://smsapi.free-mobile.fr/sendmsg?user=$USER&pass=$PASS&msg=$encoded_message"

echo "SMS envoyé avec succès."
exit 0
