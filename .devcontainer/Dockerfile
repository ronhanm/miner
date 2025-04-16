FROM ubuntu:22.04

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
  curl git vim nano wget python3 python3-pip build-essential \
  htop zram-tools docker.io tlp jq unzip nodejs npm cmake \
  && apt clean && rm -rf /var/lib/apt/lists/*

# CPU Performance Mode Settings
RUN echo 'ALGO=lz4' > /etc/default/zramswap && echo 'PERCENT=50' >> /etc/default/zramswap && systemctl enable zramswap
RUN systemctl enable docker

# Global tools
RUN npm install -g npm yarn pm2

# Pre-fetch external scripts to avoid boot-time downloads
WORKDIR /opt/setup-scripts
RUN wget -q https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/thorium.sh && \
    wget -q https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/mega.sh && bash mega.sh \
    wget -q https://raw.githubusercontent.com/naksh-07/Automate/refs/heads/main/ognode.sh && \
    chmod +x thorium.sh

WORKDIR /workspaces/${localWorkspaceFolderBasename}

CMD ["/bin/bash"]
