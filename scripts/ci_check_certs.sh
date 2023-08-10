#!/bin/bash

# Set the threshold for certificate expiration (in days)
THRESHOLD=365 # ToDo: Change this to 5


# Check if certificate is expiring within the threshold
expiry_str=$(ssh -o StrictHostKeyChecking=no -i key.pem azureuser@"$KAFKA_DOMAIN" "sudo openssl x509 -in /etc/letsencrypt/live/$KAFKA_DOMAIN/fullchain.pem -noout -enddate | cut -d= -f2")
expiration_date=$(date -d "$expiry_str" +%s)
current_date=$(date +%s)
days_until_expiry=$(( (expiration_date - current_date) / 86400 ))

if [ "$days_until_expiry" -lt "$THRESHOLD" ]; then
    echo "Certificate for $KAFKA_DOMAIN is expiring in $days_until_expiry days."
    exit -1
else
    echo "Certificate for $KAFKA_DOMAIN is not expiring within the next $THRESHOLD days. No action needed."
fi
