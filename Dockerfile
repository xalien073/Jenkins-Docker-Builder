# Base image with Docker-in-Docker
FROM docker:24.0.1-dind AS base

# Install required dependencies
RUN apk update && apk add --no-cache \
    openjdk11 \
    curl \
    unzip \
    python3 \
    py3-pip \
    git \
    jq \
    wget \
    && rm -rf /var/cache/apk/*

# Install SonarScanner
RUN curl -fsSL -o /tmp/sonar-scanner.zip "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip" \
    && unzip /tmp/sonar-scanner.zip -d /opt \
    && ln -s /opt/sonar-scanner-4.7.0.2747-linux/bin/sonar-scanner /usr/bin/sonar-scanner \
    && sed -i 's/use_embedded_jre=true/use_embedded_jre=false/' /opt/sonar-scanner-4.7.0.2747-linux/bin/sonar-scanner \
    && rm -rf /tmp/sonar-scanner.zip

# Install Trivy
RUN wget -O /tmp/trivy.tar.gz "https://github.com/aquasecurity/trivy/releases/download/v0.60.0/trivy_0.60.0_Linux-64bit.tar.gz" \
    && tar -xvzf /tmp/trivy.tar.gz -C /opt \
    && ln -s /opt/trivy /usr/bin/trivy \
    && rm -rf /tmp/trivy.tar.gz

# Verify installations
RUN docker --version && python3 --version && sonar-scanner --version && trivy --version

# Set working directory
WORKDIR /app

# Default command
CMD ["dockerd-entrypoint.sh"]
