ARG FEDORA_MAJOR_VERSION=37

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}
# See https://pagure.io/releng/issue/11047 for final location

# Add patched Gnome repo
RUN wget https://copr.fedorainfracloud.org/coprs/calcastor/gnome-patched/repo/fedora-$(rpm -E %fedora)/calcastor-gnome-patched-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_calcastor-gnome-patched.repo

# Add VSCode repo
RUN echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo && rpm --import https://packages.microsoft.com/keys/microsoft.asc

# Install Openshift tools -- oc, opm, kubectl, operator-sdk, odo, helm, crc
RUN curl -SL https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/opm-linux.tar.gz | tar xvzf - -C /usr/bin
RUN curl -SL https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/operator-sdk/latest/operator-sdk-linux-x86_64.tar.gz | tar xvzf - --strip-components 2 -C /usr/bin
RUN curl -SL https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz | tar xvzf - -C /usr/bin
RUN curl -SL https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/helm/latest/helm-linux-amd64 -o /usr/bin/helm && chmod +x /usr/bin/helm
RUN curl -SL https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/odo/latest/odo-linux-amd64 -o /usr/bin/odo && chmod +x /usr/bin/odo
RUN curl -SL https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/crc/latest/crc-linux-amd64.tar.xz | tar xfJ - --strip-components 1 -C /usr/bin

# Install awscli
RUN curl -SL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && unzip awscliv2.zip && ./aws/install --bin-dir /usr/bin --install-dir /usr/bin

# Install overrides and additions, remove lingering files
RUN rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:calcastor:gnome-patched mutter && \
    rpm-ostree install vim zsh distrobox code openssl && \
    rm -f /etc/yum.repos.d/vscode.repo && \
    rm -f /etc/_copr_calcastor-gnome-patched.repo && \
    rm -f get_helm.sh && \
    rm -rf aws && \
    rm -f awscliv2.zip && \
    rm -f /usr/bin/README.md && \
    rm -f /usr/bin/LICENSE && \
    ostree container commit
