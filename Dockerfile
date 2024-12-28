# Base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    libssl-dev \
    openssl \
    libcppunit-dev \
    libexpat1-dev \
    libpcre2-dev \
    libldap2-dev \
    libpam0g-dev \
    libkrb5-dev \
    libdb-dev \
    cdbs \
    bison \
    flex \
    g++ \
    curl \
    apache2-utils \
    && apt-get clean

# Set Squid version
ENV SQUID_VERSION=5.9

# Download and extract Squid source
RUN wget http://www.squid-cache.org/Versions/v5/squid-${SQUID_VERSION}.tar.gz && \
    tar -xvzf squid-${SQUID_VERSION}.tar.gz && \
    rm squid-${SQUID_VERSION}.tar.gz

# Build and install Squid
WORKDIR squid-${SQUID_VERSION}
RUN ./configure --prefix=/usr/local/squid \
                --enable-ssl \
                --with-openssl \
                --enable-ssl-crtd \
                --enable-auth \
                --enable-cache-digests \
                --enable-follow-x-forwarded-for \
                --with-default-user=squid && \
    make -j$(nproc) && \
    make install

# Create required directories and set permissions
RUN mkdir -p /usr/local/squid/var/logs /usr/local/squid/var/cache && \
    chown -R nobody:nogroup /usr/local/squid/var && \
    chmod -R 777 /usr/local/squid/var/logs && \
    chown -R 777 /usr/local/squid/var/cache && \
    /usr/local/squid/libexec/security_file_certgen -c -s /usr/local/squid/var/cache/ssl_db -M 4MB

# Add Squid to PATH
ENV PATH="/usr/local/squid/sbin:$PATH"

RUN groupadd -r squid && useradd -r -g squid squid
RUN mkdir -p /var/spool/squid /var/log/squid && \
    chown -R squid:squid /var/spool/squid /var/log/squid
RUN squid -z -N

# Create security credentials directory
RUN mkdir -p /usr/local/squid/etc/security_credentials && \
    chown squid:squid /usr/local/squid/etc/security_credentials

COPY squid.conf /usr/local/squid/etc/squid.conf

# Copy and set up entrypoint script
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Expose Squid default ports
EXPOSE 443

# Use the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]