# cilium
use values in this folder
to enable cgroupv2 follow below instructions https://github.com/abiosoft/colima/issues/663

## Colima Provision

```yaml
# Number of CPUs to be allocated to the virtual machine.
# Default: 2
cpu: 6

# Size of the disk in GiB to be allocated to the virtual machine.
# NOTE: changing this has no effect after the virtual machine has been created.
# Default: 60
disk: 60

# Size of the memory in GiB to be allocated to the virtual machine.
# Default: 2
memory: 16

# Architecture of the virtual machine (x86_64, aarch64, host).
# Default: host
arch: host

# Container runtime to be used (docker, containerd).
# Default: docker
runtime: docker

# Kubernetes configuration for the virtual machine.
kubernetes:
  # Enable kubernetes.
  # Default: false
  enabled: true

  # Kubernetes version to use.
  # This needs to exactly match a k3s version https://github.com/k3s-io/k3s/releases
  # Default: latest stable release
  version: v1.28.2+k3s1

  # Additional args to pass to k3s https://docs.k3s.io/cli/server
  # Default: traefik is disabled
  k3sArgs:
    - --flannel-backend none
    - --disable servicelb
    - --disable traefik
    - --disable-network-policy
    - --disable-kube-proxy

# Auto-activate on the Host for client access.
# Setting to true does the following on startup
#  - sets as active Docker context (for Docker runtime).
#  - sets as active Kubernetes context (if Kubernetes is enabled).
# Default: true
autoActivate: true

# Network configurations for the virtual machine.
network:
  # Assign reachable IP address to the virtual machine.
  # NOTE: this is currently macOS only and ignored on Linux.
  # Default: false
  address: false

  # Custom DNS resolvers for the virtual machine.
  #
  # EXAMPLE
  # dns: [8.8.8.8, 1.1.1.1]
  #
  # Default: []
  dns: []

  # DNS hostnames to resolve to custom targets using the internal resolver.
  # This setting has no effect if a custom DNS resolver list is supplied above.
  # It does not configure the /etc/hosts files of any machine or container.
  # The value can be an IP address or another host.
  #
  # EXAMPLE
  # dnsHosts:
  #   example.com: 1.2.3.4
  dnsHosts:
    host.docker.internal: host.lima.internal

  # Network driver to use (slirp, gvproxy), (requires vmType `qemu`)
  #   - slirp is the default user mode networking provided by Qemu
  #   - gvproxy is an alternative to VPNKit based on gVisor https://github.com/containers/gvisor-tap-vsock
  # Default: gvproxy
  driver: gvproxy

# ===================================================================== #
# ADVANCED CONFIGURATION
# ===================================================================== #

# Forward the host's SSH agent to the virtual machine.
# Default: false
forwardAgent: false

# Docker daemon configuration that maps directly to daemon.json.
# https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file.
# NOTE: some settings may affect Colima's ability to start docker. e.g. `hosts`.
#
# EXAMPLE - disable buildkit
# docker:
#   features:
#     buildkit: false
#
# EXAMPLE - add insecure registries
# docker:
#   insecure-registries:
#     - myregistry.com:5000
#     - host.docker.internal:5000
#
# Colima default behaviour: buildkit enabled
# Default: {}
docker:
  features:
    buildkit: true
  insecure-registries:
    - localhost:5000
    - host.docker.internal:5000

# Virtual Machine type (qemu, vz)
# NOTE: this is macOS 13 only. For Linux and macOS <13.0, qemu is always used.
#
# vz is macOS virtualization framework and requires macOS 13
#
# Default: qemu
vmType: vz

# Utilise rosetta for amd64 emulation (requires m1 mac and vmType `vz`)
# Default: false
rosetta: true

# Volume mount driver for the virtual machine (virtiofs, 9p, sshfs).
#
# virtiofs is limited to macOS and vmType `vz`. It is the fastest of the options.
#
# 9p is the recommended and the most stable option for vmType `qemu`.
#
# sshfs is faster than 9p but the least reliable of the options (when there are lots
# of concurrent reads or writes).
#
# Default: virtiofs (for vz), sshfs (for qemu)
mountType: virtiofs

# Propagate inotify file events to the VM.
# NOTE: this is experimental.
mountInotify: false

# The CPU type for the virtual machine (requires vmType `qemu`).
# Options available for host emulation can be checked with: `qemu-system-$(arch) -cpu help`.
# Instructions are also supported by appending to the cpu type e.g. "qemu64,+ssse3".
# Default: host
cpuType: host

# For a more general purpose virtual machine, Ubuntu container is optionally provided
# as a layer on the virtual machine.
# The underlying virtual machine is still accessible via `colima ssh --layer=false` or running `colima` in
# the Ubuntu session.
#
# Default: false
layer: false

# Custom provision scripts for the virtual machine.
# Provisioning scripts are executed on startup and therefore needs to be idempotent.
#
# EXAMPLE - script executed as root
# provision:
#   - mode: system
#     script: apk add htop vim
#
# EXAMPLE - script executed as user
# provision:
#   - mode: user
#     script: |
#       [ -f ~/.provision ] && exit 0;
#       echo provisioning as $USER...
#       touch ~/.provision
#
# Default: []
provision:
  - mode: system
    script: |
      mount -t bpf bpffs /sys/fs/bpf
      mount --make-shared /sys/fs/bpf
      mkdir -p /run/cilium/cgroupv2
      mount -t cgroup2 none /run/cilium/cgroupv2
      mount --make-shared /run/cilium/cgroupv2
      mount --make-shared /

# Modify ~/.ssh/config automatically to include a SSH config for the virtual machine.
# SSH config will still be generated in ~/.colima/ssh_config regardless.
# Default: true
sshConfig: true

# Configure volume mounts for the virtual machine.
# Colima mounts user's home directory by default to provide a familiar
# user experience.
#
# EXAMPLE
# mounts:
#   - location: ~/secrets
#     writable: false
#   - location: ~/projects
#     writable: true
#
# Colima default behaviour: $HOME and /tmp/colima are mounted as writable.
# Default: []
mounts: []

# Environment variables for the virtual machine.
#
# EXAMPLE
# env:
#   KEY: value
#   ANOTHER_KEY: another value
#
# Default: {}
env: {}

# Enable cgroups v2 as a temporary workaround for https://github.com/abiosoft/colima/issues/764.
# NOTE: this is incompatible with Kubernetes and Ubuntu Layer.
# NOTE: this config will be removed in future versions.
cgroupsV2: true
```

### Note

If you don't want to set a provision, use below every colima start with kubernetes

colima ssh -- sudo mount -t bpf bpffs /sys/fs/bpf
colima ssh -- sudo mount --make-shared /sys/fs/bpf
colima ssh -- sudo mkdir -p /run/cilium/cgroupv2
colima ssh -- sudo mount -t cgroup2 none /run/cilium/cgroupv2
colima ssh -- sudo mount --make-shared /run/cilium/cgroupv2
colima ssh -- sudo mount --make-shared /