# kubectl-beam

[![CI](https://github.com/codeadict/kubectl-beam/actions/workflows/ci.yml/badge.svg)](https://github.com/codeadict/kubectl-beam/actions)

A kubectl plugin for connecting to BEAM (Erlang VM) nodes running in Kubernetes pods.

## Installation

### Using Make

```bash
make install
```

This installs the plugin to `~/.local/bin/kubectl-beam`. Make sure `~/.local/bin` is in your PATH.

### Manual Installation

Copy the `kubectl-beam` script to any directory in your PATH:

```bash
cp kubectl-beam /usr/local/bin/
chmod +x /usr/local/bin/kubectl-beam
```

### Verify Installation

```bash
kubectl beam --version
```

## Requirements

- `kubectl` configured and connected to a Kubernetes cluster
- For IEx shells: Elixir installed locally
- For Erlang shells: Erlang/OTP installed locally
- For Observer mode: Erlang/OTP with wx support

**Note:** For IEx remote shells, your local Erlang/Elixir versions should match the deployed pod versions to avoid compatibility issues. The `erl` command is more forgiving with version mismatches.

## Usage

### Basic Examples

Connect to a pod using IEx:
```bash
kubectl beam iex my-app-pod
```

Connect to a pod in a specific namespace:
```bash
kubectl beam iex -n production my-app-pod
```

Connect using Erlang shell:
```bash
kubectl beam erl my-app-pod
```

### Observer Mode

Start the Erlang Observer GUI connected to a remote node:
```bash
kubectl beam iex --observer -n production my-app-pod
```

This launches the Observer application locally, allowing you to inspect processes, memory usage, and other runtime metrics on the remote node.

### Advanced Usage

Use long names instead of short names:
```bash
kubectl beam iex -l my-app-pod
```

Specify an explicit cookie:
```bash
kubectl beam iex --cookie mysecretcookie my-app-pod
```

Specify a custom cookie path on the pod:
```bash
kubectl beam iex --cookie-path /app/config/.erlang.cookie my-app-pod
```

Specify a cookie from a custom environment variable:
```bash
kubectl beam iex --cookie-env MY_COOKIE_VAR my-app-pod
```

Connect to a specific container in a multi-container pod:
```bash
kubectl beam iex -c app-container my-app-pod
```

## How It Works

The plugin establishes a connection to remote BEAM nodes by:

1. Querying EPMD inside the pod for the node's distribution port and port-forwarding only that port to localhost
2. Automatically detecting or accepting a specified Erlang cookie
3. Configuring local DNS resolution to map the pod IP to localhost
4. Starting a local hidden BEAM node that connects to the remote node via `--remsh`

This approach provides full terminal support because the shell runs locally while communicating with the remote node through the port-forward tunnel.

## Cookie Detection

The plugin attempts to detect the Erlang cookie in the following order:

1. Explicitly provided via `--cookie` flag
2. From a custom path via `--cookie-path` flag
3. From environment variables (tried in order):
   - `$RELEASE_COOKIE`
   - `$ERLANG_COOKIE`
   - `$COOKIE`
4. From common file paths:
   - `/opt/app/releases/COOKIE`
   - `/app/releases/COOKIE`
   - `/opt/release/COOKIE`
   - `/release/COOKIE`
   - `~/.erlang.cookie`
   - `/root/.erlang.cookie`

## Flags

| Flag | Description | Default |
|------|-------------|---------|
| `-n, --namespace` | Kubernetes namespace | `default` |
| `-c, --container` | Container name (for multi-container pods) | |
| `--observer` | Start Observer GUI | `false` |
| `-l, --long-names` | Use long names | `false` |
| `--cookie` | Explicit Erlang cookie | Auto-detected |
| `--cookie-path` | Path to cookie file on pod | |
| `--cookie-env` | Environment variable containing cookie | `RELEASE_COOKIE` |

## Troubleshooting

### Cannot detect cookie

If the plugin cannot automatically detect the cookie, specify it explicitly:

```bash
kubectl beam iex --cookie yourcookie my-app-pod
```

Or specify the path where the cookie is stored:

```bash
kubectl beam iex --cookie-path /custom/path/to/.erlang.cookie my-app-pod
```

### Port forwarding fails

Ensure no other process is using the node's distribution port on your local machine. The local port must match the pod's port, because the local node connects to the port the remote node registered in EPMD.

### Multiple nodes detected

If multiple BEAM nodes are running in the same pod, set the `NODE_BASENAME` environment variable in your pod to specify which node to connect to.

### Observer requires wx support

If Observer mode fails with an error about wx, ensure your local Erlang installation includes wx support:

```bash
erl -noshell -eval 'wx:new(), init:stop()'
```

## Examples

The `examples/` directory contains minimal Erlang and Elixir applications demonstrating both short names (sname) and long names (name) for testing kubectl-beam.

### Quick Start with Examples

```bash
# Setup local test environment with kind
./examples/setup-local.sh

# Connect to test pods
kubectl beam erl erlang-app-sname --cookie test_cookie_secret
kubectl beam iex elixir-app-name --cookie test_cookie_secret -l
```

See [examples/README.md](examples/README.md) for detailed information about short names vs long names and testing.

## Development

### Running Tests

Install bats-core and run the test suite:

```bash
brew install bats-core  # macOS
# or
apt-get install bats    # Debian/Ubuntu

# Unit tests (no cluster required)
make test

# Integration tests (requires deployed test pods)
make test-integration

# All tests
make test-all
```

## License

Copyright 2026 Dairon Medina Caro <me@dairon.org>

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) file for details.
