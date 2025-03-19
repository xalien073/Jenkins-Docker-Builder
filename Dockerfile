# Use the latest Alpine image with security patches
FROM alpine:3.19

# Set environment variables
ENV SONAR_SCANNER_VERSION=4.8.0.2856
ENV TRIVY_VERSION=0.50.0
ENV DOCKER_VERSION=24.0.7

# Install necessary packages and update vulnerable components
RUN apk add --no-cache \
    busybox \
    krb5-libs \
    docker-cli=${DOCKER_VERSION}-r0 \
    containerd \
    runc \
    curl \
    openjdk17-jre \
    bash \
    git \
    unzip

# Upgrade BusyBox to a secure version
RUN apk upgrade --no-cache busybox

# Download and install Sonar Scanner
RUN curl -fsSL "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip" -o /tmp/sonar-scanner.zip \
    && unzip /tmp/sonar-scanner.zip -d /opt/ \
    && rm /tmp/sonar-scanner.zip

# Set up Sonar Scanner
ENV PATH="/opt/sonar-scanner-${SONAR_SCANNER_VERSION}-linux/bin:$PATH"

# Install Trivy (latest version)
RUN curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" | tar xz -C /usr/local/bin

# Verify installations
RUN docker --version && sonar-scanner --version && trivy --version

# Set working directory
WORKDIR /app

# Default command
CMD ["sh"]
