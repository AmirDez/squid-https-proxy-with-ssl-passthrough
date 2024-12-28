#!/bin/bash

SECURITY_DIR="/usr/local/squid/etc/security_credentials"
CERT_FILE="${SECURITY_DIR}/full-chain.pem"
PASSWORD_FILE="${SECURITY_DIR}/passwords"


# Create security directory if it doesn't exist
mkdir -p ${SECURITY_DIR}

# Generate certificate if it doesn't exist
if [ ! -f "${CERT_FILE}" ]; then
    echo "Generating new SSL certificate..."
    openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=gateway" \
        -keyout ${CERT_FILE} \
        -out ${CERT_FILE}
    
    # Set proper permissions
    chmod 600 ${CERT_FILE}
    chown squid:squid ${CERT_FILE}
fi


# Generate password file if it doesn't exist
if [ ! -f "${PASSWORD_FILE}" ]; then
    echo "Creating password file and generating credentials for gateway-user..."

    # Generate a random password for the default user
    GATEWAY_USER="gateway-user"
    GATEWAY_PASS=$(openssl rand -base64 12)

    # Add the default user and password to the password file
    htpasswd -bc ${PASSWORD_FILE} ${GATEWAY_USER} ${GATEWAY_PASS}

    # Output the generated credentials
    echo "Default credentials for Squid:"
    echo "Username: ${GATEWAY_USER}"
    echo "Password: ${GATEWAY_PASS}"

    # Set permissions for the password file
    chmod 600 ${PASSWORD_FILE}
    chown squid:squid ${PASSWORD_FILE}
fi

# Start Squid
echo "Starting Squid with authentication enabled..."
exec /usr/local/squid/sbin/squid -N -d 1