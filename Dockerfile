# Stage 1: Download Plugin
FROM curlimages/curl:latest AS plugins
ARG PLUGIN_VERSION=1.6.1-26.4.0

WORKDIR /tmp
RUN curl -L -O https://github.com/vzakharchenko/keycloak-radius-plugin/releases/download/v${PLUGIN_VERSION}/keycloak-radius-${PLUGIN_VERSION}.zip && \
    unzip keycloak-radius-${PLUGIN_VERSION}.zip

# Stage 2: Keycloak Build
FROM quay.io/keycloak/keycloak:26.4.7
ARG PLUGIN_VERSION=1.6.1-26.4.0

# Copia Plugin
COPY --from=plugins --chown=keycloak:keycloak keycloak-radius-${PLUGIN_VERSION}/providers/*.jar /opt/keycloak/providers/
RUN ls -l /opt/keycloak/providers/

# Abilitazione Features (Token exchange, etc.)
ENV KC_FEATURES="token-exchange,admin-fine-grained-authz"

# Build ottimizzato (senza certificati!)
RUN /opt/keycloak/bin/kc.sh build --db=postgres --features=${KC_FEATURES}

WORKDIR /opt/keycloak
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]