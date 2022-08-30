#!/usr/bin/env bash

ARGS=()

function add_args() {
  ARGS+=("$1")
}

function exit_script() {
  local code=$1
  echo ::set-output name=exit-code::"$code"
  exit "$code"
}

AUTIFY=${INPUT_AUTIFY_PATH}

if [ -z "${INPUT_ACCESS_TOKEN}" ]; then
  echo "Missing access-token."
  exit_script 1
fi

if [ -n "${INPUT_AUTIFY_TEST_URL}" ]; then
  add_args "${INPUT_AUTIFY_TEST_URL}"
else
  echo "Missing autify-test-url."
  exit_script 1
fi

if [ -n "${INPUT_BUILD_ID}" ] && [ -n "${INPUT_BUILD_PATH}" ]; then
  echo "Can't specify both build-id and build-path."
  exit_script 1
elif [ -n "${INPUT_BUILD_ID}" ]; then
  add_args "--build-id=${INPUT_BUILD_ID}"
elif [ -n "${INPUT_BUILD_PATH}" ]; then
  add_args "--build-path=${INPUT_BUILD_PATH}"
else
  echo "Specify either build-id or build-path."
  exit_script 1
fi

if [ "${INPUT_WAIT}" = "true" ]; then 
  add_args "--wait"
fi

if [ -n "${INPUT_TIMEOUT}" ]; then
  add_args "-t=${INPUT_TIMEOUT}"
fi

OUTPUT=$(mktemp)
AUTIFY_MOBILE_ACCESS_TOKEN=${INPUT_ACCESS_TOKEN} ${AUTIFY} mobile test run "${ARGS[@]}" 2>&1 | tee "$OUTPUT"
exit_code=${PIPESTATUS[0]}

# Workaround to return multiline string as outputs
# https://trstringer.com/github-actions-multiline-strings/
output=$(cat "$OUTPUT")
output="${output//'%'/%25}"
output="${output//$'\n'/%0A}"
output="${output//$'\r'/%0D}"
echo ::set-output name=log::"$output"

result=$(grep "Successfully started" "$OUTPUT" | grep -Eo 'https://[^ ]+' | head -1)
echo ::set-output name=result-url::"$result"

build_id=$(grep "Successfully uploaded" "$OUTPUT" | grep -Eo 'ID: [^\)]+' | cut -f2 -d' ' | head -1)
echo ::set-output name=build-id::"${build_id:-$INPUT_BUILD_ID}"

exit_script "$exit_code"
