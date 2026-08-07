#!/usr/bin/bash

set ${CI:+-x} -euo pipefail

ARCH="$(rpm -E '%_arch')"
KERNEL="$(rpm -q "${KERNEL_NAME}" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
RELEASE="$(rpm -E '%fedora')"

curl -LsSf \
    -o /etc/yum.repos.d/_copr_dpratt-aorus-laptop.repo \
    "https://copr.fedorainfracloud.org/coprs/dpratt/aorus-laptop/repo/fedora-${RELEASE}/dpratt-aorus-laptop-fedora-${RELEASE}.repo"

dnf install -y \
    "akmod-aorus-laptop-*.fc${RELEASE}.${ARCH}"

akmods --force \
        --kernels "${KERNEL}" \
        --kmod aorus-laptop

modinfo "/usr/lib/modules/${KERNEL}/extra/aorus-laptop/aorus-laptop.ko.xz" >/dev/null \
|| modinfo "/usr/lib/modules/${KERNEL}/extra/aorus-laptop/aorus-laptop.ko" >/dev/null \
|| (find /var/cache/akmods/aorus-laptop -name '*.log' -print -exec cat {} \; && exit 1)

mkdir -p /var/cache/rpms/extra

dnf download --destdir /var/cache/rpms/extra \
    aorus-laptop

rm -f /var/cache/rpms/extra/*.src.rpm
rm -f /etc/yum.repos.d/_copr_dpratt-aorus-laptop.repo
