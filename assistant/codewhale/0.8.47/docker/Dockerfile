FROM ghcr.io/hmbown/codewhale:v0.8.47

# Switch to root temporarily to configure network utilities and permissions
USER root

# Install tool dependencies — tools.sh dispatches to every script in tools.d/
# (single RUN layer — each script handles its own cleanup)
COPY tools.sh /tmp/tools.sh
COPY tools.d/ /tmp/tools.d/
RUN bash /tmp/tools.sh && rm -rf /tmp/tools.sh /tmp/tools.d

# Copy your entrypoint script into the system path
COPY entrypoint.sh /usr/local/bin/hardened-entrypoint.sh
RUN chmod +x /usr/local/bin/hardened-entrypoint.sh

# Instruct Docker to run our script first on startup
ENTRYPOINT ["/usr/local/bin/hardened-entrypoint.sh"]
