#!/bin/sh
set -eu

# 1. Block outbound access to private network spaces
iptables -A OUTPUT -d 10.0.0.0/8 -j DROP 2>/dev/null || true
iptables -A OUTPUT -d 172.16.0.0/12 -j DROP 2>/dev/null || true
iptables -A OUTPUT -d 192.168.0.0/16 -j DROP 2>/dev/null || true
iptables -A OUTPUT -d 169.254.169.254/32 -j DROP 2>/dev/null || true

# 2. Match the container user's ID with the host directory owner ID
HOST_UID=$(stat -c '%u' /workspace)
HOST_GID=$(stat -c '%g' /workspace)

# Remap the container's codewhale user to match your host terminal user context
usermod -o -u "$HOST_UID" codewhale >/dev/null 2>&1 || true
groupmod -o -g "$HOST_GID" codewhale >/dev/null 2>&1 || true

# Allow passwordless sudo for the codewhale user (prevents sudo from hanging on password prompts)
echo "codewhale ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/codewhale
chmod 440 /etc/sudoers.d/codewhale

# 3. CRITICAL: Force fix the internal state volume permissions
# This ensures that no matter what UID the volume initialized with, 
# your dynamically remapped user owns it completely.
chown -R codewhale:codewhale /home/codewhale/.codewhale

# 3a. Symlink /tmp/session.d → the mounted session tools directory for convenience
if [ -n "${CODEWHALE_TOOLS_DIR:-}" ] && [ -d "$CODEWHALE_TOOLS_DIR" ]; then
    ln -sfn "$CODEWHALE_TOOLS_DIR" /tmp/session.d
fi

# 4. Handle Executable Routing
# If the first argument passed in is an executable shell or command, run it directly.
# Otherwise, default to launching the codewhale-tui application.
if [ "$#" -gt 0 ] && { [ "$1" = "sh" ] || [ "$1" = "bash" ] || [ -x "$1" ]; }; then
    exec gosu codewhale "$@"
else
    exec gosu codewhale codewhale-tui "$@"
fi
