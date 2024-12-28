# Squid HTTPS Proxy with SSL Passthrough Enabled

This repository provides a Dockerized Squid HTTPS proxy server with SSL passthrough functionality. The proxy enables secure HTTP browsing with basic authentication enabled by default. It is designed to simplify setup while offering flexibility for advanced configurations.

---

## Features

- **HTTPS Proxy with SSL Passthrough**: Ensures end-to-end encryption without intercepting or modifying SSL/TLS traffic.
- **Basic Authentication**: Enabled by default. A username (`gateway-user`) and a randomly generated password are created automatically on the first run.
- **Auto-Generated SSL Certificate**: Generates a self-signed certificate on startup. For public use, replace it with a valid certificate to avoid browser warnings.
- **Customizable Certificate Support**: Easily replace the self-signed certificate with one from Let's Encrypt or another trusted CA.

---

## How It Works

1. **Proxy Authentication**:
   - The proxy requires authentication to ensure only authorized users can access it.
   - A default username (`gateway-user`) is created, and a password is generated on the first container run. The credentials are printed in the logs.

2. **SSL Certificate**:
   - A self-signed certificate is generated and used by default.
   - For public deployment, replace it with a valid full-chain certificate from a trusted CA (e.g., Let's Encrypt).

3. **Secure Browsing**:
   - HTTPS requests are passed securely to destination servers without decryption or inspection.
   - No SSL bumping occurs, preserving end-to-end encryption.

---

## Setup and Usage

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/)
- (Optional) A valid SSL certificate if deploying publicly.

### Build the Docker Image

```bash
git clone https://github.com/yourusername/squid-https-proxy.git
cd squid-https-proxy
docker build -t squid-https-proxy .
```

### Run the Proxy

```bash
docker run -d \
    --name squid-https-proxy \
    -p 443:443 \
    squid-https-proxy
```

### Access Logs to Get Credentials

On the first run, the generated username and password are printed in the container logs:

```bash
docker logs squid-https-proxy
```

Example log output:

```plaintext
Creating password file and generating credentials for gateway-user...
Default credentials for Squid:
Username: gateway-user
Password: xYz123Abc!
Starting Squid with authentication enabled...
```

---

## Replacing the SSL Certificate

1. Generate a full-chain certificate and private key (e.g., with [Let's Encrypt](https://letsencrypt.org/)).
2. Combine them into a single file:

   ```bash
   cat fullchain.pem privkey.pem > full-chain.pem
   ```

3. Place the file in the `security_credentials` directory:

   ```bash
   docker cp full-chain.pem squid-https-proxy:/usr/local/squid/etc/security_credentials/full-chain.pem
   ```

4. Restart the container:

   ```bash
   docker restart squid-https-proxy
   ```

---

## License

This project is open-source and available under the [MIT License](LICENSE).
