#!/bin/sh
#
# Setup script for local kubectl-beam testing with kind
#
# Copyright 2026 Dairon Medina Caro <me@dairon.org>
# SPDX-License-Identifier: Apache-2.0
#

set -eu

CLUSTER_NAME="kubectl-beam-test"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> Setting up local test environment"

# Check dependencies
for cmd in docker kind kubectl; do
    if ! command -v $cmd >/dev/null 2>&1; then
        echo "Error: $cmd is required but not installed"
        exit 1
    fi
done

# Read versions from .tool-versions
if [ -f "$PROJECT_ROOT/.tool-versions" ]; then
    echo "==> Reading versions from .tool-versions"
    OTP_VERSION=$(grep erlang "$PROJECT_ROOT/.tool-versions" | awk '{print $2}')
    ELIXIR_VERSION=$(grep elixir "$PROJECT_ROOT/.tool-versions" | awk '{print $2}' | cut -d'-' -f1)
    ALPINE_VERSION="3.20.3"

    echo "    OTP: $OTP_VERSION"
    echo "    Elixir: $ELIXIR_VERSION"
    echo "    Alpine: $ALPINE_VERSION"
else
    echo "Warning: .tool-versions not found, using default versions"
    OTP_VERSION="27.2"
    ELIXIR_VERSION="1.18.1"
    ALPINE_VERSION="3.20.3"
fi

# Create kind cluster if it doesn't exist
if ! kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    echo "==> Creating kind cluster: $CLUSTER_NAME"
    kind create cluster --name "$CLUSTER_NAME" --wait 60s
else
    echo "==> Using existing kind cluster: $CLUSTER_NAME"
fi

# Build Docker images
echo "==> Building Erlang app image"
docker build \
    --build-arg OTP_VERSION="$OTP_VERSION" \
    --build-arg ALPINE_VERSION="$ALPINE_VERSION" \
    -t erlang-app:test "$SCRIPT_DIR/erlang-app"

echo "==> Building Elixir app image"
docker build \
    --build-arg ELIXIR_VERSION="$ELIXIR_VERSION" \
    --build-arg OTP_VERSION="$OTP_VERSION" \
    --build-arg ALPINE_VERSION="$ALPINE_VERSION" \
    -t elixir-app:test "$SCRIPT_DIR/elixir-app"

# Load images to kind
echo "==> Loading images to kind cluster"
kind load docker-image erlang-app:test --name "$CLUSTER_NAME"
kind load docker-image elixir-app:test --name "$CLUSTER_NAME"

# Deploy pods
echo "==> Deploying test pods"
kubectl apply -f "$SCRIPT_DIR/k8s/erlang-app-sname.yaml"
kubectl apply -f "$SCRIPT_DIR/k8s/erlang-app-name.yaml"
kubectl apply -f "$SCRIPT_DIR/k8s/elixir-app-sname.yaml"
kubectl apply -f "$SCRIPT_DIR/k8s/elixir-app-name.yaml"

# Wait for pods
echo "==> Waiting for pods to be ready"
kubectl wait --for=condition=ready pod/erlang-app-sname --timeout=120s
kubectl wait --for=condition=ready pod/erlang-app-name --timeout=120s
kubectl wait --for=condition=ready pod/elixir-app-sname --timeout=120s
kubectl wait --for=condition=ready pod/elixir-app-name --timeout=120s

# Show pod status
echo ""
echo "==> Pod status:"
kubectl get pods -o wide

echo ""
echo "==> Setup complete!"
echo ""
echo "Try connecting with:"
echo "  kubectl beam erl erlang-app-sname --cookie test_cookie_secret"
echo "  kubectl beam erl erlang-app-name --cookie test_cookie_secret -l"
echo "  kubectl beam iex elixir-app-sname --cookie test_cookie_secret"
echo "  kubectl beam iex elixir-app-name --cookie test_cookie_secret -l"
echo ""
echo "Run integration tests with:"
echo "  make test-integration"
