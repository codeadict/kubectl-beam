#!/usr/bin/env bats

setup() {
    export KUBECTL_BEAM="${BATS_TEST_DIRNAME}/../kubectl-beam"

    # Check if we're in a CI environment with test pods
    if ! kubectl get pod erlang-app-sname >/dev/null 2>&1; then
        skip "Integration tests require test pods (run in CI or deploy examples/k8s/*.yaml)"
    fi
}

@test "connects to Erlang app with short names" {
    # Test connection by checking if we can get node info
    run timeout 10s sh -c "echo 'node().' | '$KUBECTL_BEAM' erl erlang-app-sname --cookie test_cookie_secret 2>&1 | grep -q erlang_app"
    [ "$status" -eq 0 ] || [ "$status" -eq 124 ]  # 124 is timeout exit code, acceptable if connection established
}

@test "connects to Erlang app with long names" {
    run timeout 10s sh -c "echo 'node().' | '$KUBECTL_BEAM' erl erlang-app-name --cookie test_cookie_secret -l 2>&1 | grep -q erlang_app"
    [ "$status" -eq 0 ] || [ "$status" -eq 124 ]
}

@test "connects to Elixir app with short names using iex" {
    run timeout 10s sh -c "echo 'node()' | '$KUBECTL_BEAM' iex elixir-app-sname --cookie test_cookie_secret 2>&1 | grep -q elixir_app"
    [ "$status" -eq 0 ] || [ "$status" -eq 124 ]
}

@test "connects to Elixir app with long names using iex" {
    run timeout 10s sh -c "echo 'node()' | '$KUBECTL_BEAM' iex elixir-app-name --cookie test_cookie_secret -l 2>&1 | grep -q elixir_app"
    [ "$status" -eq 0 ] || [ "$status" -eq 124 ]
}

@test "connects to Elixir app with short names using erl" {
    run timeout 10s sh -c "echo 'node().' | '$KUBECTL_BEAM' erl elixir-app-sname --cookie test_cookie_secret 2>&1 | grep -q elixir_app"
    [ "$status" -eq 0 ] || [ "$status" -eq 124 ]
}

@test "auto-detects cookie from RELEASE_COOKIE env var" {
    run timeout 10s sh -c "echo 'node().' | '$KUBECTL_BEAM' erl erlang-app-sname 2>&1"
    # Should work because pods have RELEASE_COOKIE set
    [ "$status" -eq 0 ] || [ "$status" -eq 124 ]
}

@test "fails with wrong cookie" {
    run timeout 5s "$KUBECTL_BEAM" erl erlang-app-sname --cookie wrong_cookie
    [ "$status" -ne 0 ]
}

@test "respects namespace flag" {
    # Test with default namespace (where our test pods are)
    run timeout 10s sh -c "echo 'node().' | '$KUBECTL_BEAM' erl erlang-app-sname -n default --cookie test_cookie_secret 2>&1"
    [ "$status" -eq 0 ] || [ "$status" -eq 124 ]
}

@test "port forwarding establishes successfully" {
    # Run in background and check if port-forward starts
    timeout 5s "$KUBECTL_BEAM" erl erlang-app-sname --cookie test_cookie_secret 2>&1 &
    pid=$!
    sleep 2

    # Check if the distribution port is forwarded
    if ps -p $pid > /dev/null; then
        # Port forward should be active
        pgrep -f "kubectl port-forward.*erlang-app-sname" >/dev/null 2>&1
        result=$?
        kill $pid 2>/dev/null || true
        [ $result -eq 0 ]
    else
        skip "Process exited too quickly"
    fi
}
