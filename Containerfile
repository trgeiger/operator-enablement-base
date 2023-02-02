ARG FEDORA_MAJOR_VERSION=37

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}
# See https://pagure.io/releng/issue/11047 for final location

#COPY etc /etc

# Add patched Gnome Copr repo
RUN curl -SL https://copr.fedorainfracloud.org/coprs/calcastor/gnome-patched/repo/fedora-$(rpm -E %fedora)/calcastor-gnome-patched-fedora-$(rpm -E %fedora).repo -o /etc/yum.repos.d/_copr_calcastor-gnome-patched.repo

# Install oc and kubectl
RUN curl -SL https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz | tar xvzf - -C /usr/bin

# Install operator-sdk
RUN curl -SL https://github.com/operator-framework/operator-sdk/releases/download/v1.25.4/operator-sdk_linux_amd64 -o /usr/bin/operator-sdk && chmod +x /usr/bin/operator-sdk

# Install mutter patched with triple-buffering
RUN rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:calcastor:gnome-patched mutter

RUN rpm-ostree override remove firefox firefox-langpacks && \
    rpm-ostree install vim zsh distrobox && \
    rm -f /usr/local/bin/README.md && \
    rm -f /etc/yum.repos.d/_copr_calcastor-gnome-patched.repo && \
    rm -f /etc/yum.repos.d/_copr_bieszczaders-kernel-cachyos-fedora.repo && \
    ostree container commit
