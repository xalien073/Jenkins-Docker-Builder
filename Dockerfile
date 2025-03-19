# Use latest secure Alpine image
FROM alpine:3.19

# Set environment variables
ENV SONAR_SCANNER_VERSION=4.8.0.2856
ENV TRIVY_VERSION=0.50.0
ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
ENV PATH="/opt/sonar-scanner-${SONAR_SCANNER_VERSION}-linux/bin:$PATH"

# Install dependencies and update BusyBox securely
RUN apk add --no-cache \
    bash \
    busybox \
    containerd \
    curl \
    docker-cli \
    git \
    krb5-libs \
    openjdk17-jre \
    runc \
    unzip \
    && apk upgrade --no-cache

# Download and install Sonar Scanner
RUN curl -fsSL "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip" -o /tmp/sonar-scanner.zip \
    && unzip /tmp/sonar-scanner.zip -d /opt/ \
    && rm /tmp/sonar-scanner.zip \
    && echo "sonar.java.binaries=." >> /opt/sonar-scanner-${SONAR_SCANNER_VERSION}-linux/conf/sonar-scanner.properties \
    && echo "sonar.search.javaHome=${JAVA_HOME}" >> /opt/sonar-scanner-${SONAR_SCANNER_VERSION}-linux/conf/sonar-scanner.properties

# Install Trivy
RUN curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" | tar xz -C /usr/local/bin

# Verify installations
RUN java -version && sonar-scanner --version && trivy --version

# Set working directory
WORKDIR /app

# Default command
CMD ["sh"]
