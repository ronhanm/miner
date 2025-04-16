#!/bin/bash

# Bhai yeh tera dream setup hai: 4 Core + 16GB RAM + Ubuntu 22.04
# Ab aur bhi tezz, Codespace ka Verstappen bana diya isko 🚀

WORKSPACE="/workspaces/$(basename "$PWD")"
DEVCONTAINER_PATH="$WORKSPACE/.devcontainer"

mkdir -p "$DEVCONTAINER_PATH"

echo "⚙️ Setting up Ultra OP Dev Container in $DEVCONTAINER_PATH..."

# devcontainer.json — optimized for speed and only runs setup once
cat <<EOF > "$DEVCONTAINER_PATH/devcontainer.json"
{
  "name": "OP Ubuntu Dev Container 4Core-16GB",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu-22.04",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-azuretools.vscode-docker"
      ]
    }
  },
  "hostRequirements": {
    "cpus": 4,
    "memory": "16gb"
  },
  "onCreateCommand": "bash .devcontainer/setup.sh",
  "postStartCommand": "systemctl start docker || true",
  "remoteUser": "vscode",
  "mounts": [
    {
      "source": "\${localWorkspaceFolder}",
      "target": "/workspaces/\${localWorkspaceFolderBasename}",
      "type": "bind"
    }
  ]
}
EOF

echo "✅ devcontainer.json ready!"

# Dockerfile — efficient layer caching + setup
cat <<EOF > "$DEVCONTAINER_PATH/Dockerfile"
FROM ubuntu:22.04

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \\
  curl git vim nano wget python3 python3-pip build-essential \\
  htop zram-tools docker.io tlp jq unzip nodejs npm cmake \\
  && apt clean && rm -rf /var/lib/apt/lists/*

# CPU Performance Mode Settings
RUN echo 'ALGO=lz4' > /etc/default/zramswap && echo 'PERCENT=50' >> /etc/default/zramswap && systemctl enable zramswap
RUN systemctl enable docker

# Global tools
RUN npm install -g npm yarn pm2

# Pre-fetch external scripts to avoid boot-time downloads
WORKDIR /opt/setup-scripts
RUN wget -q https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/thorium.sh && \\
    wget -q https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/gaianet.sh && \\
    wget -q https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/ognode.sh && \\
    chmod +x thorium.sh

WORKDIR /workspaces/\${localWorkspaceFolderBasename}

CMD ["/bin/bash"]
EOF

echo "✅ Dockerfile done!"

# setup.sh — runs only ONCE when container is created
cat <<EOF > "$DEVCONTAINER_PATH/setup.sh"
#!/bin/bash

echo "🔥 Running OP Setup - One-Time Performance Mode ON... (\$(date))"

# Restart zram/dockers if not active
! systemctl is-active --quiet docker && systemctl start docker
! systemctl is-active --quiet zramswap && systemctl restart zramswap
! systemctl is-active --quiet tlp && systemctl start tlp

# CPU Performance Mode
echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null

# File descriptor limits
if ! grep -q "1048576" /etc/security/limits.conf; then
  echo '* soft nofile 1048576' | tee -a /etc/security/limits.conf
  echo '* hard nofile 1048576' | tee -a /etc/security/limits.conf
fi
ulimit -n 1048576

# Run external scripts (once downloaded by Dockerfile)
cd /opt/setup-scripts
[ -x thorium.sh ] && ./thorium.sh
[ -f gaianet.sh ] && bash gaianet.sh
[ -f ognode.sh ] && bash ognode.sh

echo "✅ All Done Bhai! Ultra OP Container READY 🚀 (\$(date))"
EOF

chmod +x "$DEVCONTAINER_PATH/setup.sh"

echo "🎉 Setup complete Bhai! Jaake Codespace rebuild maar!"

echo -e "\n🛠️ Run this to rebuild:\n"
echo "devcontainer rebuild-container"
