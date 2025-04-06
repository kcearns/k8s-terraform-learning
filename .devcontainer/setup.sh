#!/bin/bash

# Install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Install just
curl -fsSL https://github.com/casey/just/releases/download/1.14.0/just-1.14.0-x86_64-unknown-linux-musl.tar.gz | tar xz
sudo mv just /usr/local/bin/