ARG FEDORA_MAJOR_VERSION=37
ARG OPENSHIFT_VERSION=v4

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}
# See https://pagure.io/releng/issue/11047 for final location

#COPY etc /etc

# Run our installation commands from any Copr repos
RUN wget https://copr.fedorainfracloud.org/coprs/calcastor/gnome-patched/repo/fedora-$(rpm -E %fedora)/calcastor-gnome-patched-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_calcastor-gnome-patched.repo

RUN mkdir -p /usr/local/bin

# Install oc and kubectl
RUN wget https://mirror.openshift.com/pub/openshift-${OPENSHIFT_VERSION}/clients/oc/latest/linux/oc.tar.gz -O /usr/local/bin/oc.tar.gz
RUN tar xvzf /usr/local/bin/oc.tar.gz -C /usr/local/bin

# Install operator-sdk
RUN wget https://github.com/operator-framework/operator-sdk/releases/download/v1.25.4/operator-sdk_linux_amd64 -O /usr/local/bin/operator-sdk
RUN chmod +x /usr/local/bin/operator-sdk

# Install mutter patched with triple-buffering
RUN rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:calcastor:gnome-patched mutter

RUN rpm-ostree override remove firefox firefox-langpacks && \
    rpm-ostree install vim zsh distrobox && \
    rm -f /usr/local/bin/oc.tar.gz && \
    rm -f /usr/local/bin/README.md && \
    rm -f /etc/yum.repos.d/_copr_calcastor-gnome-patched.repo && \
    rm -f /etc/yum.repos.d/_copr_bieszczaders-kernel-cachyos-fedora.repo && \
    ostree container commit
