#!/usr/bin/env bash

log_file=$(dirname "$0")/log
log_fail_file=$(dirname "$0")/log-fail
export GITHUB_OUTPUT

function before() {
  GITHUB_OUTPUT=$(mktemp)
  unset INPUT_AUTIFY_PATH
  unset INPUT_ACCESS_TOKEN
  unset INPUT_AUTIFY_TEST_URL
  unset INPUT_BUILD_ID
  unset INPUT_BUILD_PATH
  unset INPUT_WAIT
  unset INPUT_TIMEOUT
  unset INPUT_MAX_RETRY_COUNT
  echo "=== TEST ==="
}

function test_command() {
  local expected=$1
  local result
  result=$(./script.bash | head -1)

  if [ "$result" == "$expected" ]; then
    echo "Passed command: $expected"
  else
    echo "Failed command:"
    echo "  Expected: $expected"
    echo "  Result  : $result"
    exit 1
  fi
}

function test_code() {
  local expected=$1
  ./script.bash > /dev/null
  local result=$?

  if [ "$result" == "$expected" ]; then
    echo "Passed code: $expected"
  else
    echo "Failed code:"
    echo "  Expected: $expected"
    echo "  Result  : $result"
    exit 1
  fi
}

function test_log() {
  local file=$1
  local result
  result=$(mktemp)
  ./script.bash | tail -n+2 > "$result"

  if (git diff --no-index --quiet -- "$file" "$result"); then
    echo "Passed log:"
  else
    echo "Failed log:"
    git --no-pager diff --no-index -- "$file" "$result"
    exit 1
  fi
}

function test_output() {
  echo > "$GITHUB_OUTPUT"
  local name=$1
  local expected
  expected=$(mktemp)
  echo -e "$2" > "$expected"
  ./script.bash > /dev/null
  local output
  output=$(grep -e "^${name}=" "$GITHUB_OUTPUT" | cut -f2- -d=)
  output="${output//'%25'/%}"
  output="${output//'%0A'/$'\n'}"
  output="${output//'%0D'/$'\r'}"
  local result
  result=$(mktemp)
  echo -e "$output" > "$result"

  if (git diff --no-index --quiet -- "$expected" "$result"); then
    echo "Passed output: $name"
  else
    echo "Failed output: $name"
    git --no-pager diff --no-index -- "$expected" "$result"
    exit 1
  fi
}

{
  before
  export INPUT_AUTIFY_PATH="./test/autify-mock"
  export INPUT_ACCESS_TOKEN=token
  export INPUT_AUTIFY_TEST_URL=a
  export INPUT_BUILD_ID=b
  test_command "autify mobile test run a --build-id=b"
  test_code 0
  test_log "$log_file"
  test_output exit-code "0"
  test_output log "autify mobile test run a --build-id=b\n$(cat "$log_file")"
  test_output build-id "BBB"
  test_output result-url "https://result"
}

{
  before
  export INPUT_AUTIFY_PATH="./test/autify-mock"
  export INPUT_ACCESS_TOKEN=token
  export INPUT_AUTIFY_TEST_URL=a
  export INPUT_BUILD_PATH=c
  test_command "autify mobile test run a --build-path=c"
  test_code 0
  test_log "$log_file"
  test_output exit-code "0"
  test_output log "autify mobile test run a --build-path=c\n$(cat "$log_file")"
  test_output build-id "BBB"
  test_output result-url "https://result"
}

{
  before
  export INPUT_AUTIFY_PATH="./test/autify-mock"
  export INPUT_ACCESS_TOKEN=token
  export INPUT_AUTIFY_TEST_URL=a
  export INPUT_BUILD_ID=b
  export INPUT_BUILD_PATH=c
  test_command "Can't specify both build-id and build-path."
  test_code 1
  test_output exit-code "1"
  test_output log ""
  test_output build-id ""
  test_output result-url ""
}

{
  before
  export INPUT_AUTIFY_PATH="./test/autify-mock"
  export INPUT_ACCESS_TOKEN=token
  export INPUT_AUTIFY_TEST_URL=a
  export INPUT_BUILD_ID=b
  export INPUT_WAIT=true
  export INPUT_TIMEOUT=300
  test_command "autify mobile test run a --build-id=b --wait -t=300"
  test_code 0
  test_log "$log_file"
  test_output exit-code "0"
  test_output log "autify mobile test run a --build-id=b --wait -t=300\n$(cat "$log_file")"
  test_output build-id "BBB"
  test_output result-url "https://result"
}

{
  before
  export INPUT_AUTIFY_PATH="./test/autify-mock"
  export INPUT_ACCESS_TOKEN=token
  export INPUT_AUTIFY_TEST_URL=a
  export INPUT_BUILD_ID=b
  export INPUT_WAIT=true
  export INPUT_TIMEOUT=300
  export INPUT_MAX_RETRY_COUNT=1
  test_command "autify mobile test run a --build-id=b --wait -t=300 --max-retry-count=1"
  test_code 0
  test_log "$log_file"
  test_output exit-code "0"
  test_output log "autify mobile test run a --build-id=b --wait -t=300 --max-retry-count=1\n$(cat "$log_file")"
  test_output build-id "BBB"
  test_output result-url "https://result"
}

{
  before
  export INPUT_AUTIFY_PATH="./test/autify-mock-fail"
  export INPUT_ACCESS_TOKEN=token
  export INPUT_AUTIFY_TEST_URL=a
  export INPUT_BUILD_ID=b
  test_command "autify-fail mobile test run a --build-id=b"
  test_code 1
  test_log "$log_fail_file"
  test_output exit-code "1"
  test_output log "autify-fail mobile test run a --build-id=b\n$(cat "$log_fail_file")"
  test_output build-id "b"
  test_output result-url ""
}

{
  before
  export INPUT_AUTIFY_PATH="./test/autify-mock-fail"
  export INPUT_ACCESS_TOKEN=token
  export INPUT_AUTIFY_TEST_URL=a
  export INPUT_BUILD_PATH=c
  test_command "autify-fail mobile test run a --build-path=c"
  test_code 1
  test_log "$log_fail_file"
  test_output exit-code "1"
  test_output log "autify-fail mobile test run a --build-path=c\n$(cat "$log_fail_file")"
  test_output build-id ""
  test_output result-url ""
}
