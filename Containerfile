ARG FEDORA_MAJOR_VERSION=37

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}
# See https://pagure.io/releng/issue/11047 for final location

#COPY etc /etc

RUN rpm-ostree cliwrap install-to-root /

# Add VSCode repo
RUN echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo && rpm --import https://packages.microsoft.com/keys/microsoft.asc

# Install oc and kubectl
RUN curl -SL https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz | tar xvzf - -C /usr/bin

# Install operator-sdk
RUN curl -SL https://github.com/operator-framework/operator-sdk/releases/download/v1.25.4/operator-sdk_linux_amd64 -o /usr/bin/operator-sdk && chmod +x /usr/bin/operator-sdk

# Install helm
RUN curl -SL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod 700 get_helm.sh && HELM_INSTALL_DIR=/usr/bin VERIFY_CHECKSUM=false ./get_helm.sh

# Install awscli
RUN curl -SL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && unzip awscliv2.zip && ./aws/install --bin-dir /usr/bin --install-dir /usr/bin

# Install overrides and additions, remove Copr repo files
RUN rpm-ostree install vim zsh distrobox setroubleshoot-server code && \
    rm -f /etc/yum.repos.d/vscode.repo && \
    rm -f get_helm.sh && \
    rm -rf aws && \
    rm -f awscliv2.zip && \
    rm -f /usr/bin/README.md && \
    rpm-ostree cleanup -m && \
    ostree container commit
