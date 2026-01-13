# Example Applications

Minimal Erlang and Elixir applications for testing kubectl-beam.

## Short Names vs Long Names

**Short names (-sname)**: Node name without dots (e.g., `myapp@podname`)
**Long names (-name)**: Node name with dots (e.g., `myapp@10.244.0.5` or `myapp@pod.namespace.svc.cluster.local`)

Key differences:
- Short names work when nodes can find each other without DNS (same network segment)
- Long names use DNS resolution and work across networks
- **IP addresses contain dots, so they count as long names**
- Nodes with different name types cannot communicate with each other

In Kubernetes, long names are typically preferred since pods get FQDNs via the DNS service.

## Structure

```
examples/
├── erlang-app/          # Rebar3 + relx
├── elixir-app/          # Mix releases
└── k8s/                 # Pod manifests
    ├── erlang-app-name.yaml
    ├── erlang-app-sname.yaml
    ├── elixir-app-name.yaml
    └── elixir-app-sname.yaml
```

## Local Testing

```bash
# Setup (requires Docker, kind, kubectl)
./setup-local.sh

# Connect
kubectl beam erl erlang-app-sname --cookie test_cookie_secret
kubectl beam erl erlang-app-name --cookie test_cookie_secret -l
kubectl beam iex elixir-app-sname --cookie test_cookie_secret
kubectl beam iex elixir-app-name --cookie test_cookie_secret -l

# Run integration tests
make test-integration
```

## Configuration

**Cookie**: `test_cookie_secret` (set via `RELEASE_COOKIE` env var)
**EPMD**: Port 4369
**Distribution**: Ports 9100-9109

**Note**: Example apps use `POD_IP` environment variable for the node host part. Since IP addresses contain dots (e.g., `10.244.0.5`), they are treated as long names by Erlang. The `-sname` examples would not work in practice with IP addresses - they're included for testing the kubectl-beam tool only.

## Cleanup

```bash
kubectl delete -f k8s/
kind delete cluster --name kubectl-beam-test
```
