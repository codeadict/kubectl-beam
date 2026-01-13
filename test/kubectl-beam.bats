#!/usr/bin/env bats

setup() {
    export KUBECTL_BEAM="${BATS_TEST_DIRNAME}/../kubectl-beam"
}

@test "shows help when no arguments provided" {
    run "$KUBECTL_BEAM"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "kubectl-beam - Connect to BEAM nodes in Kubernetes pods" ]]
}

@test "shows help with --help flag" {
    run "$KUBECTL_BEAM" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
    [[ "$output" =~ "kubectl beam iex" ]]
    [[ "$output" =~ "kubectl beam erl" ]]
}

@test "shows version with --version flag" {
    run "$KUBECTL_BEAM" --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "kubectl-beam version" ]]
}

@test "shows version with -v flag" {
    run "$KUBECTL_BEAM" -v
    [ "$status" -eq 0 ]
    [[ "$output" =~ "kubectl-beam version" ]]
}

@test "shows help for iex command with --help" {
    run "$KUBECTL_BEAM" iex --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "shows help for erl command with --help" {
    run "$KUBECTL_BEAM" erl --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "fails with error when unknown command provided" {
    run "$KUBECTL_BEAM" unknown
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Unknown command: unknown" ]]
}

@test "fails with error when unknown flag provided" {
    run "$KUBECTL_BEAM" iex --unknown-flag pod-name
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Unknown flag: --unknown-flag" ]]
}

@test "fails with error when pod name is missing" {
    run "$KUBECTL_BEAM" iex
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Pod name is required" ]]
}

@test "fails with error when kubectl is not available" {
    # Check if kubectl would be available in restricted PATH
    if env PATH="/usr/bin:/bin" command -v kubectl >/dev/null 2>&1; then
        skip "kubectl is in /usr/bin or /bin"
    fi

    # Run with restricted PATH that doesn't include kubectl
    run env PATH="/usr/bin:/bin" "$KUBECTL_BEAM" iex test-pod
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Missing required dependencies" ]]
}

@test "fails with error when iex is not available for iex command" {
    # Check if we can create a PATH without iex but with kubectl
    if ! command -v kubectl >/dev/null 2>&1; then
        skip "kubectl not available"
    fi

    # Create minimal PATH with kubectl but try to exclude iex
    KUBECTL_PATH=$(dirname "$(command -v kubectl)")
    if env PATH="$KUBECTL_PATH:/usr/bin:/bin" command -v iex >/dev/null 2>&1; then
        skip "iex is in essential system paths"
    fi

    run env PATH="$KUBECTL_PATH:/usr/bin:/bin" "$KUBECTL_BEAM" iex test-pod
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Missing required dependencies" ]]
}

@test "fails with error when erl is not available for erl command" {
    # Check if we can create a PATH without erl but with kubectl
    if ! command -v kubectl >/dev/null 2>&1; then
        skip "kubectl not available"
    fi

    KUBECTL_PATH=$(dirname "$(command -v kubectl)")
    if env PATH="$KUBECTL_PATH:/usr/bin:/bin" command -v erl >/dev/null 2>&1; then
        skip "erl is in essential system paths"
    fi

    run env PATH="$KUBECTL_PATH:/usr/bin:/bin" "$KUBECTL_BEAM" erl test-pod
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Missing required dependencies" ]]
}
